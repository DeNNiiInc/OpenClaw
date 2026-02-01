# Deployment Notes

## Issues Encountered & Resolutions

1.  **Line Endings (CRLF vs LF)**:
    - *Issue*: `server_setup_generated.sh` failing due to Windows CRLF.
    - *Resolution*: Used `tr -d '\r'` during injection.

2.  **Git Permissions**:
    - *Issue*: Merge conflicts on `deploy.sh`.
    - *Resolution*: Forced `git reset --hard` on server.

3.  **Missing Build Context**:
    - *Issue*: `docker-compose.yml` missing `build: .`.
    - *Resolution*: Added build context.

4.  **Gateway Configuration**:
    - *Issue*: Gateway container exiting with "Missing config".
    - *Resolution*: Added `--allow-unconfigured` flag to command.

5.  **Connectivity (WebSocket)**:
    - *Issue*: "Connection refused" initially, then "Bad Gateway" due to invalid bind parameter `0.0.0.0` causing crash.
    - *Resolution*: Reverted `OPENCLAW_GATEWAY_BIND` to `lan` (default) and ensured `--allow-unconfigured` is set. Docker port mapping handles the external access.

## Server Information
- **IP**: `172.16.69.235`
- **URL**: `https://zen.beyondcloud.solutions`
- **Gateway Token**: `6d1809076cc26f8b7979de3d1cbe3db2`

## Deployment Command
```bash
wsl sshpass -p 'uvgQi31gOMinJRvmHx' ssh root@172.16.69.235 "cd /root/OpenClaw && ./deploy.sh"
```

6.  **Permission Denied (EACCES)**:
    - *Issue*: Gateway crashed or rejected connections due to inability to write to .openclaw/devices volume.
    - *Resolution*: Chowned the mapped volume directories to 1000:1000 (Node user).
