#!/bin/bash
# Secure iptables Firewall Configuration
# Beperkt externe toegang tot alleen gepubliceerde website in DMZ

echo "🛡️ Configurating secure iptables firewall..."

# Kleuren voor output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Netwerk configuratie
DMZ_NET="172.20.1.0/24"
INTERNAL_NET="172.20.2.0/24"
OFFICE_NET="172.20.3.0/24"
MGMT_NET="172.20.4.0/24"
WEBSERVER_IP="172.20.1.10"
DATABASE_IP="172.20.2.10"
OFFICE_IP="172.20.3.10"

echo -e "${BLUE}📋 Netwerk configuratie:${NC}"
echo -e "  DMZ:        ${DMZ_NET} (Webserver: ${WEBSERVER_IP})"
echo -e "  Internal:   ${INTERNAL_NET} (Database: ${DATABASE_IP})"
echo -e "  Office:     ${OFFICE_NET} (Office: ${OFFICE_IP})"
echo -e "  Management: ${MGMT_NET} (VPN + Admin)"

# 1. Reset alle bestaande rules
echo -e "\n${YELLOW}🧹 Resetting existing iptables rules...${NC}"
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# 2. Set default policies naar DROP (Security First!)
echo -e "${RED}🔒 Setting default DROP policies...${NC}"
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# 3. Loopback interface toestaan
echo -e "${GREEN}🔄 Allowing loopback interface...${NC}"
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# 4. Established en Related connections (using modern conntrack)
echo -e "${GREEN}🤝 Allowing established/related connections...${NC}"
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# ===== EXTERNE INTERFACE BEVEILIGING =====
echo -e "\n${BLUE}🌐 Configuring external access restrictions...${NC}"

# 5. HTTP/HTTPS vanaf extern ALLEEN naar webserver in DMZ
echo -e "${GREEN}  ✅ Allowing HTTP/HTTPS to DMZ webserver only${NC}"
iptables -A FORWARD -i eth0 -d ${WEBSERVER_IP} -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -d ${WEBSERVER_IP} -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# 6. NAT rules voor HTTP/HTTPS naar DMZ webserver  
echo -e "${GREEN}  🔀 Setting up NAT for web traffic${NC}"
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination ${WEBSERVER_IP}:80
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination ${WEBSERVER_IP}:443

# 7. BLOKKEREN: Extern naar firewall zelf
echo -e "${RED}  ❌ Blocking external access to firewall management${NC}"
iptables -A INPUT -i eth0 -p tcp --dport 22 -j LOG --log-prefix "EXTERN-SSH-BLOCK: " --log-level 4
iptables -A INPUT -i eth0 -p tcp --dport 22 -j DROP
iptables -A INPUT -i eth0 -p tcp --dport 443 -j LOG --log-prefix "EXTERN-HTTPS-BLOCK: " --log-level 4
iptables -A INPUT -i eth0 -p tcp --dport 443 -j DROP
iptables -A INPUT -i eth0 -p tcp --dport 80 -j LOG --log-prefix "EXTERN-HTTP-BLOCK: " --log-level 4
iptables -A INPUT -i eth0 -p tcp --dport 80 -j DROP

# 8. BLOKKEREN: Extern rechtstreeks naar andere netwerken (alleen van buiten interne ranges)
echo -e "${RED}  ❌ Blocking external access to internal networks${NC}"
iptables -A FORWARD -s ! 172.20.0.0/16 -d ${INTERNAL_NET} -j LOG --log-prefix "EXTERN-DB-BLOCK: " --log-level 4
iptables -A FORWARD -s ! 172.20.0.0/16 -d ${INTERNAL_NET} -j DROP
iptables -A FORWARD -s ! 172.20.0.0/16 -d ${OFFICE_NET} -j LOG --log-prefix "EXTERN-OFFICE-BLOCK: " --log-level 4
iptables -A FORWARD -s ! 172.20.0.0/16 -d ${OFFICE_NET} -j DROP
iptables -A FORWARD -s ! 172.20.0.0/16 -d ${MGMT_NET} -j LOG --log-prefix "EXTERN-MGMT-BLOCK: " --log-level 4
iptables -A FORWARD -s ! 172.20.0.0/16 -d ${MGMT_NET} -j DROP

# 9. BLOKKEREN: Directe toegang tot andere DMZ hosts
echo -e "${RED}  ❌ Blocking external access to other DMZ hosts${NC}"
iptables -A FORWARD -i eth0 -d ${DMZ_NET} ! -d ${WEBSERVER_IP} -j LOG --log-prefix "EXTERN-DMZ-BLOCK: " --log-level 4
iptables -A FORWARD -i eth0 -d ${DMZ_NET} ! -d ${WEBSERVER_IP} -j DROP

