#!/bin/bash

# 1. DEĞİŞKENLER VE AYARLAR
PROJECT_DIR="/opt/usom_entegrasyonu"
SERVICE_FILE="/etc/systemd/system/usom-fetcher.service"

echo "=========================================="
echo "🚀 GitHub Otomatik Yukleme Araci Basliyor"
echo "=========================================="

cd $PROJECT_DIR || exit

# 2. SERVİS DOSYASINI PROJE KLASÖRÜNE YEDEKLEME
# Kullanicilar systemd servis dosyasini da gorsun diye projeye kopyaliyoruz
if [ -f "$SERVICE_FILE" ]; then
    echo "[+] Systemd servis dosyasi projeye kopyalaniyor..."
    sudo cp $SERVICE_FILE $PROJECT_DIR/
    sudo chown $USER:$USER $PROJECT_DIR/usom-fetcher.service
fi

# 3. GIT KONTROLÜ VE İLK KURULUM
if [ ! -d ".git" ]; then
    echo "[+] Git deposu (repository) baslatiliyor..."
    git init
    
    # Kullanicidan GitHub depo linkini istiyoruz
    read -p "GitHub Depo URL'nizi girin (Orn: https://github.com/kullaniciadi/usom-feed.git): " REPO_URL
    git remote add origin $REPO_URL
fi

# 4. DOSYALARI EKLEME VE GÖNDERME
echo "[+] Dosyalar hazirlaniyor..."
git add fetch_usom.py README.md usom-fetcher.service

# Güncel tarih ile otomatik commit mesaji
COMMIT_MSG="Otomatik Guncelleme: $(date +'%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG"

echo "[+] GitHub'a gonderiliyor..."
# Ana dali main olarak ayarlayip gonderiyoruz
git branch -M main
git push -u origin main

echo "=========================================="
echo "✅ Islem Basarili! Proje GitHub'da."
echo "=========================================="
