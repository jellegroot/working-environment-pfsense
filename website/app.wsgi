#!/usr/bin/python3
import sys
import os

# Voeg het pad toe aan sys.path
sys.path.insert(0, '/var/www/webapp')

from app import app as application

if __name__ == "__main__":
    application.run()
