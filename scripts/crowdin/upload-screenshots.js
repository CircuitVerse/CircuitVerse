require('dotenv').config();
const { chromium } = require('playwright');
const { authenticator } = require('otplib');
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const FormData = require('form-data');

const CROWDIN_PROJECT_ID = process.env.CROWDIN_PROJECT_ID;
const CROWDIN_PERSONAL_TOKEN = process.env.CROWDIN_PERSONAL_TOKEN;
const CROWDIN_USERNAME = process.env.CROWDIN_USERNAME;
const CROWDIN_PASSWORD = process.env.CROWDIN_PASSWORD;
const CROWDIN_2FA_SECRET = process.env.CROWDIN_2FA_SECRET;
const BASE_URL = 'https://api.crowdin.com/api/v2';

const pages = [
  { name: 'Home', url: 'https://circuitverse.org/' },
  { name: 'Home_Features', url: 'https://circuitverse.org/#home-features-section' },
  { name: 'Simulator', url: 'https://circuitverse.org/simulator' },
  { name: 'Examples', url: 'https://circuitverse.org/examples' },
  { name: 'Login', url: 'https://circuitverse.org/users/sign_in' },
  { name: 'Signup', url: 'https://circuitverse.org/users/sign_up' },
  { name: 'About', url: 'https://circuitverse.org/about' },
  { name: 'Teachers', url: 'https://circuitverse.org/teachers' },
  { name: 'Contribute', url: 'https://circuitverse.org/contribute' },
  { name: 'Learn', url: 'https://learn.circuitverse.org/' },
  { name: 'Blog', url: 'https://blog.circuitverse.org/' },
];

const getHeaders = (contentType = 'application/json') => ({
  'Authorization': `Bearer ${CROWDIN_PERSONAL_TOKEN}`,
  'Accept': 'application/json',
  'Content-Type': contentType,
});

async function uploadToCrowdinStorage(filePath, fileName) {
  try {
    console.log(`[UPLOAD] Uploading ${fileName} to Crowdin storage...`);

    const fileData = fs.readFileSync(filePath);
    const res = await axios.post(`${BASE_URL}/storages`, fileData, {
      headers: {
        'Authorization': `Bearer ${CROWDIN_PERSONAL_TOKEN}`,
        'Accept': 'application/json',
        'Content-Type': 'application/octet-stream',
        'Crowdin-API-FileName': fileName,
      },
      timeout: 30000,
    });

    if (res.data && res.data.data && res.data.data.id) {
      console.log(`[OK] Storage upload successful: ${res.data.data.id}`);
      return res.data.data.id;
    } else {
      console.error('[ERROR] Crowdin did not return a storage ID:', res.data);
      return null;
    }
  } catch (err) {
    console.error('[ERROR] Error uploading to Crowdin storage:');
    if (err.response) {
      console.error('Status:', err.response.status);
      console.error('Details:', JSON.stringify(err.response.data, null, 2));
    } else {
      console.error('Message:', err.message);
    }
    return null;
  }
}

async function getExistingScreenshots() {
  try {
    const res = await axios.get(
      `${BASE_URL}/projects/${CROWDIN_PROJECT_ID}/screenshots`,
      {
        headers: getHeaders(),
        timeout: 30000,
      }
    );
    return res.data.data || [];
  } catch (err) {
    console.error('[ERROR] Error fetching existing screenshots:', err.message);
    return [];
  }
}

async function updateScreenshot(screenshotId, storageId, name) {
  try {
    console.log(`[UPDATE] Updating existing screenshot: ${name}...`);

    const res = await axios.put(
      `${BASE_URL}/projects/${CROWDIN_PROJECT_ID}/screenshots/${screenshotId}`,
      { storageId },
      {
        headers: getHeaders(),
        timeout: 30000,
      }
    );

    console.log(`[OK] Screenshot updated: ${name}`);
    return res.data;
  } catch (err) {
    console.error(`[ERROR] Error updating screenshot ${name}:`, err.message);
    throw err;
  }
}

