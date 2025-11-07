#!/bin/bash

################################################################################
# Ory Kratos Complete Installation Script (Auto-IP + Custom Schema)
# Usage: sudo bash kratos_install.sh
################################################################################

set -e

# Dynamic Configuration
DOMAIN="kratos.upsure.io"
INTERNAL_IP=$(hostname -I | awk '{print $1}')
EXTERNAL_IP=$(curl -s ifconfig.me || curl -s http://checkip.amazonaws.com)

# Prefer domain if resolvable
if host "$DOMAIN" >/dev/null 2>&1; then
    BASE_URL="https://${DOMAIN}"
    echo "Using domain: ${BASE_URL}"
else
    BASE_URL="http://${EXTERNAL_IP}"
    echo "Using external IP: ${BASE_URL}"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================="
echo "   Ory Kratos Installation Script"
echo "=============================================="
echo ""
echo "Internal IP: $INTERNAL_IP"
echo "External IP: $EXTERNAL_IP"
echo "Base URL: $BASE_URL"
echo ""
echo "This script will:"
echo "  1. Clean existing installation"
echo "  2. Install PostgreSQL"
echo "  3. Install Ory Kratos"
echo "  4. Configure and start the service"
echo ""
echo "=============================================="
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}ERROR: Please run with sudo${NC}"
    exit 1
fi

# Step 1: Cleanup
echo -e "${YELLOW}[1/15] Cleaning existing installation...${NC}"
systemctl stop kratos 2>/dev/null || true
systemctl disable kratos 2>/dev/null || true
rm -f /etc/systemd/system/kratos.service
systemctl daemon-reload
rm -f /usr/local/bin/kratos
rm -rf /etc/kratos
sudo -u postgres psql -c "DROP DATABASE IF EXISTS kratos;" 2>/dev/null || true
sudo -u postgres psql -c "DROP USER IF EXISTS kratouser;" 2>/dev/null || true
echo -e "${GREEN}✓ Cleanup complete${NC}"

# Step 2: Update System
echo -e "${YELLOW}[2/15] Updating system...${NC}"
apt update -qq
echo -e "${GREEN}✓ System updated${NC}"

# Step 3: Install PostgreSQL
echo -e "${YELLOW}[3/15] Installing PostgreSQL...${NC}"
apt install -y postgresql postgresql-contrib curl wget >/dev/null 2>&1
echo -e "${GREEN}✓ PostgreSQL installed${NC}"

# Step 4: Start PostgreSQL
echo -e "${YELLOW}[4/15] Starting PostgreSQL...${NC}"
systemctl start postgresql
systemctl enable postgresql >/dev/null 2>&1
sleep 3
echo -e "${GREEN}✓ PostgreSQL started${NC}"

# Step 5: Create Database
echo -e "${YELLOW}[5/15] Creating database...${NC}"
DB_PASSWORD=$(openssl rand -base64 18 | tr -dc 'A-Za-z0-9' | head -c 20)

sudo -u postgres psql >/dev/null 2>&1 << EOF
CREATE DATABASE kratos;
CREATE USER kratouser WITH ENCRYPTED PASSWORD '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE kratos TO kratouser;
ALTER DATABASE kratos OWNER TO kratouser;
EOF

echo -e "${GREEN}✓ Database created${NC}"

# Step 6: Install Kratos
echo -e "${YELLOW}[6/15] Installing Ory Kratos...${NC}"
curl -sSL https://raw.githubusercontent.com/ory/meta/master/install.sh | bash -s -- -b /tmp kratos >/dev/null 2>&1
mv /tmp/kratos /usr/local/bin/
chmod +x /usr/local/bin/kratos
echo -e "${GREEN}✓ Kratos installed${NC}"
kratos version

# Step 7: Directories
mkdir -p /etc/kratos
echo -e "${GREEN}✓ Directories ready${NC}"

# Step 8: Secrets
COOKIE_SECRET=$(openssl rand -hex 16)
CIPHER_SECRET=$(openssl rand -hex 16)
echo -e "${GREEN}✓ Secrets generated${NC}"

# Step 9: Configuration
echo -e "${YELLOW}[9/15] Creating configuration...${NC}"
cat > /etc/kratos/kratos.yml << EOF
version: v0.11.1

dsn: postgres://kratouser:${DB_PASSWORD}@localhost:5432/kratos?sslmode=disable&max_conns=20&max_idle_conns=4

serve:
  public:
    base_url: ${BASE_URL}:4433/
    cors:
      enabled: true
      allowed_origins:
        - ${BASE_URL}:4455
        - ${BASE_URL}
        - http://localhost:4455
      allowed_methods: [POST, GET, PUT, PATCH, DELETE, OPTIONS]
      allowed_headers: [Authorization, Content-Type, Cookie]
      exposed_headers: [Content-Type, Set-Cookie]
      allow_credentials: true
    host: 0.0.0.0
    port: 4433
  admin:
    base_url: http://${INTERNAL_IP}:4434/
    host: 0.0.0.0
    port: 4434

