#!/usr/bin/env python3
"""
Password Hash Generator for Database Initialization
Generates bcrypt hashes for the default user passwords
"""

import bcrypt
import os

def generate_hash(password):
    """Generate bcrypt hash for a password"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def main():
    print("Password Hash Generator")
    print("=" * 30)
    
    # Get passwords from environment or use defaults
    admin_password = os.environ.get('DEFAULT_ADMIN_PASSWORD', 'AdminPass2024!')
    test_password = os.environ.get('DEFAULT_TEST_PASSWORD', 'TestPass2024!')
    
    # Generate hashes
    admin_hash = generate_hash(admin_password)
    test_hash = generate_hash(test_password)
    
    print(f"Admin password hash: {admin_hash}")
    print(f"Test user password hash: {test_hash}")
    
    # Generate SQL with the new hashes
    sql_template = f"""
-- Updated users with environment-based password hashes
-- Admin password: {admin_password}
-- Test password: {test_password}

INSERT INTO users (username, password_hash, email) VALUES
('admin', '{admin_hash}', 'admin@example.com'),
('testuser', '{test_hash}', 'test@example.com'),
('user1', '{test_hash}', 'user1@example.com'),
('user2', '{test_hash}', 'user2@example.com')
ON DUPLICATE KEY UPDATE 
    password_hash = VALUES(password_hash),
    email = VALUES(email);
"""
    
    print("\nGenerated SQL:")
    print(sql_template)
    
    # Write to file
    with open('/tmp/user_insert.sql', 'w') as f:
        f.write(sql_template)
    
    print("\nSQL written to /tmp/user_insert.sql")

if __name__ == "__main__":
    main()