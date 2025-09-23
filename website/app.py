from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
import bcrypt
import os
from datetime import datetime

app = Flask(__name__)
app.secret_key = os.environ.get('FLASK_SECRET_KEY', 'your-secret-key-here-change-in-production')

# Database configuratie
DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'database'),
    'database': os.environ.get('DB_NAME', 'webapp_db'),
    'user': os.environ.get('DB_USER', 'webapp_user'),
    'password': os.environ.get('DB_PASSWORD', 'secure_password123'),
    'charset': 'utf8mb4'
}

def get_db_connection():
    """Maak verbinding met de database"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except mysql.connector.Error as err:
        print(f"Database connection error: {err}")
        return None

def verify_password(password, hashed):
    """Verifieer wachtwoord tegen hash"""
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

def hash_password(password):
    """Hash een wachtwoord"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

@app.route('/')
def index():
    """Homepage"""
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Login pagina"""
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        if not username or not password:
            flash('Gebruikersnaam en wachtwoord zijn verplicht', 'error')
            return render_template('login.html')
        
        # Verbind met database
        conn = get_db_connection()
        if not conn:
            flash('Database verbinding mislukt', 'error')
            return render_template('login.html')
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute(
                "SELECT id, username, password_hash, is_active FROM users WHERE username = %s",
                (username,)
            )
            user = cursor.fetchone()
            
            if user and user['is_active'] and verify_password(password, user['password_hash']):
                # Login succesvol
                session['user_id'] = user['id']
                session['username'] = user['username']
                
                # Log de login
                cursor.execute(
                    "UPDATE users SET last_login = %s WHERE id = %s",
                    (datetime.now(), user['id'])
                )
                
                # Log login attempt
                cursor.execute(
                    "INSERT INTO login_logs (user_id, ip_address, user_agent, success) VALUES (%s, %s, %s, %s)",
                    (user['id'], request.remote_addr, request.headers.get('User-Agent', ''), True)
                )
                
                conn.commit()
                flash(f'Welkom, {username}!', 'success')
                return redirect(url_for('dashboard'))
            else:
                # Login mislukt
                if user:
                    cursor.execute(
                        "INSERT INTO login_logs (user_id, ip_address, user_agent, success) VALUES (%s, %s, %s, %s)",
                        (user['id'], request.remote_addr, request.headers.get('User-Agent', ''), False)
                    )
                    conn.commit()
                
                flash('Ongeldige gebruikersnaam of wachtwoord', 'error')
                
        except mysql.connector.Error as err:
            flash(f'Database fout: {err}', 'error')
        finally:
            conn.close()
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    """Logout"""
    session.clear()
    flash('Je bent uitgelogd', 'info')
    return redirect(url_for('index'))

@app.route('/dashboard')
def dashboard():
    """Dashboard voor ingelogde gebruikers"""
    if 'user_id' not in session:
        flash('Je moet inloggen om deze pagina te bekijken', 'error')
        return redirect(url_for('login'))
    
    # Haal gebruikersinformatie op
    conn = get_db_connection()
    user_info = None
    recent_logins = []
    
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            
            # Gebruikersinformatie
            cursor.execute(
                "SELECT username, email, created_at, last_login FROM users WHERE id = %s",
                (session['user_id'],)
            )
            user_info = cursor.fetchone()
            
            # Recente logins
            cursor.execute(
                "SELECT ip_address, login_time, success FROM login_logs WHERE user_id = %s ORDER BY login_time DESC LIMIT 5",
                (session['user_id'],)
            )
            recent_logins = cursor.fetchall()
            
        except mysql.connector.Error as err:
            flash(f'Database fout: {err}', 'error')
        finally:
            conn.close()
    
    return render_template('dashboard.html', user_info=user_info, recent_logins=recent_logins)

@app.route('/users')
def users():
    """Gebruikers overzicht (alleen voor admins)"""
    if 'user_id' not in session:
        flash('Je moet inloggen om deze pagina te bekijken', 'error')
        return redirect(url_for('login'))
    
    if session.get('username') != 'admin':
        flash('Toegang geweigerd - alleen voor administrators', 'error')
        return redirect(url_for('dashboard'))
    
    conn = get_db_connection()
    users_list = []
    
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute(
                "SELECT id, username, email, created_at, last_login, is_active FROM users ORDER BY created_at DESC"
            )
            users_list = cursor.fetchall()
            
        except mysql.connector.Error as err:
            flash(f'Database fout: {err}', 'error')
        finally:
            conn.close()
    
    return render_template('users.html', users_list=users_list)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
