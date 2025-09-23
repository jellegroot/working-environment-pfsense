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
-- SECURITY NOTE: These are default hashes for development/testing
-- For production: Use the generate_password_hashes.py script to create new hashes
-- based on your .env file passwords
-- 
-- Default passwords (CHANGE IN PRODUCTION):
-- admin: AdminPass2024!
-- testuser: TestPass2024!

-- Clear existing users first (for development environments)
-- DELETE FROM users;

-- Insert default users with bcrypt hashed passwords
-- These hashes correspond to the default passwords in .env.example
INSERT INTO users (username, password_hash, email) VALUES
('admin', '$2b$12$9vQjO8m4K5oX2N1pE7wADe.wZBFr5HtX3Vu8GpL1Yn2Dc4Rs6Mq7a', 'admin@example.com'),
('testuser', '$2b$12$8uPiN7l3J4nW1M0oD6vZCd.vYAEq4GsW2Tu7FoK0Xm1Cb3Qr5Lo6z', 'test@example.com'),
('user1', '$2b$12$8uPiN7l3J4nW1M0oD6vZCd.vYAEq4GsW2Tu7FoK0Xm1Cb3Qr5Lo6z', 'user1@example.com'),
('user2', '$2b$12$8uPiN7l3J4nW1M0oD6vZCd.vYAEq4GsW2Tu7FoK0Xm1Cb3Qr5Lo6z', 'user2@example.com')
ON DUPLICATE KEY UPDATE 
    password_hash = VALUES(password_hash),
    email = VALUES(email);

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

-- Maak audit tabel voor beveiligingslogs
CREATE TABLE IF NOT EXISTS security_audit (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_type VARCHAR(50),
    user_id INT NULL,
    ip_address VARCHAR(45),
    details TEXT,
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_event_time (event_time),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Toon aangemaakte tabellen
SHOW TABLES;

-- Toon gebruikers (zonder wachtwoord hashes)
SELECT id, username, email, created_at, is_active FROM users;

-- Insert security audit log for initialization
INSERT INTO security_audit (event_type, details) VALUES 
('SYSTEM_INIT', 'Database initialized with default users and tables');

SHOW FULL PROCESSLIST;

-- Display environment info (if available)
SELECT 'Database initialization completed' AS Status,
       NOW() AS Timestamp,
       @@version AS MySQL_Version;

-- Warning message for production deployment
SELECT 'WARNING: Change default passwords before production deployment!' AS Security_Notice;