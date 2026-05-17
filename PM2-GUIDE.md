# ⚡ AstraHost PM2 Pro — Panduan Lengkap

> **Untuk user sepuh yang butuh kontrol penuh atas proses bot mereka**

---

## 🤔 Apa itu PM2?

**PM2** (Process Manager 2) adalah **production-grade process manager** untuk aplikasi Node.js (dan bisa juga Python, Go, dll). PM2 dikembangkan oleh [Keymetrics](https://pm2.keymetrics.io/) dan digunakan oleh ribuan perusahaan besar di seluruh dunia.

Kalau `npm start` biasa hanya menjalankan bot lalu mati saat crash, PM2 hadir sebagai **"penjaga"** yang:
- Selalu memastikan bot tetap hidup
- Me-restart otomatis saat crash atau memory overload
- Memberikan monitoring real-time
- Mengelola log secara profesional

---

## 💡 Kenapa PM2 Lebih Baik dari `npm start` Biasa?

| Fitur | `npm start` (biasa) | **PM2** |
|-------|-------------------|---------|
| Auto-restart saat crash | ❌ | ✅ |
| Memory limit guard | ❌ | ✅ Restart jika RAM > batas |
| Log management | ❌ (stdout saja) | ✅ File log terpisah + rotasi |
| Cluster mode (multi-core) | ❌ | ✅ |
| Graceful reload (zero downtime) | ❌ | ✅ |
| Health monitoring | ❌ | ✅ CPU, RAM, uptime, restart count |
| Startup delay antar restart | ❌ | ✅ Configurable |
| Environment per-app | ❌ | ✅ via ecosystem.config.js |
| Bisa jalankan banyak app | ❌ | ✅ |
| Watch file changes (dev mode) | ❌ | ✅ |

---

## 🏆 Kelebihan PM2 untuk WhatsApp Bot di Pterodactyl

### 1. 🔄 Auto-Restart Cerdas
Bot WhatsApp sering crash karena disconnect, WebSocket timeout, atau memory leak.  
PM2 langsung restart **dalam hitungan detik** tanpa perlu sentuh panel.

```
restart_delay: 3000     → tunggu 3 detik sebelum restart
max_restarts: 10        → maksimal 10 restart dalam 60 detik
min_uptime: 5s          → dianggap stable jika hidup > 5 detik
```

### 2. 🧠 Memory Guard
Kalau bot bocor memory (memory leak), PM2 otomatis restart sebelum VPS kehabisan RAM.

```
max_memory_restart: 512M   → restart jika RAM > 512MB
```

### 3. 📜 Log Management Profesional
Log tersimpan di file terpisah, bukan hilang bersama terminal:
- `logs/pm2-out.log` → stdout (normal output)
- `logs/pm2-err.log` → stderr (error)
- Dengan timestamp: `2025-01-01 12:00:00 +07:00`
- Log rotation otomatis agar tidak menghabiskan disk

### 4. ⚡ Cluster Mode (Multi-Core)
Untuk bot dengan traffic tinggi, PM2 bisa menjalankan **beberapa instance** sekaligus memanfaatkan semua CPU core:

```js
instances: 'max',     // pakai semua core
exec_mode: 'cluster', // load balancing otomatis
```

### 5. 🔧 ecosystem.config.js — Konfigurasi Terpusat
Semua pengaturan bot ada di satu file yang bisa di-commit ke Git:

```js
module.exports = {
  apps: [{
    name: 'kaiden-bot',
    script: 'index.js',
    instances: 1,
    exec_mode: 'fork',
    max_memory_restart: '512M',
    restart_delay: 3000,
    env: { NODE_ENV: 'production', TZ: 'Asia/Jakarta' }
  }]
};
```

### 6. 🔁 Graceful Reload (Zero Downtime)
Saat update bot, PM2 bisa reload **tanpa memutus koneksi** yang sedang berjalan (untuk cluster mode).

---

## 🎯 Apakah PM2 Cocok untuk Panel Bot Pterodactyl?

### ✅ Sangat Cocok Jika Kamu:
- Punya bot produksi yang **harus selalu online 24/7**
- Ingin **monitoring** CPU/RAM real-time
- Bot sering crash dan butuh **auto-recovery yang andal**
- Punya **banyak bot** dan ingin kelola dalam satu tempat
- Butuh **log terstruktur** untuk debugging
- Familiar dengan terminal dan konfigurasi lanjutan

### ⚠️ Tidak Perlu PM2 Jika Kamu:
- Baru belajar hosting bot (gunakan `egg-astra.json` dulu)
- Bot hanya untuk testing/development
- Resource VPS sangat terbatas (PM2 sendiri ~30MB RAM)

---

## 🚀 Cara Setup Egg PM2 di Pterodactyl

### Step 1: Import Egg
1. Buka Pterodactyl Admin Panel
2. **Nests** → pilih Nest kamu
3. **Import Egg** → upload `egg-pm2.json`

### Step 2: Buat Server Baru
Pilih Egg **"⚡ AstraHost PM2 [Pro]"** saat membuat server.

### Step 3: Konfigurasi Variables

| Variable | Nilai Rekomendasi | Keterangan |
|----------|------------------|------------|
| Git Repository URL | `https://github.com/user/bot` | URL repo bot |
| PM2 App Name | `bot` | Nama proses |
| PM2 Script | `index.js` | Entry file |
| Max Memory | `512` | MB |
| Max Restarts | `10` | Dalam 60 detik |
| Use ecosystem.config.js | `1` | Jika sudah ada |

### Step 4: Buat ecosystem.config.js (Opsional tapi Recommended)

Letakkan file ini di root project botmu:

```js
// ecosystem.config.js
module.exports = {
  apps: [
    {
      name: 'kaiden-bot',
      script: 'index.js',

      // Restart strategy
      autorestart: true,
      max_memory_restart: '512M',
      restart_delay: 3000,
      max_restarts: 10,
      min_uptime: '5s',

      // Environment
      env: {
        NODE_ENV: 'production',
        TZ: 'Asia/Jakarta',
      },

      // Logging
      out_file: './logs/pm2-out.log',
      error_file: './logs/pm2-err.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,

      // Graceful shutdown
      kill_timeout: 5000,
    }
  ]
};
```

---

## 🔧 Perbedaan `pm2 start` vs `pm2-runtime`

| | `pm2 start` | `pm2-runtime` |
|--|-------------|---------------|
| Untuk | Development (background daemon) | **Production / Docker / Pterodactyl** |
| Proses | Fork ke background | **Foreground (blocking)** |
| Log | Ke file `.pm2/logs` | Langsung ke **stdout** (Pterodactyl bisa baca) |
| Cocok Pterodactyl | ❌ (process langsung exit) | ✅ |

> **Penting:** Egg ini menggunakan `pm2-runtime` bukan `pm2 start` agar Pterodactyl bisa membaca output dan kontrol proses dengan benar!

---

## 📊 Contoh Output Console di Pterodactyl

```
╔═══════════════════════════════════════════════════╗
║     AstraHost ⚡ PM2 Pro — Process Manager        ║
╚═══════════════════════════════════════════════════╝

[INFO]  Timezone    : Asia/Jakarta
[INFO]  Node ENV    : production
[INFO]  Internal IP : 10.0.0.5
[OK]    PM2 v5.4.3 ready.
[STEP]  Installing npm dependencies...
[OK]    Dependencies installed.
[STEP]  Launching application with PM2...
[INFO]  Using ecosystem.config.js (advanced mode)

[PM2] Spawning PM2 daemon with pm2_home=/home/container/.pm2
[PM2] PM2 Successfully daemonized
[PM2] Running app in production mode with 1 instances
[PM2][WORKER][0] Starting up application on port 3000
✓ Bot connected. Waiting for messages...
```

---

## 🛡️ Troubleshooting

### Bot tidak mau start
```bash
# Cek log error
cat logs/pm2-err.log

# Cek ecosystem.config.js syntax
node -e "require('./ecosystem.config.js')" && echo "OK"
```

### Memory terus naik
- Turunkan `Max Memory` di variable panel
- Cek apakah ada memory leak di kode bot

### PM2 restart terus-terusan
- Cek `Max Restarts` dan `Min Uptime`
- Bot mungkin crash di startup, cek `logs/pm2-err.log`

### Mau pakai `pm2 logs` interaktif
- PM2 egg menggunakan `pm2-runtime` sehingga log langsung ke console Pterodactyl
- Tidak perlu `pm2 logs` terpisah

---

## 📁 Struktur File yang Direkomendasikan

```
/home/container/
├── index.js              ← Entry point bot
├── package.json
├── ecosystem.config.js   ← PM2 config (recommended)
├── .env                  ← Environment variables
├── logs/
│   ├── pm2-out.log       ← Normal output
│   └── pm2-err.log       ← Error log
├── sessions/             ← WhatsApp session
└── node_modules/
```

---

*Dibuat dengan ❤️ oleh AstraHost | Untuk user yang serius soal uptime*
