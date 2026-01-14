# Mailspring + Docker Ecosystem Integration

## Quick Start

```bash
# Navigate to mailspring folder
cd /Volumes/RAID5/Projects/_tools/mailspring

# Build image
docker-compose build

# Start service
docker-compose up -d

# Verify
docker-compose ps
```

**Access**: http://localhost:6379

---

## Architecture

```
┌──────────────────────────────────────────────────┐
│         Mission Control Dashboard (2187)         │
│                                                  │
│  ┌─────────────────────────────────────────┐   │
│  │  📧 Mailspring (6379) ← Add this entry  │   │
│  │  📄 Paperless (8010)                    │   │
│  │  🤖 AI Hub (4001)                       │   │
│  │  📊 Leantime (8081)                     │   │
│  │  🔗 n8n (5678)                         │   │
│  └─────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
                      │
              ┌───────▼────────┐
              │  tools-network  │
              └────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   Mailspring    Paperless       Ollama
    (C++ Sync)    (OCR/Index)   (Analysis)
```

---

## Port Reference

| Service     | Port | Purpose                              |
|------------|------|--------------------------------------|
| Mailspring | 6379 | Email client API + web dashboard     |
| Paperless  | 8010 | Document management                 |
| n8n        | 5678 | Workflow automation                 |
| Ollama     | 11434| Local LLM inference                 |

---

## Workflow Examples

### 1. Email → Document Archive (via n8n)
```
Mailspring → n8n webhook → Export as PDF → Paperless OCR → Full-text searchable
```

### 2. Email Analysis (via Ollama)
```
Mailspring API → n8n → Extract content → Ollama (llama3.2) → Categorize/Summarize
```

### 3. Project Integration (via n8n + Leantime)
```
Starred Email → n8n trigger → Extract task info → Create Leantime task
```

---

## Configuration

### Update external_tools.json

After starting Mailspring, add to `/Volumes/RAID5/Projects/_tools/toolbox/external_tools.json`:

```json
{
  "name": "Mailspring",
  "description": "Beautiful, fast email client with local sync engine",
  "icon": "📧",
  "port": 6379,
  "url": "http://localhost:6379",
  "category": "Communication",
  "status": "running",
  "healthCheck": "http://localhost:6379/health",
  "features": [
    "Email Sync (IMAP/SMTP)",
    "Unified Inbox",
    "Local Encryption",
    "Plugin Architecture",
    "Link Tracking (Pro)"
  ]
}
```

Then restart toolbox:
```bash
docker restart developer-toolbox
```

---

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Service health check |
| `/api/status` | GET | Mailspring status & version |
| `/api/accounts` | GET | Connected email accounts |
| `/` | GET | Web dashboard UI |

### Example API Calls

```bash
# Check if service is running
curl http://localhost:6379/health

# Get Mailspring status
curl http://localhost:6379/api/status

# List connected accounts
curl http://localhost:6379/api/accounts
```

---

## Data Persistence

Configuration and cache stored in:
- `data/config/` → ~/.config/Mailspring
- `data/cache/` → ~/.cache
- `data/local/` → ~/.local/share

These are mounted as volumes, persisting across container restarts.

---

## First-Time Setup

1. **Start container**
   ```bash
   docker-compose up -d
   ```

2. **Wait for service** (~30 seconds)
   ```bash
   docker-compose logs mailspring
   ```

3. **Access web interface**
   - Navigate to: http://localhost:6379
   - Status should show "running"

4. **Add email account** (via configuration)
   - Container runs in headless mode
   - Email accounts configured via config file or API
   - See DOCKER_SETUP.md for detailed account setup

---

## Useful Commands

```bash
# View real-time logs
docker-compose logs -f mailspring

# Restart service
docker-compose restart mailspring

# Shell access
docker-compose exec mailspring bash

# View config
docker-compose exec mailspring ls -la ~/.config/Mailspring/

# Stop service
docker-compose down

# Full rebuild
docker-compose build --no-cache && docker-compose up -d
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Container crashes | Check logs: `docker-compose logs mailspring` |
| API not responding | Wait 30 seconds for startup, then test health endpoint |
| Port 6379 in use | Change port in `docker-compose.yml` or kill existing process |
| Config not persisting | Verify `data/` directory has write permissions |

---

## Network Testing

Verify Mailspring can reach other services:

```bash
# From within container
docker-compose exec mailspring bash

# Test connectivity to other services
curl http://paperless:8010/health  # Paperless
curl http://ollama:11434/health    # Ollama (if n8n can reach it)
```

---

## Production Notes

For production deployment:
- Use environment variables for credentials
- Implement reverse proxy (nginx) for HTTPS
- Enable firewall rules to restrict port access
- Set up automated backups of `data/` directory
- Monitor container resource usage

---

## Next Steps

1. Start the container: `docker-compose up -d`
2. Verify it's running: `curl http://localhost:6379/health`
3. Add to external_tools.json in toolbox
4. Create n8n workflows for automation
5. Configure email accounts for sync

See **DOCKER_SETUP.md** for detailed configuration guide.
