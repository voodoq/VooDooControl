# VooDoo CI/CD Pipeline

This directory contains GitHub Actions workflows for automated iOS builds.

## Workflows

### build.yml
Triggered on every push. Builds the app and runs tests.

### deploy.yml  
Triggered on release tags. Builds, signs, and uploads to App Store Connect.

## Required Secrets

Add these in GitHub → Settings → Secrets → Actions:

| Secret | Description |
|--------|-------------|
| `MATCH_PASSWORD` | fastlane match encryption password |
| `MATCH_REPOSITORY` | Git repo for certificates |
| `APP_STORE_CONNECT_API_KEY` | App Store Connect API key |
| `TEAM_ID` | Apple Developer Team ID |

## Setup

1. Fork this repo
2. Add secrets above
3. Push to main branch
4. Check Actions tab for build status
