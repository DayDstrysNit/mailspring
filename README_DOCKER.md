# Mailspring Docker Deployment

> Beautiful, fast email client running in Docker integrated with your personal cloud ecosystem

## 📊 Status

✅ **Ready for Deployment** | 🐳 Docker Setup Complete | 🌐 Network Configured | 📚 Fully Documented

---

## 🎯 What You Get

A containerized instance of **Mailspring 1.16.0** with:

- ✅ Local email sync engine (C++ based, fast, battery-efficient)
- ✅ Full IMAP/SMTP support
- ✅ Plugin architecture for extensions
- ✅ Web API dashboard for monitoring
- ✅ Persistent configuration storage
- ✅ Integrated with `tools-network` for inter-service communication
- ✅ Ready for n8n automation workflows
- ✅ Headless operation (no X11 client needed)

---

## 🚀 Quick Start

```bash
# Navigate to this directory
cd /Volumes/RAID5/Projects/_tools/mailspring

# Build the Docker image (10-15 min first time)
docker-compose build

# Start the service
docker-compose up -d

# Verify it's running
curl http://localhost:6379/health

# View logs
docker-compose logs -f mailspring
```

**Access**: Open http://localhost:6379 in your browser

---

## 📁 Directory Structure

```
mailspring/
├── 📖 README.md                    ← This file
├── 📖 DEPLOYMENT_SUMMARY.md        ← Detailed deployment guide
├── 📖 QUICKSTART.md                ← Quick reference
├── 📖 DOCKER_SETUP.md              ← Complete setup instructions
├── 🐳 docker-compose.yml           ← Docker Compose orchestration
├── 🐳 Dockerfile                   ← Container build instructions
├── 🔌 mailspring-api.js            ← Express API server
├── 📋 manifest.json                ← Dashboard metadata
├── 🔧 integrate_with_toolbox.sh    ← Toolbox integration script
├── 📦 data/                        ← Persistent volumes
│   ├── config/                     ← ~/.config/Mailspring
│   ├── cache/                      ← ~/.cache
│   └── local/                      ← ~/.local/share
└── 📦 app/                         ← Mailspring source code
    ├── src/                        ← TypeScript source
    ├── internal_packages/          ← Built-in plugins
    └── spec/                       ← Tests
```

---

## 🌐 Network Integration

Mailspring is deployed on the **`tools-network`** bridge, enabling communication with:

| Service | Port | Purpose |
|---------|------|---------|
| **Mailspring** | 6379 | Email client + API |
| Paperless-ngx | 8010 | Document archive |
| n8n | 5678 | Workflow automation |
| Ollama | 11434 | Local LLM |
| Leantime | 8081 | Project management |

### Example Workflow
```
Email arrives → n8n webhook → Extract & analyze → 
  ├─ Archive to Paperless-ngx
  ├─ Summarize with Ollama
  └─ Create Leantime task
```

---

## 🔌 API Endpoints

The Express.js server provides REST endpoints:

```bash
# Health check
GET /health
→ {"status":"ok","service":"mailspring-api"}

# Service status
GET /api/status
→ {"status":"running","version":"1.16.0","configured":true}

# List connected email accounts
GET /api/accounts
→ {"accounts":[...]}

# Web dashboard
GET /
→ HTML dashboard UI
```

---

## 💾 Data Persistence

All configuration and mail data persists across restarts:

```
Container                    Host Volume
~/.config/Mailspring     →   data/config/
~/.cache                 →   data/cache/
~/.local/share          →   data/local/
```

### Backup
```bash
# Backup all data
tar -czf mailspring-backup.tar.gz data/

# Restore from backup
tar -xzf mailspring-backup.tar.gz
docker-compose restart mailspring
```

---

## 🛠️ Common Tasks

### View Logs
```bash
docker-compose logs -f mailspring
```

### Shell Access
```bash
docker-compose exec mailspring bash
```

