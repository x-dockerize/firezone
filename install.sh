#!/usr/bin/env bash
set -e

ENV_EXAMPLE=".env.example"
ENV_FILE=".env"

# --------------------------------------------------
# Kontroller
# --------------------------------------------------
if [ ! -f "$ENV_EXAMPLE" ]; then
  echo "❌ $ENV_EXAMPLE bulunamadı."
  exit 1
fi

if [ -f "$ENV_FILE" ]; then
  echo "⚠️  $ENV_FILE zaten mevcut."
  read -rp "Üzerine yazılsın mı? (y/N): " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
fi

cp "$ENV_EXAMPLE" "$ENV_FILE"
echo "✅ $ENV_EXAMPLE → $ENV_FILE kopyalandı"

# --------------------------------------------------
# Yardımcı Fonksiyonlar
# --------------------------------------------------
gen_password() {
  openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 12
}

gen_base64() {
  local bytes="$1"
  openssl rand -base64 "$bytes" | tr -d '\n'
}

gen_hex() {
  openssl rand -hex 32
}

gen_db_encryption_key() {
  openssl rand -base64 32 | tr -d '\n'
}

set_env () {
  local key="$1"
  local value="$2"
  sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
}

# --------------------------------------------------
# Kullanıcıdan Gerekli Bilgiler
# --------------------------------------------------
read -rp "FIREZONE_SERVER_HOSTNAME (örn: vpn.example.com): " FIREZONE_SERVER_HOSTNAME
read -rp "DEFAULT_ADMIN_EMAIL: " DEFAULT_ADMIN_EMAIL

EXTERNAL_URL="https://${FIREZONE_SERVER_HOSTNAME}"

# --------------------------------------------------
# Admin Şifresi (Sor / Üret)
# --------------------------------------------------
read -rsp "DEFAULT_ADMIN_PASSWORD (boş bırakılırsa otomatik oluşturulur): " INPUT_PASSWORD
echo

if [ -z "$INPUT_PASSWORD" ]; then
  DEFAULT_ADMIN_PASSWORD=$(gen_password)
  echo "🔐 Otomatik oluşturulan admin şifresi: $DEFAULT_ADMIN_PASSWORD"
else
  DEFAULT_ADMIN_PASSWORD="$INPUT_PASSWORD"
fi

# --------------------------------------------------
# .env Dosyasını Güncelle
# --------------------------------------------------
set_env FIREZONE_SERVER_HOSTNAME "$FIREZONE_SERVER_HOSTNAME"
set_env EXTERNAL_URL "$EXTERNAL_URL"

set_env DEFAULT_ADMIN_EMAIL "$DEFAULT_ADMIN_EMAIL"
set_env DEFAULT_ADMIN_PASSWORD "$DEFAULT_ADMIN_PASSWORD"

set_env GUARDIAN_SECRET_KEY "$(gen_base64 64)"
set_env SECRET_KEY_BASE "$(gen_base64 64)"
set_env LIVE_VIEW_SIGNING_SALT "$(gen_base64 32)"
set_env COOKIE_SIGNING_SALT "$(gen_base64 8)"
set_env COOKIE_ENCRYPTION_SALT "$(gen_base64 8)"

set_env DATABASE_PASSWORD "$(gen_base64 64)"
set_env DATABASE_ENCRYPTION_KEY "$(gen_db_encryption_key)"

# --------------------------------------------------
# Sonuçları Göster
# --------------------------------------------------
echo
echo "==============================================="
echo "🎉 Firezone .env Başarıyla Oluşturuldu!"
echo "-----------------------------------------------"
echo "🌐 EXTERNAL_URL        : $EXTERNAL_URL"
echo "👤 Admin Email         : $DEFAULT_ADMIN_EMAIL"
echo "🔑 Admin Şifresi       : $DEFAULT_ADMIN_PASSWORD"
echo "-----------------------------------------------"
echo "⚠️  Admin şifresini güvenli bir yerde saklayın!"
echo "==============================================="