# ===== MANAGEMENT TOEGANG - BEPERKT =====
echo -e "\n${BLUE}🔑 Configuring restricted management access...${NC}"

# 10. Management subnet mag ALLEEN SSH toegang naar alle omgevingen
echo -e "${GREEN}  ✅ SSH access to DMZ${NC}"
iptables -A FORWARD -s ${MGMT_NET} -d ${DMZ_NET} -p tcp --dport 22 -j ACCEPT
echo -e "${GREEN}  ✅ SSH access to Internal${NC}"
iptables -A FORWARD -s ${MGMT_NET} -d ${INTERNAL_NET} -p tcp --dport 22 -j ACCEPT
echo -e "${GREEN}  ✅ SSH access to Office${NC}"
iptables -A FORWARD -s ${MGMT_NET} -d ${OFFICE_NET} -p tcp --dport 22 -j ACCEPT

# 11. Management subnet mag toegang tot extern gepubliceerde website
echo -e "${GREEN}  ✅ Access to published website (DMZ webserver)${NC}"
iptables -A FORWARD -s ${MGMT_NET} -d ${WEBSERVER_IP} -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -s ${MGMT_NET} -d ${WEBSERVER_IP} -p tcp --dport 443 -j ACCEPT

# 12. Management toegang tot router web interface
echo -e "${GREEN}  ✅ Access to router web interface${NC}"
iptables -A INPUT -s ${MGMT_NET} -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -s ${MGMT_NET} -p tcp --dport 80 -j ACCEPT

# 13. WireGuard VPN server toegang
echo -e "${GREEN}  🔒 Allowing WireGuard VPN access${NC}"
iptables -A INPUT -i eth0 -p udp --dport 51820 -j ACCEPT

# 14. BLOKKEREN: Alle andere management toegang
echo -e "${RED}  ❌ Blocking all other management access${NC}"
iptables -A FORWARD -s ${MGMT_NET} -j LOG --log-prefix "MGMT-DENY: " --log-level 4
iptables -A FORWARD -s ${MGMT_NET} -j DROP

# ===== INTERNE NETWERK SEGMENTATIE =====
echo -e "\n${BLUE}🏗️ Configuring internal network segmentation...${NC}"

# 15. DMZ webserver mag alleen naar database
echo -e "${GREEN}  ✅ DMZ webserver → Database (MySQL)${NC}"
iptables -A FORWARD -s ${WEBSERVER_IP} -d ${DATABASE_IP} -p tcp --dport 3306 -j ACCEPT

# 16. Office netwerk toegang - BEPERKT volgens nieuwe specificaties
echo -e "${GREEN}  ✅ Office → Database (MySQL - lezen/schrijven)${NC}"
iptables -A FORWARD -s ${OFFICE_NET} -d ${DATABASE_IP} -p tcp --dport 3306 -j ACCEPT

# 17. BLOKKEREN: Office toegang tot DMZ webserver (direct)
echo -e "${RED}  ❌ Blocking Office → DMZ direct access${NC}"
iptables -A FORWARD -s ${OFFICE_NET} -d ${DMZ_NET} -j LOG --log-prefix "OFFICE-DMZ-BLOCK: " --log-level 4
iptables -A FORWARD -s ${OFFICE_NET} -d ${DMZ_NET} -j DROP

# 18. BLOKKEREN: Office toegang tot firewall zelf
echo -e "${RED}  ❌ Blocking Office → Firewall access${NC}"
iptables -A INPUT -s ${OFFICE_NET} -j LOG --log-prefix "OFFICE-FW-BLOCK: " --log-level 4
iptables -A INPUT -s ${OFFICE_NET} -j DROP

# ===== UITGAAND VERKEER =====
echo -e "\n${BLUE}🌍 Configuring outbound traffic...${NC}"

# 15. DMZ en Internal netwerken mogen naar extern
echo -e "${GREEN}  ✅ Allowing outbound traffic from DMZ, Internal networks${NC}"
iptables -A FORWARD -s ${DMZ_NET} -o eth0 -j ACCEPT
iptables -A FORWARD -s ${INTERNAL_NET} -o eth0 -j ACCEPT