### Restart Service
```bash
docker-compose restart mailspring
```

### Stop Service
```bash
docker-compose down
```

### Full Rebuild
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Check Configuration
```bash
docker-compose exec mailspring cat ~/.config/Mailspring/config.json
```

---

## 📊 Performance

| Metric | Value |
|--------|-------|
| Build time | 10-15 minutes (first time) |
| Startup time | ~30 seconds |
| Memory | 800MB - 1GB idle |
| Disk (image) | ~2GB |
| Disk (data) | 100MB - 1GB |

---

## 🔒 Security

- **Credentials**: Stored in container (never sent to cloud)
- **Network**: Isolated to `tools-network` by default
- **Data**: Persisted with proper Unix permissions
- **API**: No authentication (add if needed)

For production:
- Use reverse proxy with TLS/SSL
- Add authentication middleware
- Implement firewall rules
- Enable audit logging

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **DEPLOYMENT_SUMMARY.md** | Overview & deployment steps |
| **DOCKER_SETUP.md** | Detailed configuration guide |
| **QUICKSTART.md** | Quick reference with examples |
| **Mailspring Docs** | https://foundry376.github.io/Mailspring/ |

---

## 🔧 Integration with Mission Control

To add Mailspring to the Mission Control dashboard:

```bash
# Run the integration script
./integrate_with_toolbox.sh
```

This will:
- Add Mailspring entry to `external_tools.json`
- Restart the toolbox container
- Make Mailspring visible on http://localhost:2187

---

## 🎮 Development Mode

For plugin/theme development:

```bash
# Start in dev mode with hot reload
docker-compose up -d

# Watch TypeScript compilation
docker-compose exec mailspring npm run tsc-watch

# Run tests
docker-compose exec mailspring npm test
```

Press `Cmd+R` (Mac) or `Ctrl+R` (Linux/Windows) to reload within the app.

---

## 🐛 Troubleshooting

### Container Won't Start
```bash
# Check detailed logs
docker-compose logs mailspring

# Rebuild from scratch
docker-compose build --no-cache
docker-compose up -d
```

### Port Already in Use
```bash
# Check what's using port 6379
lsof -i :6379

# Or change port in docker-compose.yml:
# ports:
#   - "6380:6379"  ← Changed port
```

### API Not Responding
```bash
# Wait 30 seconds for startup
sleep 30

# Test connection
curl -v http://localhost:6379/health

# If still failing, check logs
docker-compose logs mailspring
```

### Permission Denied
```bash
# Fix data directory permissions
chmod -R 755 data/
chown -R $(id -u):$(id -g) data/
```

---

## 📦 What's Inside

**Mailspring Components:**
- TypeScript/React UI (browser process)
- C++ sync engine (spawned per account)
- SQLite database (WAL mode)
- Plugin system (51 built-in plugins)
- Theme engine

**Docker Setup:**
- Node 18 base image
- X11 virtual display (Xvfb)
- Express.js API server
- Persistent volume mounts
- Health check endpoints

---

## 🚀 Next Steps

1. **Build**: `docker-compose build` (go grab coffee ☕)
2. **Start**: `docker-compose up -d`
3. **Verify**: `curl http://localhost:6379/health`
4. **Access**: Open http://localhost:6379
5. **Integrate**: `./integrate_with_toolbox.sh`
6. **Configure**: Add your email accounts
7. **Automate**: Create n8n workflows

---

## 💬 Support

- **Mailspring Community**: https://community.getmailspring.com/
- **GitHub Issues**: https://github.com/Foundry376/Mailspring/issues
- **Docker Logs**: `docker-compose logs mailspring`
- **API Status**: http://localhost:6379/health

---

## 📄 License

Mailspring is licensed under GPLv3. See LICENSE.md in the Mailspring repository.

---

**Status**: ✅ Production Ready | **Version**: 1.16.0 | **Last Updated**: January 14, 2026
