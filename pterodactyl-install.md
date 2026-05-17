# Panduan Instalasi Pterodactyl Panel & Wings

Pterodactyl adalah panel manajemen server game berbasis web yang open-source. Panduan ini menjelaskan cara tercepat dan termudah menginstal Panel dan Wings (node) menggunakan Bash Script Installer komunitas yang sangat populer.

## 📌 Persyaratan Sistem
- VPS / Dedicated Server dengan OS **Ubuntu 20.04/22.04/24.04** atau **Debian 11/12**.
- Akses Root (`sudo su` atau login sebagai `root`).
- 2 Subdomain aktif yang sudah diarahkan (A Record) ke IP Server Anda. Contoh:
  - `panel.domain.com` (Untuk Panel Web)
  - `node.domain.com` (Untuk Wings/Daemon Server Game)

---

## 🚀 Langkah Instalasi

### 1. Update Server
Sebelum menginstal, pastikan server Anda sudah *up-to-date*:
```bash
apt update -y && apt upgrade -y
```

### 2. Jalankan Script Installer Pterodactyl
Jalankan perintah di bawah ini pada terminal SSH server Anda:
```bash
bash <(curl -s https://pterodactyl-installer.se)
```

### 3. Pilih Opsi Instalasi
Setelah script berjalan, Anda akan dihadapkan dengan beberapa pilihan instalasi.

**A. Install Panel Terlebih Dahulu:**
1. Ketik `0` lalu tekan *Enter* untuk memilih opsi **Install the panel**.
2. Ikuti instruksi di layar:
   - **Database**: Tekan *Enter* untuk menggunakan setting default (biarkan script yang menginstal & mengatur MariaDB otomatis).
   - **Timezone**: Masukkan zona waktu Anda (Contoh: `Asia/Jakarta`).
   - **Admin Account**: Masukkan Email, Username, Nama, dan Password untuk akun Administrator panel Anda.
   - **FQDN**: Masukkan subdomain panel Anda (Contoh: `panel.domain.com`).
   - **Firewall**: Pilih `yes` (y) jika ditanya untuk mengatur aturan UFW secara otomatis.
   - **SSL/Let's Encrypt**: Pilih `yes` (y) dan masukkan email Anda untuk mendapatkan sertifikat HTTPS/SSL gratis.
3. Tunggu proses instalasi dan konfigurasi Nginx, PHP, dan Panel hingga selesai sepenuhnya.

**B. Install Wings (Daemon / Node):**
*(Lakukan langkah ini jika Anda ingin menjalankan server game di VPS yang sama dengan Panel web).*
1. Jalankan kembali script installer yang sama:
   ```bash
   bash <(curl -s https://pterodactyl-installer.se)
   ```
2. Ketik `1` lalu tekan *Enter* untuk memilih **Install Wings**.
3. Ikuti instruksi perizinan SSL dan Firewall (UFW) sama seperti instalasi panel (pilih `yes`).

---

## ⚙️ Menghubungkan Wings ke Panel

Setelah Panel dan Wings terinstal di server, Anda harus menghubungkannya:

1. Buka browser dan login ke `https://panel.domain.com` menggunakan akun Admin yang dibuat tadi.
2. Klik ikon **Gear ⚙️** di pojok kanan atas untuk masuk ke mode Admin.
3. Buka menu **Locations**, lalu klik **Create New** (Contoh: Beri nama `Singapore` atau `Lokal`).
4. Buka menu **Nodes**, lalu klik **Create New**.
   - **Name**: Beri nama bebas (Misal: `Node-1`).
   - **Location**: Pilih lokasi yang baru saja Anda buat.
   - **FQDN**: Masukkan subdomain node Anda (Contoh: `node.domain.com`).
   - **Communicate Over SSL**: Pilih `Use SSL Connection`.
   - **Behind Proxy**: Pilih `Not Behind Proxy`.
   - **Total Memory / Disk Space**: Isi batas RAM dan Disk yang dialokasikan untuk node tersebut (sesuaikan dengan sisa spesifikasi VPS Anda).
   - Klik **Create Node**.
5. Setelah Node berhasil dibuat, klik pada nama Node tersebut lalu masuk ke tab **Configuration**.
6. Klik tombol biru **Generate Token**.
7. Salin (Copy) kode yang diawali dengan `sudo wings configure ...`, kemudian *Paste* dan jalankan kode tersebut di terminal (SSH) VPS Anda.
8. Jalankan *service* Wings secara permanen dengan menjalankan 2 perintah ini di terminal:
   ```bash
   systemctl start wings
   systemctl enable wings
   ```

🎉 **Selesai!** Pterodactyl Panel dan Wings Anda kini sudah terhubung dan siap digunakan untuk membuat server game.