async function uploadScreenshotToCrowdin(storageId, name) {
  try {
    console.log(`[UPLOAD] Creating screenshot record for ${name}...`);

    const screenshotName = `${name}.png`;

    // Check if screenshot already exists
    const existingScreenshots = await getExistingScreenshots();
    const existing = existingScreenshots.find(s => s.data.name === screenshotName);

    if (existing) {
      return await updateScreenshot(existing.data.id, storageId, name);
    }

    const res = await axios.post(
      `${BASE_URL}/projects/${CROWDIN_PROJECT_ID}/screenshots`,
      {
        storageId,
        name: screenshotName,
      },
      {
        headers: getHeaders(),
        timeout: 30000,
      }
    );

    console.log(`[OK] Screenshot record created for ${name}`);
    return res.data;
  } catch (err) {
    console.error(`[ERROR] Error creating screenshot record for ${name}:`);
    if (err.response) {
      console.error('Status:', err.response.status);
      console.error('Details:', JSON.stringify(err.response.data, null, 2));
    } else {
      console.error('Message:', err.message);
    }
    throw err;
  }
}

async function handle2FA(page) {
  if (!CROWDIN_2FA_SECRET) {
    console.log('[INFO] 2FA secret not configured, skipping 2FA');
    return false;
  }

  try {
    const tfaField = page.getByLabel('Verification Code');
    if (await tfaField.isVisible({ timeout: 5000 })) {
      console.log('[AUTH] 2FA required, generating code...');
      const token = authenticator.generate(CROWDIN_2FA_SECRET);
      await tfaField.fill(token);
      await page.getByRole('button', { name: 'Verify' }).click();
      console.log('[OK] 2FA code submitted');
      return true;
    }
  } catch (e) {
    console.log('[INFO] No 2FA required or 2FA handling failed:', e.message);
  }
  return false;
}

async function captureAndUploadScreenshot(page, pageInfo, screenshotDir) {
  console.log(`[CAPTURE] Processing: ${pageInfo.name} (${pageInfo.url})`);

  try {
    await page.goto(pageInfo.url, {
      waitUntil: 'domcontentloaded',
      timeout: 30000
    });

    await page.waitForTimeout(2000);

    try {
      await page.waitForLoadState('networkidle', { timeout: 10000 });
    } catch (e) {
      console.log(`[WARN] Network idle timeout for ${pageInfo.name}, proceeding anyway...`);
    }

    const fileName = `${pageInfo.name.replace(/\s+/g, '_').toLowerCase()}.png`;
    const screenshotPath = path.join(screenshotDir, fileName);

    await page.screenshot({
      path: screenshotPath,
      fullPage: true,
      timeout: 30000
    });

    console.log(`[OK] Screenshot saved: ${fileName}`);

    const storageId = await uploadToCrowdinStorage(screenshotPath, fileName);
    if (storageId) {
      await uploadScreenshotToCrowdin(storageId, pageInfo.name);
      console.log(`[OK] Uploaded to Crowdin: ${pageInfo.name}`);
      return true;
    } else {
      console.error(`[ERROR] Failed to upload ${pageInfo.name} to Crowdin`);
      return false;
    }
  } catch (err) {
    console.error(`[ERROR] Failed to process ${pageInfo.name}: ${err.message}`);
    return false;
  }
}

async function captureSimulatorPage(page, screenshotDir) {
  console.log('[CAPTURE] Capturing simulator page...');

  try {
    await page.goto('https://circuitverse.org/simulator');
    
    try {
      await page.waitForLoadState('networkidle', { timeout: 15000 });
    } catch (e) {
      console.log('[WARN] Network idle timeout for simulator, proceeding anyway...');
    }
    
    await page.waitForTimeout(3000);

    const fileName = 'simulator_interactive.png';
    const screenshotPath = path.join(screenshotDir, fileName);

    await page.screenshot({
      path: screenshotPath,
      fullPage: true,
    });

    console.log('[OK] Simulator screenshot captured');

    // Upload to Crowdin
    const storageId = await uploadToCrowdinStorage(screenshotPath, fileName);
    if (storageId) {
      await uploadScreenshotToCrowdin(storageId, 'Simulator_Interactive');
      console.log('[OK] Simulator screenshot uploaded to Crowdin');
      return true;
    } else {
      console.error('[ERROR] Failed to upload simulator screenshot to Crowdin');
      return false;
    }
  } catch (err) {
    console.error(`[ERROR] Failed to capture simulator page: ${err.message}`);
    return false;
  }
}