selfservice:
  default_browser_return_url: ${BASE_URL}:4455/
  allowed_return_urls:
    - ${BASE_URL}:4455
    - ${BASE_URL}

  methods:
    password:
      enabled: true
      config:
        haveibeenpwned_enabled: false
        min_password_length: 8

  flows:
    error:
      ui_url: ${BASE_URL}:4455/error
    settings:
      ui_url: ${BASE_URL}:4455/settings
      privileged_session_max_age: 15m
    recovery:
      enabled: true
      ui_url: ${BASE_URL}:4455/recovery
      use: code
    verification:
      enabled: true
      ui_url: ${BASE_URL}:4455/verification
      use: code
    logout:
      after:
        default_browser_return_url: ${BASE_URL}:4455/login
    login:
      ui_url: ${BASE_URL}:4455/login
      lifespan: 10m
    registration:
      lifespan: 10m
      ui_url: ${BASE_URL}:4455/registration
      after:
        password:
          hooks:
            - hook: session

session:
  lifespan: 720h

log:
  level: info
  format: json

secrets:
  cookie:
    - ${COOKIE_SECRET}
  cipher:
    - ${CIPHER_SECRET}

ciphers:
  algorithm: xchacha20-poly1305

hashers:
  algorithm: bcrypt
  bcrypt:
    cost: 12

identity:
  default_schema_id: default
  schemas:
    - id: default
      url: file:///etc/kratos/identity.schema.json

courier:
  smtp:
    connection_uri: smtp://test:test@mailslurper:1025/?skip_ssl_verify=true
EOF

echo -e "${GREEN}✓ Configuration created${NC}"

# Step 10: Custom Schema
echo -e "${YELLOW}[10/15] Creating identity schema...${NC}"
cat > /etc/kratos/identity.schema.json << 'EOF'
{
  "$id": "https://example.io/schemas/default",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Person",
  "type": "object",
  "properties": {
    "traits": {
      "type": "object",
      "properties": {
        "userName": {
          "type": "string",
          "title": "User Name",
          "minLength": 2
        },
        "email": {
          "type": "string",
          "format": "email",
          "title": "E-Mail",
          "minLength": 3,
          "ory.sh/kratos": {
            "credentials": {
              "password": {
                "identifier": true
              }
            },
            "verification": {
              "via": "email"
            },
            "recovery": {
              "via": "email"
            }
          }
        },
        "mobile": {
          "type": "string",
          "pattern": "^[0-9]{10}$",
          "title": "Mobile Number"
        },
        "otp": {
          "type": "string",
          "enum": ["123456"],
          "title": "Static OTP (for testing)"
        }
      },
      "required": ["userName", "email", "mobile", "otp"],
      "additionalProperties": false
    }
  }
}
EOF
echo -e "${GREEN}✓ Custom identity schema created${NC}"

# Step 11: DB Migrations
cd /etc/kratos
kratos migrate sql -e --yes --config /etc/kratos/kratos.yml
echo -e "${GREEN}✓ Database migrations complete${NC}"

# Step 12: Systemd Service
cat > /etc/systemd/system/kratos.service << 'EOF'
[Unit]
Description=Ory Kratos Identity Server
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=root
WorkingDirectory=/etc/kratos
ExecStart=/usr/local/bin/kratos serve --config /etc/kratos/kratos.yml
Restart=always
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kratos >/dev/null 2>&1
systemctl start kratos
sleep 5

# Step 13: Firewall
if command -v ufw &> /dev/null; then
    ufw allow 4433/tcp comment 'Kratos Public' >/dev/null 2>&1
    ufw allow 4434/tcp comment 'Kratos Admin' >/dev/null 2>&1
    ufw allow 4455/tcp comment 'Kratos UI' >/dev/null 2>&1
fi

# Step 14: Verify
echo -e "${YELLOW}[15/15] Verifying installation...${NC}"
if systemctl is-active --quiet kratos; then
    echo -e "${GREEN}✓ Kratos service is running${NC}"
else
    echo -e "${RED}✗ Kratos service failed${NC}"
    journalctl -u kratos -n 30 --no-pager
    exit 1
fi

# Step 15: Save Credentials
cat > /etc/kratos/credentials.txt << EOF
============================================
Ory Kratos Installation Credentials
============================================
Internal IP: ${INTERNAL_IP}
External IP: ${EXTERNAL_IP}
Domain: ${DOMAIN}

Database: kratos
User: kratouser
Pass: ${DB_PASSWORD}

Cookie Secret: ${COOKIE_SECRET}
Cipher Secret: ${CIPHER_SECRET}

Public API:  ${BASE_URL}:4433
Admin API:   http://${INTERNAL_IP}:4434
============================================
EOF
chmod 600 /etc/kratos/credentials.txt

echo -e "${GREEN}Installation Complete!${NC}"
echo "Public API: ${BASE_URL}:4433"
echo "Admin API: http://${INTERNAL_IP}:4434"
echo "Credentials saved: /etc/kratos/credentials.txt"
