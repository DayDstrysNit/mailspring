#!/usr/bin/env bash
# Mailspring Docker Setup - Complete Overview
# Run this script to get a summary of what's configured

cat << 'EOF'

╔══════════════════════════════════════════════════════════════════════════╗
║                   MAILSPRING DOCKER SETUP COMPLETE ✓                    ║
╚══════════════════════════════════════════════════════════════════════════╝

📍 Location: /Volumes/RAID5/Projects/_tools/mailspring

📦 DEPLOYMENT FILES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ docker-compose.yml          - Orchestrates containers & volumes
✓ Dockerfile                  - Builds image with all dependencies
✓ mailspring-api.js           - Express server (API + dashboard)
✓ manifest.json               - Dashboard metadata
✓ .dockerignore               - Optimizes build size
✓ integrate_with_toolbox.sh   - Integration helper script

📚 DOCUMENTATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ README_DOCKER.md            - Main documentation (START HERE)
✓ DEPLOYMENT_SUMMARY.md       - Detailed deployment guide
✓ DOCKER_SETUP.md             - Configuration reference
✓ QUICKSTART.md               - Quick commands & examples

📊 CONFIGURATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Port:           6379
Network:        tools-network (shared)
Data Storage:   data/config/, data/cache/, data/local/
Health Check:   http://localhost:6379/health
Dashboard:      http://localhost:6379

🚀 QUICK START (3 COMMANDS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. BUILD IMAGE:
   $ docker-compose build
   (Takes 10-15 minutes on first run)

2. START SERVICE:
   $ docker-compose up -d

3. VERIFY:
   $ curl http://localhost:6379/health

Then open: http://localhost:6379

🔗 INTEGRATION WITH DOCKER ECOSYSTEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Connected Services:
  • Paperless-ngx (8010)   - Archive emails as documents
  • n8n (5678)             - Workflow automation
  • Ollama (11434)         - AI email analysis
  • Leantime (8081)        - Project management
  • Mission Control (2187) - Dashboard

To add to Mission Control:
  $ ./integrate_with_toolbox.sh

🎯 API ENDPOINTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GET /health                  → Service health check
GET /api/status              → Mailspring status & version
GET /api/accounts            → Connected email accounts
GET /                        → Web dashboard UI

💾 DATA PERSISTENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
data/config/   → ~/.config/Mailspring
data/cache/    → ~/.cache
data/local/    → ~/.local/share

All configuration persists across container restarts.

🛠️ USEFUL COMMANDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
docker-compose logs -f mailspring      View live logs
docker-compose exec mailspring bash    Shell access
docker-compose restart mailspring      Restart service
docker-compose down                    Stop service
docker-compose build --no-cache        Rebuild image

📖 DOCUMENTATION GUIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Start Here:
  • README_DOCKER.md .................... Overview & getting started

Then Read:
  • QUICKSTART.md ....................... Common commands & examples
  • DOCKER_SETUP.md ..................... Complete setup guide
  • DEPLOYMENT_SUMMARY.md ............... Detailed reference

✨ ECOSYSTEM INTEGRATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mailspring can integrate with other tools via n8n:

Email → Paperless Archive
  Mailspring (6379) → n8n (5678) → Paperless (8010)
  Automatically archive important emails as OCR'd documents

Email → AI Analysis
  Mailspring (6379) → n8n (5678) → Ollama (11434)
  Analyze, summarize, and categorize emails with local LLM

Email → Task Creation
  Mailspring (6379) → n8n (5678) → Leantime (8081)
  Auto-create project tasks from starred/flagged emails

🔒 SECURITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Email credentials stored locally (never sent to cloud)
✓ Sync engine runs as separate process (isolated)
✓ Network isolated to tools-network by default
✓ No authentication by default (add if exposing externally)

📞 SUPPORT & RESOURCES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mailspring:      https://github.com/Foundry376/Mailspring
Community:       https://community.getmailspring.com/
Documentation:   https://foundry376.github.io/Mailspring/

✅ CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[✓] Repository cloned
[✓] Docker configuration created
[✓] API server configured
[✓] Data volumes prepared
[✓] Documentation written
[✓] Integration script created
[✓] Manifest prepared
[✓] Ready for deployment

📋 NEXT STEPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. cd /Volumes/RAID5/Projects/_tools/mailspring

2. docker-compose build

3. docker-compose up -d

4. curl http://localhost:6379/health

5. Open http://localhost:6379 in browser

6. (Optional) Run: ./integrate_with_toolbox.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Status:  ✅ READY FOR DEPLOYMENT
Version: 1.16.0 (Latest)
Date:    January 14, 2026

Questions? See README_DOCKER.md or visit https://community.getmailspring.com/

╚══════════════════════════════════════════════════════════════════════════╝

EOF
