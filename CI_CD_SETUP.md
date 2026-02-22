# VooDoo CI/CD Architecture

Complete infrastructure for remote iOS building and deployment.

## Architecture Overview

```
┌─────────────────┐     SSH      ┌─────────────────┐     xcodebuild    ┌─────────────┐
│   Your Windows  │ ───────────→ │   Cloud Mac     │ ────────────────→ │   iOS App   │
│   Machine       │              │   (macOS)       │                   │   (.app)    │
└─────────────────┘              └─────────────────┘                   └─────────────┘
         │                              │
         │ git push                     │ fastlane
         ↓                              ↓
┌─────────────────┐              ┌─────────────────┐
│   GitHub Repo   │              │   App Store     │
│                 │              │   Connect       │
└─────────────────┘              └─────────────────┘
         │
         │ GitHub Actions
         ↓
┌─────────────────┐
│   Auto Build    │
│   on Push       │
└─────────────────┘
```

## Option 1: GitHub Actions (Recommended - Free)

### Setup Steps

1. **Fork/Push this repo to GitHub**
```bash
cd VooDooControl
git remote add origin https://github.com/YOUR_USERNAME/VooDooControl.git
git push -u origin main
```

2. **Add GitHub Secrets**
Go to Settings → Secrets → Actions, add:
- `MATCH_PASSWORD`: Encryption password for certificates
- `MATCH_REPOSITORY`: GitHub repo for certificates (create empty repo)
- `APP_STORE_CONNECT_API_KEY`: Your App Store Connect API key
- `TEAM_ID`: Apple Developer Team ID

3. **Push triggers build automatically**
Every push to `main` branch triggers the workflow.

**Pros:**
- ✅ Free for public repos
- ✅ No cloud Mac needed
- ✅ Automatic on every push
- ✅ Download .ipa directly

**Cons:**
- ❌ Limited to 2000 minutes/month on free tier
- ❌ 10 minute max build time sometimes

## Option 2: Cloud Mac (More Control)

### Providers

| Provider | Price | Notes |
|----------|-------|-------|
| **MacStadium** | ~$99/mo | Dedicated Mac Mini |
| **AWS EC2 Mac** | $1.08/hr | On-demand, powerful |
| **Scaleway** | €0.10/hr | Cheapest option |
| **Github Actions** | FREE | macOS runners |

### Setup Steps

1. **Rent a cloud Mac** from one of the providers above

2. **SSH into the Mac**
```bash
ssh username@cloud-mac-ip
```

3. **Run setup script**
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/VooDooControl/main/scripts/setup_cloud_mac.sh | bash
```

4. **Configure locally**
Edit `scripts/remote_build.sh`:
```bash
CLOUD_MAC_IP="YOUR_CLOUD_MAC_IP"
CLOUD_MAC_USER="YOUR_USERNAME"
```

5. **Control from Windows**
```bash
./scripts/remote_build.sh status
./scripts/remote_build.sh build
./scripts/remote_build.sh download
```

**Available Commands:**
- `status` - Check cloud Mac status
- `pull` - Pull latest code
- `build` - Build debug version
- `test` - Run tests
- `release` - Build release
- `deploy` - Push to TestFlight
- `logs` - View build logs
- `download` - Get build artifacts
- `shell` - SSH into cloud Mac

## Option 3: Hybrid (Best of Both)

Use GitHub Actions for CI/CD, cloud Mac for development/testing.

1. **GitHub Actions**: Automatic builds on every push
2. **Cloud Mac**: Interactive development, quick tests
3. **Local Windows**: Edit code, trigger remote builds

## File Structure

```
VooDooControl/
├── .github/
│   └── workflows/
│       ├── build.yml       # Automatic builds
│       ├── deploy.yml      # App Store deployment
│       └── README.md
├── scripts/
│   ├── setup_cloud_mac.sh  # One-time cloud Mac setup
│   ├── build.sh            # Local/remote build script
│   └── remote_build.sh     # Control cloud Mac from Windows
├── fastlane/
│   ├── Fastfile            # Deployment lanes
│   ├── Appfile             # App configuration
│   └── Matchfile           # Certificate management
└── README.md
```

## Quick Start

### Using GitHub Actions (Free)

```bash
# 1. Push to GitHub
git push origin main

# 2. Check Actions tab on GitHub
# Build will start automatically

# 3. Download .ipa from Actions artifacts
```

### Using Cloud Mac

```bash
# 1. Setup cloud Mac (one time)
ssh cloud-mac-ip < scripts/setup_cloud_mac.sh

# 2. Configure remote_build.sh with your IP

# 3. Build from Windows
./scripts/remote_build.sh build
./scripts/remote_build.sh download
```

## Troubleshooting

### Build fails with code signing
```bash
# Run on cloud Mac
fastlane match development
fastlane match appstore
```

### Can't SSH to cloud Mac
1. Enable Remote Login: System Preferences → Sharing → Remote Login
2. Check firewall: `sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate`
3. Verify SSH key: `ssh-add -l`

### GitHub Actions fails
Check Actions logs for specific errors. Common issues:
- Missing secrets
- Wrong Xcode version
- Certificate issues

## Security Notes

- Never commit certificates or private keys
- Use GitHub Secrets or environment variables
- Rotate API keys regularly
- Use match for secure certificate sharing

## Next Steps

1. Choose your approach (GitHub Actions or Cloud Mac)
2. Follow setup steps above
3. Push code and watch it build!

Need help? Check the main README.md for app-specific info.