async function captureScreenshots() {
  console.log('[START] Starting Crowdin screenshot capture process...');

  console.log('\n[ENV] Environment check:');
  console.log('CROWDIN_PROJECT_ID:', CROWDIN_PROJECT_ID ? 'Set' : 'Missing');
  console.log('CROWDIN_PERSONAL_TOKEN:', CROWDIN_PERSONAL_TOKEN ? 'Set' : 'Missing');
  console.log('CROWDIN_USERNAME:', CROWDIN_USERNAME ? 'Set' : 'Not set (optional)');
  console.log('CROWDIN_PASSWORD:', CROWDIN_PASSWORD ? 'Set' : 'Not set (optional)');
  console.log('CROWDIN_2FA_SECRET:', CROWDIN_2FA_SECRET ? 'Set' : 'Not set (2FA disabled)');

  if (!CROWDIN_PROJECT_ID || !CROWDIN_PERSONAL_TOKEN) {
    throw new Error('Missing required environment variables: CROWDIN_PROJECT_ID, CROWDIN_PERSONAL_TOKEN');
  }

  const browser = await chromium.launch({
    headless: true,
  });

  const context = await browser.newContext({
    viewport: { width: 1920, height: 1080 },
    userAgent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
  });

  const page = await context.newPage();

  const results = {
    success: [],
    failed: [],
  };

  try {
    await page.goto('https://circuitverse.org');
    
    try {
      await page.waitForLoadState('networkidle', { timeout: 30000 });
    } catch (e) {
      console.log('[WARN] Network idle timeout for initial page, proceeding anyway...');
    }

    const crowdinAvailable = await page.evaluate(() => {
      return typeof window.jipt !== 'undefined';
    });

    if (crowdinAvailable && CROWDIN_USERNAME && CROWDIN_PASSWORD) {
      console.log('[OK] Crowdin in-context localization detected');

      try {
        const loginFrameLocator = page.locator('#jipt-login-panel iframe');
        if (await loginFrameLocator.count() > 0) {
          const loginFrame = await loginFrameLocator.contentFrame();
          await loginFrame.getByRole('button', { name: 'Log In' }).click({ timeout: 5000 });

          await page.getByLabel('Email or Username').fill(CROWDIN_USERNAME);
          await page.getByLabel('Password').fill(CROWDIN_PASSWORD);
          await page.getByRole('button', { name: 'Log In' }).click();

          // Handle 2FA if required
          await handle2FA(page);

          try {
            await page.getByRole('button', { name: 'Keep Me Logged In' }).click({ timeout: 5000 });
          } catch (e) {
            console.log('[INFO] No "Keep Me Logged In" button found');
          }

          console.log('[OK] Logged in to Crowdin');
        }
      } catch (e) {
        console.log('[INFO] Crowdin login not required or failed, proceeding with screenshot capture');
      }
    }

    const screenshotDir = path.join(__dirname, 'screenshots');
    await fs.promises.mkdir(screenshotDir, { recursive: true });

    // Capture all page screenshots
    for (const pageInfo of pages) {
      const success = await captureAndUploadScreenshot(page, pageInfo, screenshotDir);
      if (success) {
        results.success.push(pageInfo.name);
      } else {
        results.failed.push(pageInfo.name);
      }
    }

    // Capture simulator interactive screenshot
    const simSuccess = await captureSimulatorPage(page, screenshotDir);
    if (simSuccess) {
      results.success.push('Simulator_Interactive');
    } else {
      results.failed.push('Simulator_Interactive');
    }

    // Print summary
    console.log('\n[SUMMARY]');
    console.log(`Successfully uploaded: ${results.success.length}`);
    console.log(`Failed: ${results.failed.length}`);

    if (results.failed.length > 0) {
      console.log('\nFailed screenshots:');
      results.failed.forEach(name => console.log(`  - ${name}`));
    }

    console.log('\n[DONE] Screenshot capture process completed!');

  } finally {
    await browser.close();
  }

  return results;
}

if (require.main === module) {
  captureScreenshots()
    .then(results => {
      if (results.failed.length > 0) {
        process.exit(1);
      }
    })
    .catch(err => {
      console.error('Fatal error:', err);
      process.exit(1);
    });
}

module.exports = { captureScreenshots };
