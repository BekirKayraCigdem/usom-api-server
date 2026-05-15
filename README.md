# USOM Threat Intelligence Fetcher & Nginx Feeder

Bu proje, USOM (Ulusal Siber Olaylara Müdahale Merkezi) API'sinden güncel zararlı bağlantı (Domain/IP) listelerini otomatik olarak çeken, temizleyen ve kurumsal güvenlik duvarları (FortiGate, Palo Alto vb.) için "External Threat Feed" formatında Nginx üzerinden sunan bir otomasyon aracıdır.

## 🚀 Mimari Özellikler

*   **Sınırsız Dinamik Sayfalama (Pagination):** USOM veritabanındaki tüm sayfaları otomatik tarar. Sınır yoktur.
*   **Akıllı Veri Temizleme (IOC Cleaner):** Gelen karmaşık URL'leri (`http://zararli.com/virus.exe`) analiz eder, klasör yollarını silerek sadece saf Domain veya IP adresini ayıklar.
*   **Tekrarsızlaştırma:** Aynı domainin yüzlerce kez güvenlik duvarına gönderilip donanımın yorulmasını engeller (`set()` mantığı).
*   **Savunmacı Programlama (Defensive Design):** API banlarına (Rate Limiting) karşı bekleme süreleri ayarlanmıştır. Veri gelmezse mevcut dosyayı koruma altına alır, sistemi çökertmez.
*   **Sistem Entegrasyonu:** Linux `systemd` servisi olarak arka planda 7/24 kesintisiz çalışır.

## 🛠️ Kurulum ve Kullanım

### 1. Gereksinimler
* Ubuntu/Debian tabanlı bir Linux sunucu
* Python 3 ve `requests` kütüphanesi
* Nginx Web Sunucusu

### 2. Dosya Yapısı
Projeyi `/opt/usom_entegrasyonu/` dizinine klonlayın.
Çıktı dosyası `/var/www/html/usom.txt` konumunda oluşacak ve Nginx üzerinden `http://SUNUCU_IP/usom.txt` adresinden yayınlanacaktır.

### 3. Servis Kurulumu
`usom-fetcher.service` dosyasını `/etc/systemd/system/` dizinine kopyalayın ve servisi başlatın:
```bash
sudo systemctl daemon-reload
sudo systemctl enable usom-fetcher.service
sudo systemctl start usom-fetcher.service
