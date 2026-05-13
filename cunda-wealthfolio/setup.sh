#!/bin/bash
cd "$(dirname "$0")"

echo "=== Wealthfolio - First Time Setup ==="
echo "This script only needs to be run once."

if [ -f ".env" ]; then
  echo "✅ Configuration already exists."
  echo "If you want to change your password, delete the .env file and run this script again."
  cat .env
  exit 0
fi

echo -e "\nGenerating Secret Key..."
SECRET=$(openssl rand -base64 32)
echo "WF_SECRET_KEY=$SECRET" > .env

echo -e "\nEnter the password you want to use for Wealthfolio:"
read -s PASSWORD
echo ""

SALT="CundaUmbrelSalt2026"
HASH=$(printf '%s' "$PASSWORD" | argon2 "$SALT" -id -e)

echo "WF_AUTH_PASSWORD_HASH='$HASH'" >> .env

echo -e "\n✅ Setup completed successfully!"
echo "Please restart Wealthfolio from the Umbrel interface."
echo "You will be able to log in with the password you just chose."
