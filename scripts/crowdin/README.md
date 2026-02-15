# Crowdin Screenshot Automation

This script automates capturing screenshots of CircuitVerse pages and uploading them to Crowdin for better translation context.

## Prerequisites

1. Node.js 18+
2. Playwright browsers installed
3. Crowdin API credentials

## Setup

1. Install dependencies:
   ```bash
   yarn install
   npx playwright install chromium
   ```

2. Configure environment variables in `.env`:
   ```bash
   CROWDIN_PERSONAL_TOKEN=<your-crowdin-api-token>  # Required
   CROWDIN_PROJECT_ID=<your-crowdin-project-id>    # Required
   # Optional: Only for Crowdin in-context editor login
   # CROWDIN_USERNAME=<your-crowdin-username>
   # CROWDIN_PASSWORD=<your-crowdin-password>
   # CROWDIN_2FA_SECRET=<your-2fa-secret>
   ```

3. **Note:** The `.env` file is already in `.gitignore`, so your credentials won't be committed.
   Never commit files containing API tokens or credentials.

## Usage

Run the screenshot capture and upload:

```bash
yarn crowdin:screenshot
```

Or directly:

```bash
node scripts/crowdin/upload-screenshots.js
```

## What it does

1. Launches a headless Chromium browser
2. Captures full-page screenshots of:
   - Home page
   - Simulator
   - Examples
   - Login/Signup
   - About
   - Teachers
   - Contribute
   - Learn (external)
   - Blog (external)
3. Uploads each screenshot to Crowdin storage
4. Creates/updates screenshot records in Crowdin project
5. Supports 2FA authentication if configured

## Screenshots

Screenshots are saved locally in `scripts/crowdin/screenshots/` directory.

## Troubleshooting

### Missing environment variables
Ensure all required variables are set in your `.env` file.

### 2FA Authentication
If your Crowdin account has 2FA enabled, set `CROWDIN_2FA_SECRET` to your TOTP secret key.

### Network timeouts
The script has built-in timeouts. If pages load slowly, screenshots will still be captured after the DOM is loaded.
