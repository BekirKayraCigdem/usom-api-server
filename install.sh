#!/bin/bash

echo "====================================================="
echo "🛡️ USOM Threat Intelligence - Otomatik Kurulum Araci"
echo "====================================================="

# 1. ROOT (YÖNETİCİ) KONTROLÜ (Savunmacı Programlama)
# Sistem paketleri yükleneceği ve servis oluşturulacağı için root olmak şarttır.
if [ "$EUID" -ne 0 ]; then
  echo "❌ HATA: Bu kurulum sistem ayarlari yapacagi icin 'sudo' ile calistirilmalidir."
  echo "👉 Kullanim: sudo ./install.sh"
  exit 1
fi

# 2. DOSYA KONTROLÜ
# Kullanıcının doğru klasörde olup olmadığını kontrol ediyoruz.
if [ ! -f "fetch_usom.py" ] || [ ! -f "usom-fetcher.service" ]; then
  echo "❌ HATA: Gerekli proje dosyalari (fetch_usom.py veya usom-fetcher.service) bulunamadi!"
  echo "Lutfen bu betigi GitHub'dan indirdiginiz klasorun icinde calistirin."
  exit 1
fi

# 3. BAĞIMLILIKLARIN KURULUMU
echo "[+] 1/4: Sistem paketleri guncelleniyor ve gerekli araclar kuruluyor..."
# Kullanıcıya soru sormadan (-y) arka planda sessizce (-qq) kurulum yapıyoruz.
apt-get update -qq
apt-get install -y -qq nginx python3 python3-requests

# 4. KLASÖR YAPISI VE DOSYALARIN TAŞINMASI
echo "[+] 2/4: Proje klasor yapisi (/opt/usom_entegrasyonu) olusturuluyor..."
TARGET_DIR="/opt/usom_entegrasyonu"

# Klasör yoksa oluşturuyoruz
mkdir -p "$TARGET_DIR"

# Python kodumuzu sistemin güvenli çalışma alanına kopyalıyoruz
cp fetch_usom.py "$TARGET_DIR/"

# Dosyaya çalışma (executable) yetkisi veriyoruz ki Linux onu çalıştırabilsin
chmod +x "$TARGET_DIR/fetch_usom.py"

# Nginx'in yayın yapacağı klasörün var olduğundan emin oluyoruz
mkdir -p /var/www/html
chmod 755 /var/www/html

# 5. LİNUX SERVİSİNİN (DAEMON) KURULUMU
echo "[+] 3/4: Systemd servisi (usom-fetcher) kuruluyor..."
cp usom-fetcher.service /etc/systemd/system/

# Systemd'ye yeni dosyayı tanıtıp, sunucu her açıldığında otomatik başlamasını sağlıyoruz
systemctl daemon-reload
systemctl enable usom-fetcher.service

# Servisi anında ayağa kaldırıyoruz
echo "[+] 4/4: Servis baslatiliyor..."
systemctl restart usom-fetcher.service

echo "====================================================="
echo "✅ KURULUM BASARIYLA TAMAMLANDI!"
echo "====================================================="
echo "👉 Canli loglari izlemek icin: sudo journalctl -u usom-fetcher.service -f"
echo "👉 Yayin adresi: http://$(hostname -I | awk '{print $1}')/usom.txt" 
echo "👉 Tarama tamamlanmadan usom.txt dosyası oluşmaz. (Internet Hızınına bağlı bir süre bekleyiniz.)" 
