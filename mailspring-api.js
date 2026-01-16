const express = require('express');
const path = require('path');
const fs = require('fs');
const cors = require('cors');

const { exec } = require('child_process');

const app = express();
const PORT = 6379;
const MAILSPRING_CONFIG = path.join(process.env.HOME || '/home/mailspring', '.config/Mailspring');
const MAILSPRING_CONFIG_DEV = path.join(process.env.HOME || '/home/mailspring', '.config/Mailspring-dev');

app.use(cors());
app.use(express.json());

// Type text into the active window (emergency VNC bypass)
app.post('/api/type', (req, res) => {
    const { text } = req.body;
    if (!text) return res.status(400).json({ error: 'No text provided' });

    // Using xdotool to type text into the virtual display
    const command = `export DISPLAY=:99 && xdotool type "${text.replace(/"/g, '\\"')}"`;

    exec(command, (error) => {
        if (error) {
            return res.status(500).json({ error: error.message });
        }
        res.json({ status: 'sent', text: '******' });
    });
});

// Helper to get actual config path
const getConfigPath = () => {
    const devPath = path.join(MAILSPRING_CONFIG_DEV, 'config.json');
    if (fs.existsSync(devPath)) return devPath;
    return path.join(MAILSPRING_CONFIG, 'config.json');
};

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'mailspring-api' });
});

// Get Mailspring status
app.get('/api/status', (req, res) => {
    try {
        const configPath = getConfigPath();
        const configExists = fs.existsSync(configPath);

        res.json({
            status: 'running',
            configPath: path.dirname(configPath),
            configured: configExists,
            version: '1.16.0'
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get accounts info (read-only)
app.get('/api/accounts', (req, res) => {
    try {
        const configPath = getConfigPath();
        if (fs.existsSync(configPath)) {
            const data = JSON.parse(fs.readFileSync(configPath, 'utf8'));
            const accounts = data["*"] ? data["*"].accounts : [];
            res.json({ accounts: accounts || [] });
        } else {
            res.json({ accounts: [] });
        }
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Web dashboard
app.get('/', (req, res) => {
    res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Mailspring Control Panel</title>
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .status { padding: 10px; border-radius: 4px; margin: 10px 0; }
        .status.ok { background: #d4edda; color: #155724; }
        .status.error { background: #f8d7da; color: #721c24; }
        .info { background: #e7f3ff; padding: 10px; border-left: 4px solid #2196F3; margin: 10px 0; }
        .gui-link { display: block; background: #28a745; color: white; text-align: center; padding: 15px; border-radius: 8px; text-decoration: none; font-weight: bold; margin: 20px 0; font-size: 1.2em; }
        .gui-link:hover { background: #218838; }
        button { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
        button:hover { background: #0056b3; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>📧 Mailspring Control Panel</h1>
        <a href="http://localhost:6080/vnc.html?autoconnect=true" target="_blank" class="gui-link">Open Mailspring Desktop Interface</a>
        <div id="status"></div>
        <div id="accounts"></div>
        <div class="info">
          <strong>Note:</strong> Mailspring runs as a background service. Configuration and accounts are managed via the API.
        </div>
      </div>
      <script>
        async function loadStatus() {
          try {
            const response = await fetch('/api/status');
            const data = await response.json();
            document.getElementById('status').innerHTML = \`
              <div class="status ok">
                <strong>Status:</strong> \${data.status}<br>
                <strong>Version:</strong> \${data.version}<br>
                <strong>Configured:</strong> \${data.configured ? 'Yes' : 'No'}
              </div>
            \`;
            loadAccounts();
          } catch (err) {
            document.getElementById('status').innerHTML = \`<div class="status error">Error: \${err.message}</div>\`;
          }
        }
        
        async function loadAccounts() {
          try {
            const response = await fetch('/api/accounts');
            const data = await response.json();
            const count = data.accounts ? data.accounts.length : 0;
            document.getElementById('accounts').innerHTML = \`
              <div class="info">
                <strong>Connected Accounts:</strong> \${count}
              </div>
            \`;
          } catch (err) {
            console.error('Error loading accounts:', err);
          }
        }
        
        loadStatus();
        setInterval(loadStatus, 30000);
      </script>
    </body>
    </html>
  `);
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Mailspring API running on port ${PORT}`);
});
