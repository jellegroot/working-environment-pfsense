#!/usr/bin/env python3
"""
Website Access Tool voor Office Werkomgeving
Test toegang tot de webserver en toont website status
"""

import requests
import sys
import os
from datetime import datetime

# Website configuratie
WEBSITE_URL = "http://webserver"
LOGIN_URL = f"{WEBSITE_URL}/login"

def test_website_access():
    """Test toegang tot de website"""
    print("WEBSITE TOEGANG TEST")
    print("=" * 30)
    
    try:
        # Test basis website toegang
        response = requests.get(WEBSITE_URL, timeout=10)
        if response.status_code == 200:
            print(f"Website bereikbaar: {WEBSITE_URL}")
            print(f"Status Code: {response.status_code}")
            print(f"Content-Length: {len(response.content)} bytes")
        else:
            print(f"Website response: {response.status_code}")
        
        # Test login pagina
        login_response = requests.get(LOGIN_URL, timeout=10)
        if login_response.status_code == 200:
            print(f"Login pagina bereikbaar: {LOGIN_URL}")
        else:
            print(f"Login pagina niet bereikbaar: {login_response.status_code}")
            
    except requests.exceptions.ConnectTimeout:
        print(f"Timeout bij verbinding met {WEBSITE_URL}")
    except requests.exceptions.ConnectionError:
        print(f"Kan geen verbinding maken met {WEBSITE_URL}")
    except Exception as e:
        print(f"Fout bij website test: {e}")

def test_login(username=None, password=None):
    """Test login functionaliteit"""
    if username is None:
        username = os.environ.get('DEFAULT_TEST_USERNAME', 'testuser')
    if password is None:
        password = os.environ.get('DEFAULT_TEST_PASSWORD', 'password123')
    print(f"\n🔐 LOGIN TEST - {username}")
    print("=" * 30)
    
    try:
        # Start sessie
        session = requests.Session()
        
        # Haal login pagina op voor CSRF token (indien nodig)
        login_page = session.get(LOGIN_URL, timeout=10)
        
        # Login gegevens
        login_data = {
            'username': username,
            'password': password
        }
        
        # Probeer in te loggen
        login_response = session.post(LOGIN_URL, data=login_data, timeout=10)
        
        if "Dashboard" in login_response.text or login_response.url.endswith("/dashboard"):
            print(f"Login succesvol voor {username}")
            
            # Test dashboard toegang
            dashboard_response = session.get(f"{WEBSITE_URL}/dashboard", timeout=10)
            if dashboard_response.status_code == 200:
                print("Dashboard toegankelijk")
            else:
                print("Dashboard niet toegankelijk")
                
        elif "Ongeldige" in login_response.text:
            print(f"Login mislukt: Ongeldige gebruikersnaam of wachtwoord")
        else:
            print(f"Onbekende login response")
            
    except Exception as e:
        print(f" Fout bij login test: {e}")

def download_user_data():
    """Download gebruikersdata via website (indien beschikbaar)"""
    print("\n GEBRUIKERSDATA DOWNLOAD")
    print("=" * 30)
    
    try:
        # Login als admin
        session = requests.Session()
        login_data = {
            'username': os.environ.get('DEFAULT_ADMIN_USERNAME', 'admin'),
            'password': os.environ.get('DEFAULT_ADMIN_PASSWORD', 'password123')
        }
        
        login_response = session.post(LOGIN_URL, data=login_data, timeout=10)
        
        if "Dashboard" in login_response.text:
            print("Admin login succesvol")
            
            # Probeer gebruikers pagina te bereiken
            users_response = session.get(f"{WEBSITE_URL}/users", timeout=10)
            if users_response.status_code == 200:
                print("Gebruikers pagina toegankelijk")
                print(f"Pagina grootte: {len(users_response.content)} bytes")
                
                # Sla HTML op voor analyse
                with open("/home/office/Documents/Data/users_page.html", "w") as f:
                    f.write(users_response.text)
                print("Gebruikers data opgeslagen in: /home/office/Documents/Data/users_page.html")
                
            else:
                print("Gebruikers pagina niet toegankelijk")
        else:
            print("Admin login mislukt")
            
    except Exception as e:
        print(f"Fout bij data download: {e}")

def main():
    """Hoofdfunctie"""
    print("OFFICE WERKOMGEVING - WEBSITE TOOLS")
    print("=" * 50)
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    if len(sys.argv) > 1:
        if sys.argv[1] == "test":
            test_website_access()
        elif sys.argv[1] == "login":
            username = sys.argv[2] if len(sys.argv) > 2 else os.environ.get('DEFAULT_TEST_USERNAME', 'testuser')
            password = sys.argv[3] if len(sys.argv) > 3 else os.environ.get('DEFAULT_TEST_PASSWORD', 'password123')
            test_login(username, password)
        elif sys.argv[1] == "download":
            download_user_data()
        else:
            print("Gebruik: python3 website_tool.py [test|login|download]")
    else:
        # Standaard: voer alle tests uit
        test_website_access()
        test_login("testuser")
        test_login("admin")
        download_user_data()

if __name__ == "__main__":
    main()
