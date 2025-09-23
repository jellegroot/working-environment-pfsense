-- Initialisatie script voor webapp database
-- Dit script wordt automatisch uitgevoerd bij het opstarten van de database

USE webapp_db;

-- Maak users tabel voor login validatie
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Voeg test gebruikers toe (wachtwoorden zijn gehashed)
-- Wachtwoord voor alle test users is: "password123"
INSERT INTO users (username, password_hash, email) VALUES
('admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/7Zf.3Hn1e', 'admin@example.com'),
('testuser', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/7Zf.3Hn1e', 'test@example.com'),
('user1', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/7Zf.3Hn1e', 'user1@example.com'),
('user2', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/7Zf.3Hn1e', 'user2@example.com');

-- Maak een tabel voor login logs (optioneel)
CREATE TABLE IF NOT EXISTS login_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Toon aangemaakte tabellen
SHOW TABLES;

-- Toon gebruikers
SELECT id, username, email, created_at, is_active FROM users;