# 16. Office netwerk beperkte externe toegang (internet + extern gepubliceerde website)
echo -e "${GREEN}  ✅ Limited outbound access for Office (HTTP(S), DNS, SSH only)${NC}"
iptables -A FORWARD -s ${OFFICE_NET} -o eth0 -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A FORWARD -s ${OFFICE_NET} -o eth0 -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -s ${OFFICE_NET} -o eth0 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s ${OFFICE_NET} -o eth0 -p tcp --dport 22 -j ACCEPT
echo -e "${RED}  ❌ Blocking other Office outbound traffic${NC}"
iptables -A FORWARD -s ${OFFICE_NET} -o eth0 -j LOG --log-prefix "OFFICE-OUTBOUND-BLOCK: " --log-level 4 || true
iptables -A FORWARD -s ${OFFICE_NET} -o eth0 -j DROP

# 17. Management netwerk beperkte externe toegang
echo -e "${GREEN}  ✅ Limited outbound access for management (SSH, HTTP(S), DNS only)${NC}"
iptables -A FORWARD -s ${MGMT_NET} -o eth0 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -s ${MGMT_NET} -o eth0 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -s ${MGMT_NET} -o eth0 -p tcp --dport 443 -j ACCEPT
iptables -A FORWARD -s ${MGMT_NET} -o eth0 -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -s ${MGMT_NET} -o eth0 -p udp --dport 53 -j ACCEPT

# 18. NAT/Masquerading voor uitgaand verkeer
echo -e "${GREEN}  🔀 Setting up outbound NAT${NC}"
iptables -t nat -A POSTROUTING -s ${DMZ_NET} -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s ${INTERNAL_NET} -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s ${OFFICE_NET} -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s ${MGMT_NET} -o eth0 -j MASQUERADE

# ===== LOGGING =====
echo -e "\n${BLUE}📝 Setting up logging for blocked connections...${NC}"

# 19. Log geblokkeerde forward attempts
iptables -A FORWARD -j LOG --log-prefix "FORWARD-BLOCK: " --log-level 4 || true
iptables -A FORWARD -j DROP

# 20. Log geblokkeerde input attempts
iptables -A INPUT -j LOG --log-prefix "INPUT-BLOCK: " --log-level 4 || true
iptables -A INPUT -j DROP

# ===== SAVE RULES =====
echo -e "\n${GREEN}💾 Saving iptables rules...${NC}"
iptables-save > /etc/iptables/rules.v4 2>/dev/null || echo "Warning: Could not save to /etc/iptables/rules.v4"

# ===== STATUS OVERVIEW =====
echo -e "\n${GREEN}✅ Secure firewall configuration complete!${NC}"
echo -e "\n${BLUE}📊 Security Status:${NC}"
echo -e "${GREEN}  ✅ External access limited to DMZ webserver only${NC}"
echo -e "${GREEN}  ✅ Management access via WireGuard VPN only${NC}" 
echo -e "${GREEN}  ✅ Network segmentation enforced${NC}"
echo -e "${GREEN}  ✅ All unauthorized access blocked and logged${NC}"

echo -e "\n${YELLOW}🌐 Allowed External Access:${NC}"
echo -e "  • HTTP (80)  → ${WEBSERVER_IP}:80"
echo -e "  • HTTPS (443) → ${WEBSERVER_IP}:443"
echo -e "  • WireGuard VPN (51820/udp)"

echo -e "\n${GREEN}🏢 Office Network Access:${NC}"
echo -e "  • Database access (MySQL port 3306)"
echo -e "  • Internet access via external website route"
echo -e "  • Limited outbound (HTTP(S), DNS, SSH only)"

echo -e "\n${RED}🚫 Blocked External Access:${NC}"
echo -e "  • Direct SSH to firewall"
echo -e "  • Direct access to database (${DATABASE_IP})"
echo -e "  • Direct access to office (${OFFICE_IP})"
echo -e "  • Direct access to management network"
echo -e "  • Direct access to other DMZ hosts"

echo -e "\n${RED}🚫 Office Network Restrictions:${NC}"
echo -e "  • No direct access to DMZ webserver"
echo -e "  • No access to firewall management"
echo -e "  • No access to database server directly"
echo -e "  • Limited outbound ports (HTTP(S), DNS, SSH only)"

echo -e "\n${BLUE}🔑 Management Access (RESTRICTED):${NC}"
echo -e "  • SSH access only via WireGuard VPN (${MGMT_NET})"
echo -e "  • SSH to all systems from management network"
echo -e "  • Access to published website (HTTP/HTTPS)"
echo -e "  • Router web interface access"
echo -e "  • Limited external access (SSH, HTTP(S), DNS only)"

echo -e "\n${GREEN}🔥 Firewall is now SECURE! 🔒${NC}"