#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import logging
import sys
import time

# 1. LOGLAMA AYARLARI
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
OUTPUT_FILE = "/var/www/html/usom.txt"

def clean_ioc(address):
    """Gelen adresten sadece Domain veya IP'yi kopartir, uzantilari cope atar."""
    try:
        clean_addr = address.replace("http://", "").replace("https://", "").split("/")[0]
        clean_addr = clean_addr.strip()
        if clean_addr:
            return True, clean_addr
        return False, None
    except Exception:
        return False, None

def fetch_and_save_usom_data():
    ioc_list = [] 
    total_records_checked = 0
    page = 1 # Taramaya baslayacagimiz ilk sayfa
    
    try:
        logging.info("USOM SINIRSIZ Derin Taramasi Basliyor (Tum veritabani cekilecek)...")
        
        # 2. SINIRSIZ DÖNGÜ (Dinamik Sayfalama)
        while True:
            api_url = f"https://www.usom.gov.tr/api/address/index?page={page}"
            
            response = requests.get(api_url, timeout=20)
            response.raise_for_status() 
            data = response.json()
            
            # Eger 'models' icinde veri varsa taramaya devam et
            if "models" in data and len(data["models"]) > 0:
                all_items = data["models"]
                total_records_checked += len(all_items)
                
                for item in all_items:
                    url = item.get("url", "")
                    if url:
                        valid, clean_data = clean_ioc(url)
                        if valid:
                            ioc_list.append(clean_data)
                
                # Sadece her 50 sayfada bir log atalim ki ekranimiz log coplugune donmesin
                if page % 50 == 0:
                    logging.info(f"... Su ana kadar {page} sayfa ve {total_records_checked} kayit tarandi ...")
                
                # Bir sonraki sayfaya gecmek icin sayaci 1 artir
                page += 1
                
                # SAVUNMACI YAKLASIM: USOM IP'mizi banlamasin diye sayfalar arasi 1 saniye bekle
                time.sleep(1)
                
            # Eger 'models' bossa, USOM'un sonuna gelmisiz demektir.
            else:
                logging.info(f"Veritabani sonuna ulasildi! Toplam {page-1} sayfa tamamen tarandi.")
                break # Donguyu kir ve bitir.

    except requests.exceptions.RequestException as e:
        logging.error(f"USOM API Erisim Hatasi (Ban riski veya baglanti koptu): {e}")
    except Exception as e:
        logging.error(f"Beklenmeyen hata: {e}")

    # 3. DOSYAYA YAZMA VE TEKRARLARI SİLME
    if len(ioc_list) > 0:
        unique_iocs = list(set(ioc_list)) 
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            for item in unique_iocs:
                f.write(f"{item}\n")
        logging.info(f"Sinirsiz Tarama Bitti! Toplam {total_records_checked} kayit icinden {len(unique_iocs)} adet ESSIZ tehdit dosyaya yazildi.")
    else:
        logging.warning("Hic tehdit bulunamadi. Mevcut dosya korundu.")

if __name__ == "__main__":
    logging.info("USOM Sınırsız Tarama Servisi Baslatildi...")
    while True:
        fetch_and_save_usom_data()
        
        # Tüm veritabanını çektiğimiz için sistemi ve USOM'u yormamak adına yeni tarama için 1 SAAT bekliyoruz.
        logging.info("Yeni Sinirsiz Tarama icin 1 SAAT (3600 saniye) bekleniyor...")
        time.sleep(3600)
