#!/usr/bin/env python3
"""
Database Data Extractor voor Office Werkomgeving
Haalt gegevens op uit de SQL database en exporteert naar Excel
"""

import mysql.connector
import pandas as pd
import os
from datetime import datetime
import sys

# Database configuratie
DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'database'),
    'database': os.environ.get('DB_NAME', 'webapp_db'),
    'user': os.environ.get('DB_USER', 'webapp_user'),
    'password': os.environ.get('DB_PASSWORD', 'secure_password123'),
    'charset': 'utf8mb4'
}

def connect_to_database():
    """Maak verbinding met de database"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        print(f"Verbonden met database: {DB_CONFIG['database']}")
        return connection
    except mysql.connector.Error as err:
        print(f"Database verbinding mislukt: {err}")
        return None

def export_users_to_excel(output_dir="/home/office/Documents/Reports"):
    """Exporteer gebruikersgegevens naar Excel"""
    conn = connect_to_database()
    if not conn:
        return False
    
    try:
        # Haal gebruikers op
        users_query = """
        SELECT 
            id,
            username,
            email,
            created_at,
            last_login,
            is_active
        FROM users 
        ORDER BY created_at DESC
        """
        users_df = pd.read_sql(users_query, conn)
        
        # Haal login logs op
        logs_query = """
        SELECT 
            ll.id,
            u.username,
            ll.ip_address,
            ll.login_time,
            ll.success,
            ll.user_agent
        FROM login_logs ll
        JOIN users u ON ll.user_id = u.id
        ORDER BY ll.login_time DESC
        LIMIT 100
        """
        logs_df = pd.read_sql(logs_query, conn)
        
        # Maak output directory
        os.makedirs(output_dir, exist_ok=True)
        
        # Genereer bestandsnaam met timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"database_report_{timestamp}.xlsx"
        filepath = os.path.join(output_dir, filename)
        
        # Schrijf naar Excel met meerdere sheets
        with pd.ExcelWriter(filepath, engine='xlsxwriter') as writer:
            # Users sheet
            users_df.to_excel(writer, sheet_name='Gebruikers', index=False)
            
            # Login logs sheet
            logs_df.to_excel(writer, sheet_name='Login_Logs', index=False)
            
            # Summary sheet
            summary_data = {
                'Statistiek': [
                    'Totaal Gebruikers',
                    'Actieve Gebruikers', 
                    'Inactieve Gebruikers',
                    'Totaal Login Pogingen',
                    'Succesvolle Logins',
                    'Mislukte Logins',
                    'Laatste Export'
                ],
                'Waarde': [
                    len(users_df),
                    len(users_df[users_df['is_active'] == 1]),
                    len(users_df[users_df['is_active'] == 0]),
                    len(logs_df),
                    len(logs_df[logs_df['success'] == 1]),
                    len(logs_df[logs_df['success'] == 0]),
                    datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                ]
            }
            summary_df = pd.DataFrame(summary_data)
            summary_df.to_excel(writer, sheet_name='Samenvatting', index=False)
            
            # Opmaak toevoegen
            workbook = writer.book
            header_format = workbook.add_format({
                'bold': True,
                'text_wrap': True,
                'valign': 'top',
                'fg_color': '#D7E4BC',
                'border': 1
            })
            
            # Headers opmaken
            for sheet_name in ['Gebruikers', 'Login_Logs', 'Samenvatting']:
                worksheet = writer.sheets[sheet_name]
                for col_num, value in enumerate(locals()[f"{sheet_name.lower().replace('_', '_')}_df" if sheet_name != 'Samenvatting' else 'summary_df'].columns.values):
                    worksheet.write(0, col_num, value, header_format)
        
        print(f"Excel rapport gegenereerd: {filepath}")
        return filepath
        
    except Exception as e:
        print(f"Fout bij Excel export: {e}")
        return False
    finally:
        conn.close()

def generate_user_statistics():
    """Genereer gebruikersstatistieken"""
    conn = connect_to_database()
    if not conn:
        return
    
    try:
        cursor = conn.cursor(dictionary=True)
        
        # Basis statistieken
        cursor.execute("SELECT COUNT(*) as total FROM users")
        total_users = cursor.fetchone()['total']
        
        cursor.execute("SELECT COUNT(*) as active FROM users WHERE is_active = 1")
        active_users = cursor.fetchone()['active']
        
        cursor.execute("SELECT COUNT(*) as total_logins FROM login_logs")
        total_logins = cursor.fetchone()['total_logins']
        
        cursor.execute("SELECT COUNT(*) as successful FROM login_logs WHERE success = 1")
        successful_logins = cursor.fetchone()['successful']
        
        # Recente activiteit
        cursor.execute("""
            SELECT u.username, ll.login_time 
            FROM login_logs ll 
            JOIN users u ON ll.user_id = u.id 
            WHERE ll.success = 1 
            ORDER BY ll.login_time DESC 
            LIMIT 5
        """)
        recent_logins = cursor.fetchall()
        
        print("\n DATABASE STATISTIEKEN")
        print("=" * 40)
        print(f"Totaal gebruikers: {total_users}")
        print(f"Actieve gebruikers: {active_users}")
        print(f"Totaal login pogingen: {total_logins}")
        print(f"Succesvolle logins: {successful_logins}")
        print(f"Mislukte logins: {total_logins - successful_logins}")
        
        print("\n RECENTE LOGIN ACTIVITEIT:")
        print("-" * 40)
        for login in recent_logins:
            print(f"• {login['username']}: {login['login_time']}")
        
    except Exception as e:
        print(f" Fout bij statistieken: {e}")
    finally:
        conn.close()

def main():
    """Hoofdfunctie"""
    print(" OFFICE WERKOMGEVING - DATABASE TOOLS")
    print("=" * 50)
    
    if len(sys.argv) > 1:
        if sys.argv[1] == "excel":
            export_users_to_excel()
        elif sys.argv[1] == "stats":
            generate_user_statistics()
        else:
            print("Gebruik: python3 db_extractor.py [excel|stats]")
    else:
        # Standaard: toon statistieken en maak Excel
        generate_user_statistics()
        print("\n Genereren Excel rapport...")
        export_users_to_excel()

if __name__ == "__main__":
    main()
