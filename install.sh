#!/bin/bash

echo "====================================================="
echo "🛡️ USOM Threat Intelligence - Otomatik Kurulum Araci"
echo "====================================================="

if [ "$EUID" -ne 0 ]; then
  echo "❌ HATA: Bu kurulum sistem ayarlari yapacagi icin 'sudo' ile calistirilmalidir."
  echo "👉 Kullanim: sudo ./install.sh"
  exit 1
fi

if [ ! -f "fetch_usom.py" ] || [ ! -f "usom-fetcher.service" ]; then
  echo "❌ HATA: Gerekli proje dosyalari (fetch_usom.py veya usom-fetcher.service) bulunamadi!"
  echo "Lutfen bu betigi GitHub'dan indirdiginiz klasorun icinde calistirin."
  exit 1
fi

echo "[+] 1/4: Sistem paketleri guncelleniyor ve gerekli araclar kuruluyor..."
apt-get update -qq
apt-get install -y -qq nginx python3 python3-requests

echo "[+] 2/4: Proje klasor yapisi (/opt/usom_entegrasyonu) olusturuluyor..."
TARGET_DIR="/opt/usom_entegrasyonu"

mkdir -p "$TARGET_DIR"

cp fetch_usom.py "$TARGET_DIR/"

chmod +x "$TARGET_DIR/fetch_usom.py"

mkdir -p /var/www/html
chmod 755 /var/www/html

echo "[+] 3/4: Systemd servisi (usom-fetcher) kuruluyor..."
cp usom-fetcher.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable usom-fetcher.service

echo "[+] 4/4: Servis baslatiliyor..."
systemctl restart usom-fetcher.service

echo "====================================================="
echo "✅ KURULUM BASARIYLA TAMAMLANDI!"
echo "====================================================="
echo "👉 Canli loglari izlemek icin: sudo journalctl -u usom-fetcher.service -f"
echo "👉 Yayin adresi: http://$(hostname -I | awk '{print $1}')/usom.txt" 
echo "👉 Tarama tamamlanmadan usom.txt dosyası oluşmaz. (Internet Hızınına bağlı bir süre bekleyiniz.)" 
