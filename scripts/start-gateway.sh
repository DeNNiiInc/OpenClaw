#!/bin/bash
set -e

CONFIG_DIR="/home/node/.openclaw"
CONFIG_FILE="$CONFIG_DIR/config.json"

mkdir -p "$CONFIG_DIR"

echo "Generating config at $CONFIG_FILE..."

# Generate config using Node.js to ensure valid JSON
node << EOFNODE
const fs = require('fs');
const configPath = '$CONFIG_FILE';
const config = {
    gateway: {
        port: 18789,
        mode: 'local',
        bind: '0.0.0.0',
        trustedProxies: [
            '0.0.0.0/0', 
            '::/0', 
            '10.0.0.0/8', 
            '172.16.0.0/12', 
            '192.168.0.0/16',
            '127.0.0.1'
        ],
        auth: {},
        controlUi: {}
    }
};

// Set gateway token
if (process.env.OPENCLAW_GATEWAY_TOKEN) {
    config.gateway.auth.token = process.env.OPENCLAW_GATEWAY_TOKEN;
}

// Enable insecure auth (bypass pairing)
config.gateway.controlUi.allowInsecureAuth = true;
config.gateway.controlUi.dangerouslyDisableDeviceAuth = true;

fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
console.log('Config generated successfully.');
console.log(JSON.stringify(config, null, 2));
EOFNODE

# Start the gateway
echo "Starting OpenClaw Gateway..."

# Debug: list files to find entrypoint
echo "DEBUG CWD: $(pwd)"
echo "DEBUG LS:"
ls -F || echo "ls failed"
echo "DEBUG FIND index.js:"
find / -name "index.js" -maxdepth 4 2>/dev/null || echo "find failed"

# We use the env var for token as well just in case config is ignored
exec node dist/index.js gateway \
    --port 18789 \
    --verbose \
    --allow-unconfigured \
    --bind 0.0.0.0 \
    --token "$OPENCLAW_GATEWAY_TOKEN"
