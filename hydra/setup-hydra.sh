#!/bin/bash
# ============================================================
# ORY Hydra OAuth2 Server - Full Auto Setup (No Docker Compose)
# ============================================================

set -e

echo "================================================"
echo "ORY Hydra OAuth2 Server Setup (No Docker Compose)"
echo "================================================"

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker not installed. Please install Docker first."
    exit 1
fi

# --- Configuration ---
DOMAIN="hydra.test.io"
USE_DOMAIN=false

# Detect IP
if host $DOMAIN &> /dev/null; then
    BASE_URL="https://$DOMAIN"
    USE_DOMAIN=true
    echo "Using domain: $DOMAIN"
else
    EXTERNAL_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || echo "localhost")
    BASE_URL="http://$EXTERNAL_IP"
    echo "Detected external IP: $EXTERNAL_IP"
fi

# Generate secrets
SYSTEM_SECRET=$(openssl rand -hex 32)
COOKIE_SECRET=$(openssl rand -hex 16)

# Clean up old containers
echo ""
echo "Cleaning up old Hydra containers..."
docker rm -f hydra hydra-migrate hydra-postgres hydra-consent 2>/dev/null || true

# Create Docker network
NETWORK_NAME="hydra-network"
docker network create $NETWORK_NAME 2>/dev/null || true

# --- Start PostgreSQL ---
echo ""
echo "Starting PostgreSQL..."
docker run -d \
  --name hydra-postgres \
  --network $NETWORK_NAME \
  -e POSTGRES_USER=hydra \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=hydra \
  -v hydra_postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:15-alpine

# --- Run Hydra DB Migration ---
echo ""
echo "Running Hydra migrations..."
docker run --rm \
  --name hydra-migrate \
  --network $NETWORK_NAME \
  -e DSN=postgres://hydra:secret@hydra-postgres:5432/hydra?sslmode=disable \
  oryd/hydra:v2.2.0 migrate sql -e --yes

# --- Start Hydra Server ---
echo ""
echo "Starting Hydra Server..."
docker run -d \
  --name hydra \
  --network $NETWORK_NAME \
  -p 4444:4444 \
  -p 4445:4445 \
  -e DSN=postgres://hydra:secret@hydra-postgres:5432/hydra?sslmode=disable \
  -e SECRETS_SYSTEM=$SYSTEM_SECRET \
  -e SECRETS_COOKIE=$COOKIE_SECRET \
  -e URLS_SELF_ISSUER=$BASE_URL:4444/ \
  -e URLS_CONSENT=$BASE_URL:3000/consent \
  -e URLS_LOGIN=$BASE_URL:3000/login \
  -e URLS_LOGOUT=$BASE_URL:3000/logout \
  -e SERVE_COOKIES_SAME_SITE_MODE=Lax \
  -e LOG_LEVEL=debug \
  -e LOG_LEAK_SENSITIVE_VALUES=true \
  --restart unless-stopped \
  oryd/hydra:v2.2.0 serve all --dev

# --- Start Consent/Login App ---
echo ""
echo "Starting Hydra Login/Consent UI..."
docker run -d \
  --name hydra-consent \
  --network $NETWORK_NAME \
  -p 3000:3000 \
  -e HYDRA_ADMIN_URL=http://hydra:4445 \
  -e NODE_TLS_REJECT_UNAUTHORIZED=0 \
  --restart unless-stopped \
  oryd/hydra-login-consent-node:v2.2.0

# --- Wait and Create Client ---
echo ""
echo "Waiting for Hydra to be ready..."
sleep 25

echo ""
echo "Creating sample OAuth2 client..."
docker exec -i hydra \
  hydra create client \
  --endpoint http://localhost:4445 \
  --name "Sample Client" \
  --grant-type authorization_code,refresh_token,client_credentials \
  --response-type code,id_token \
  --scope openid,offline,profile,email \
  --redirect-uri $BASE_URL:5555/callback \
  --token-endpoint-auth-method client_secret_post || echo "Client creation may have failed."

# --- Summary ---
echo ""
echo "================================================"
echo "ORY HYDRA SETUP COMPLETE!"
echo "================================================"
echo ""
if [ "$USE_DOMAIN" = true ]; then
    echo "Domain: $DOMAIN"
else
    echo "External IP: $EXTERNAL_IP"
fi
echo ""
echo "Services running:"
echo "  - Hydra Public API: $BASE_URL:4444"
echo "  - Hydra Admin API:  $BASE_URL:4445"
echo "  - Login/Consent UI: $BASE_URL:3000"
echo "  - PostgreSQL:       localhost:5432"
echo ""
echo "Firewall ports to open:"
echo "  - 4444 (Hydra Public API)"
echo "  - 4445 (Hydra Admin API)"
echo "  - 3000 (Consent UI)"
echo ""
echo "Useful commands:"
echo "  - docker logs -f hydra"
echo "  - docker logs -f hydra-consent"
echo "  - docker logs -f hydra-postgres"
echo "  - docker exec -it hydra hydra list clients --endpoint http://localhost:4445"
echo ""
echo "================================================"
