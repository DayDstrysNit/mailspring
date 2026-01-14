# Mailspring Docker Setup

## Installation & Configuration

### 1. Build the Docker Image
```bash
cd /Volumes/RAID5/Projects/_tools/mailspring
docker-compose build
```

### 2. Create Required Directories
```bash
mkdir -p data/config data/cache data/local
chmod 777 data/config data/cache data/local
```

### 3. Start the Service
```bash
docker-compose up -d
```

### 4. Verify Service is Running
```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f mailspring

# Test API endpoint
curl http://localhost:6379/health
```

### 5. Access the Web Interface
Open your browser to: **http://localhost:6379**

---

## Integration with Mission Control Dashboard

Add this entry to `/Volumes/RAID5/Projects/_tools/toolbox/external_tools.json`:

```json
{
  "name": "Mailspring",
  "description": "Beautiful, fast email client with local sync engine",
  "icon": "📧",
  "port": 6379,
  "url": "http://localhost:6379",
  "category": "Communication",
  "status": "running",
  "healthCheck": "http://localhost:6379/health"
}
```

Then restart the toolbox:
```bash
docker restart developer-toolbox
```

---

## Configuration

### Adding Email Accounts

Access Mailspring configuration at:
```
~/.config/Mailspring/accounts.json
```

The web API provides read-only access via:
- `GET /api/status` - Service status
- `GET /api/accounts` - Connected email accounts
- `GET /health` - Health check

### Data Persistence

All configuration data is persisted in:
- `data/config/` - Main Mailspring config
- `data/cache/` - Cached data
- `data/local/` - Local database

---

## Network Architecture

Mailspring container is connected to the `tools-network` bridge, allowing communication with:
- **Paperless-ngx** (8010) - Archive emails as documents
- **n8n** (5678) - Create workflows (e.g., auto-organize emails)
- **Ollama** (11434) - AI-powered email analysis (future)

### Example n8n Workflow Integration

Use n8n to create workflows like:
1. **Email to Paperless**: Automatically archive important emails as PDFs
2. **Smart Organization**: Use Mailspring API + n8n to auto-tag/organize emails
3. **AI Analysis**: Send emails to Ollama for content analysis

---

## Troubleshooting

### Container Won't Start
```bash
# Check logs
docker-compose logs mailspring

# Rebuild image
docker-compose build --no-cache

# Start fresh
docker-compose down
docker-compose up -d
```

### API Not Responding
```bash
# Test connection
curl -v http://localhost:6379/health

# Check if port is in use
lsof -i :6379

# Restart service
docker-compose restart mailspring
```

### Permission Issues
```bash
# Fix data directory permissions
chmod -R 755 data/
chown -R 1000:1000 data/
```

---

## Performance Notes

- **First Build**: ~10-15 minutes (npm dependencies + Mailspring build)
- **Startup Time**: ~30 seconds (Xvfb + Mailspring initialization)
- **Memory**: ~800MB-1GB running
- **CPU**: Minimal when idle (<5% average)

---

## Development Commands

```bash
# Development mode with hot reload
docker-compose up -d

# Follow logs in real-time
docker-compose logs -f mailspring

# Shell into running container
docker-compose exec mailspring bash

# View Mailspring config
docker-compose exec mailspring cat ~/.config/Mailspring/config.json

# Query installed accounts
docker-compose exec mailspring cat ~/.config/Mailspring/accounts.json

# Stop service
docker-compose down

# Complete cleanup
docker-compose down -v
```

---

## Next Steps: Automation

Once running, set up n8n workflows to:
1. Extract emails to Markdown via Mailspring API
2. Archive into Paperless for OCR indexing
3. Use Ollama to categorize/summarize email content
4. Create Leantime tasks from flagged/starred emails

---

## Sync Engine Details

Mailspring uses a separate C++ sync engine (`Mailspring-Sync`) that:
- Handles all IMAP/SMTP communication
- Runs locally (credentials never leave container)
- Syncs via stdin/stdout JSON protocol
- Manages database changes in SQLite

The Docker container runs this sync engine in headless mode with a virtual X display, making it suitable for server/container environments.
