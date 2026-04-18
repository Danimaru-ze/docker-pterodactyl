# 🚀 AstraHost :: Professional Pterodactyl Docker Images

[![Build Status](https://img.shields.io/github/actions/workflow/status/danimaru-ze/panel/universal.yml?style=flat-square&logo=github)](https://github.com/danimaru-ze/panel/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Docker Registry](https://img.shields.io/badge/Registry-GHCR-blue?style=flat-square&logo=docker)](https://github.com/danimaru-ze/panel/pkgs/container/panel)

**AstraHost** provides a suite of high-performance, feature-rich Docker images specifically engineered for **Pterodactyl** and **Jexactyl** panels. Our images are optimized for bot hosting, multimedia processing, and modern web development.

---

## 🌟 Why AstraHost?

AstraHost goes beyond standard Pterodactyl "yolks" by including everything you need for production-grade hosting out of the box.

- **Pre-installed Powerhouse**: Built-in support for FFmpeg, Chromium, ImageMagick, and Libvips.
- **Signal Handling**: Integrated with `tini` for graceful shutdowns—no more "zombie" processes or forced kills.
- **Cloudflare Ready**: Native `cloudflared` integration for seamless tunneling and public URLs.
- **Universal Runtime**: A powerhouse image containing Node.js, Python, Go, Bun, and more in a single environment.
- **Developer Experience**: Enhanced terminal with custom shell prompts and detailed system banners.

---

## 📦 Image Registry

All images are automatically built and published to the **GitHub Container Registry**.

> [!TIP]
> Use the tags below in your Pterodactyl Egg configuration.

### Available Stacks
| Stack | Tags | Features |
| :--- | :--- | :--- |
| **Node.js** | `node_18` to `node_25` | npm, yarn, pnpm, pm2, nodemon, puppeteer-ready |
| **Python** | `python_3.11` to `python_3.13` | Pip, venv, uv package manager |
| **Bun** | `bun_1.0` to `bun_latest` | High-performance JS runtime |
| **Golang** | `go_1.20` to `go_1.25.1` | Optimized for backend services |
| **Universal** | `debian13_universal`, `ubuntu25_universal` | **ALL ABOVE** + PHP, Ruby, Rust, Database Clients |

---

## 🛠️ Getting Started

### 1. Update your Egg Configuration
In your Pterodactyl Admin Panel, navigate to your Egg settings and update the **Docker Images** field:

```text
ghcr.io/danimaru-ze/panel:node_22
```

### 2. Force Rebuild
Go to the **Settings** tab of your server in the Admin Panel and click **Reinstall Server**. This will pull the latest AstraHost image and reconstruct the container without touching your data files.

---

## 🖥️ Universal Environment
The `universal` tag is our "flagship" image. It is designed for developers who need multiple runtimes or complex dependencies in a single server.

**Included Runtimes:**
- **Node.js** (LTS)
- **Python** 3.x
- **Bun** & **Deno**
- **Go** & **Rust**
- **PHP** & **Ruby**

**Network Tools Included:**
- `cloudflared` (Cloudflare Tunnel)
- `speedtest-cli`, `mtr`, `tcpdump`, `traceroute`, `whois`, `dig`.

---

## 🤝 Contributing
Contributions are what make the open-source community an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License
Distributed under the **MIT License**. See `LICENSE` for more information.

Built with ❤️ by [danimaru-ze](https://github.com/danimaru-ze)
