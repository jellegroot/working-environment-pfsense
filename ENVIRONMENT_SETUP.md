# Environment Configuration Guide

## Setting up Environment Variables

This project uses a `.env` file to manage all credentials and configuration settings securely. Follow these steps to set up your environment:

### 1. Copy the Example File

```bash
cp .env.example .env
```

### 2. Update Credentials

Edit the `.env` file and replace all placeholder values with your actual credentials:

```bash
# Replace these example values with secure passwords
MYSQL_ROOT_PASSWORD=your_mysql_root_password_here
MYSQL_PASSWORD=your_mysql_user_password_here
FLASK_SECRET_KEY=your_flask_secret_key_here
# ... and so on for all variables
```

### 3. Security Considerations

⚠️ **Important Security Notes:**

- **Never commit the `.env` file to version control** (it's already in `.gitignore`)
- **Use strong, unique passwords** for all services
- **Change default passwords** before deploying to production
- **Rotate credentials regularly** in production environments
- **Limit file permissions**: `chmod 600 .env`

### 4. Required Variables

The following environment variables are **required** for the system to function:

#### Database Configuration
- `MYSQL_ROOT_PASSWORD` - MySQL root user password
- `MYSQL_PASSWORD` - Application database user password
- `DB_PASSWORD` - Same as MYSQL_PASSWORD (used by applications)

#### Application Security
- `FLASK_SECRET_KEY` - Used for session encryption and CSRF protection
- `DEFAULT_ADMIN_PASSWORD` - Initial admin user password
- `DEFAULT_TEST_PASSWORD` - Test user password

#### System Access
- `SSH_ROOT_PASSWORD` - SSH access to containers
- `PFSENSE_ADMIN_PASSWORD` - pfSense router admin password
- `VNC_PASSWORD` - VNC access to office environment
- `RDP_PASSWORD` - RDP access to office environment

### 5. Password Requirements

For production use, ensure passwords meet these minimum requirements:
- At least 12 characters long
- Mix of uppercase, lowercase, numbers, and special characters
- No dictionary words or common patterns
- Unique across all services

### 6. Environment-Specific Configuration

You can create different environment files for different deployments:

```bash
.env.development    # Local development
.env.staging        # Staging environment  
.env.production     # Production deployment
```

Use Docker Compose's `--env-file` flag to specify which file to use:

```bash
docker-compose --env-file .env.production up -d
```

### 7. Verification

After setting up your `.env` file, you can verify the configuration by checking:

```bash
# Check if environment variables are loaded
docker-compose config

# Test database connection
docker-compose exec webserver python3 -c "
import os
print('DB Host:', os.environ.get('DB_HOST'))
print('DB User:', os.environ.get('DB_USER'))
print('DB Name:', os.environ.get('DB_NAME'))
print('Flask Secret Key length:', len(os.environ.get('FLASK_SECRET_KEY', '')))
"
```

### 8. Troubleshooting

If you encounter issues:

1. **Check file permissions**: `ls -la .env` (should be readable by user)
2. **Verify syntax**: No spaces around `=` in variable definitions
3. **Quote special characters**: Use quotes for values with spaces or special chars
4. **Restart containers**: `docker-compose down && docker-compose up -d`

### 9. Backup and Recovery

- **Backup your `.env` file** securely (encrypted storage)
- **Document your credential management process**
- **Have a recovery plan** for credential rotation

---

**Need help?** Check the main README.md for deployment instructions or contact your system administrator.