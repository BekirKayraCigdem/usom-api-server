# 🛡️ USOM API Server (Threat Intelligence Fetcher & Nginx Feeder)

## 📖 Proje Hakkında
Bu proje, USOM (Ulusal Siber Olaylara Müdahale Merkezi) API'sinden güncel zararlı bağlantı (Domain/IP) listelerini otomatik olarak çeker. Gelen veriyi akıllı bir şekilde temizleyerek kurumsal ağ güvenlik cihazlarının okuyabileceği "External Threat Feed" (Dış Tehdit Beslemesi) formatına dönüştürür ve Nginx üzerinden canlı olarak yayınlar.

## ✨ Öne Çıkan Özellikler
* **Sınırsız Dinamik Sayfalama (Pagination):** USOM veritabanındaki tüm verileri sınır tanımadan, otomatik olarak tarar ve çeker.
* **Akıllı Veri Temizleme (IOC Cleaner):** `http://zararli.com/virus.exe` gibi karmaşık bağlantıları ayrıştırır, klasör ve dosya yollarını atarak firewall cihazlarının anlayabileceği saf Domain veya IP adresini ayıklar.
* **Tekrarsızlaştırma Sistemi:** Çift kayıtları (duplicate) `set()` veri mimarisi ile engeller. Böylece güvenlik donanımlarının aynı veriyi defalarca işleyerek yorulmasının önüne geçilir.
* **Savunmacı Programlama (Defensive Design):** API limitlerine (Rate Limiting) takılmamak için akıllı bekleme süreleri içerir. Veri çekilemediği nadir durumlarda mevcut dosyayı koruma altına alır, ağın boş liste çekmesini önler.
* **7/24 Servis Mimarisi:** Linux `systemd` ile entegre çalışarak sistemin arka planında daemon olarak kesintisiz hizmet verir.
* **Yüksek Performanslı Dağıtım:** Oluşturulan tehdit listesi, Nginx web sunucusu üzerinden çok düşük gecikmeyle `.txt` formatında sunulur.

---

## 🛠️ Sistem Gereksinimleri
* **İşletim Sistemi:** Ubuntu / Debian tabanlı Linux Dağıtımı
* **Paketler:** `python3`, `python3-requests`, `nginx`, `git`

---

## 🚀 Kurulum Rehberi

### Otomatik Kurulum 
Repo içerisinde bulunan `github_push.sh` dosyası, sistem gereksinimlerini kurmak ve servisleri aktif etmek üzere otomatikleştirilmiştir.

1. Terminali açın ve sunucunuza bağlanın.
2. Aşağıda bulunan komutları sırasıyla uygulayın.
   ```bash
   cd /opt
   sudo git clone https://github.com/BekirKayraCigdem/usom-api-server.git
   cd usom-api-server
   sudo chmod +x install.sh
   sudo ./install.sh
