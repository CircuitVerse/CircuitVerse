require('dotenv').config();
const { chromium } = require('playwright');
const { authenticator } = require('otplib');
const fs = require('fs');
const path = require('path');
const axios = require('axios');

const CROWDIN_PROJECT_ID = process.env.CROWDIN_PROJECT_ID;
const CROWDIN_PERSONAL_TOKEN = process.env.CROWDIN_PERSONAL_TOKEN;
const CROWDIN_USERNAME = process.env.CROWDIN_USERNAME;
const CROWDIN_PASSWORD = process.env.CROWDIN_PASSWORD;
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
    console.log(`📤 Uploading ${fileName} to Crowdin storage...`);

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
      console.log(`✅ Storage upload successful: ${res.data.data.id}`);
      return res.data.data.id;
    } else {
      console.error('❌ Crowdin did not return a storage ID:', res.data);
      return null;
    }
  } catch (err) {
    console.error('❌ Error uploading to Crowdin storage:');
    if (err.response) {
      console.error('Status:', err.response.status);
      console.error('Details:', JSON.stringify(err.response.data, null, 2));
    } else {
      console.error('Message:', err.message);
    }
    return null;
  }
}

async function uploadScreenshotToCrowdin(storageId, name) {
  try {
    console.log(`📤 Creating screenshot record for ${name}...`);

    const screenshotName = `${name}.png`;

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

    console.log(`✅ Screenshot record created for ${name}`);
    return res.data;
  } catch (err) {
    console.error(`❌ Error creating screenshot record for ${name}:`);
    if (err.response) {
      console.error('Status:', err.response.status);
      console.error('Details:', JSON.stringify(err.response.data, null, 2));
    } else {
      console.error('Message:', err.message);
    }
    throw err;
  }
}

async function captureScreenshots() {
  console.log('🚀 Starting Crowdin screenshot capture process...');

  console.log('Environment variables:');
  console.log('CROWDIN_PROJECT_ID:', process.env.CROWDIN_PROJECT_ID ? '✅ Set' : '❌ Missing');
  console.log('CROWDIN_PERSONAL_TOKEN:', process.env.CROWDIN_PERSONAL_TOKEN ? '✅ Set' : '❌ Missing');
  console.log('CROWDIN_USERNAME:', process.env.CROWDIN_USERNAME ? '✅ Set' : '❌ Missing');
  console.log('CROWDIN_PASSWORD:', process.env.CROWDIN_PASSWORD ? '✅ Set' : '❌ Missing');

  if (!CROWDIN_PROJECT_ID || !CROWDIN_PERSONAL_TOKEN) {
    console.error('Missing environment variables:');
    console.error('CROWDIN_PROJECT_ID:', CROWDIN_PROJECT_ID || 'MISSING');
    console.error('CROWDIN_PERSONAL_TOKEN:', CROWDIN_PERSONAL_TOKEN ? 'SET' : 'MISSING');
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

  try {
    await page.goto('https://circuitverse.org');
    await page.waitForLoadState('networkidle');

    const crowdinAvailable = await page.evaluate(() => {
      return typeof window.jipt !== 'undefined';
    });

    if (crowdinAvailable) {
      console.log('✅ Crowdin in-context localization detected');

      try {
        const loginFrameLocator = page.locator('#jipt-login-panel iframe');
        if (await loginFrameLocator.count() > 0) {
          const loginFrame = await loginFrameLocator.contentFrame();
          await loginFrame.getByRole('button', { name: 'Log In' }).click({ timeout: 5000 });

          await page.getByLabel('Email or Username').fill(CROWDIN_USERNAME);
          await page.getByLabel('Password').fill(CROWDIN_PASSWORD);
          await page.getByRole('button', { name: 'Log In' }).click();

          try {
            const tfaField = page.getByLabel('Verification Code');
            if (await tfaField.isVisible({ timeout: 5000 })) {
              console.log('⚠️ 2FA required - please configure your 2FA secret key');
            }
          } catch (e) {
            console.log('ℹ️ No 2FA required');
          }

          try {
            await page.getByRole('button', { name: 'Keep Me Logged In' }).click({ timeout: 5000 });
          } catch (e) {
            console.log('ℹ️ No "Keep Me Logged In" button found');
          }

          console.log('✅ Logged in to Crowdin');
        }
      } catch (e) {
        console.log('ℹ️ Crowdin login not required or failed, proceeding with screenshot capture');
      }
    }

    const screenshotDir = path.join(__dirname, 'screenshots');
    await fs.promises.mkdir(screenshotDir, { recursive: true });

    for (const pageInfo of pages) {
      console.log(`➡️ Capturing: ${pageInfo.name} (${pageInfo.url})`);

      try {
        await page.goto(pageInfo.url, {
          waitUntil: 'domcontentloaded',
          timeout: 30000
        });

        await page.waitForTimeout(2000);

        try {
          await page.waitForLoadState('networkidle', { timeout: 10000 });
        } catch (e) {
          console.log(`⚠️ Network idle timeout for ${pageInfo.name}, proceeding anyway...`);
        }



        const fileName = `${pageInfo.name.replace(/\s+/g, '_').toLowerCase()}.png`;
        const screenshotPath = path.join(screenshotDir, fileName);

        await page.screenshot({
          path: screenshotPath,
          fullPage: true,
          timeout: 30000
        });

        console.log(`✅ Screenshot saved: ${fileName}`);

        const storageId = await uploadToCrowdinStorage(screenshotPath, fileName);
        if (storageId) {
          await uploadScreenshotToCrowdin(storageId, pageInfo.name);
          console.log(`✅ Uploaded to Crowdin: ${pageInfo.name}`);
        } else {
          console.error(`❌ Failed to upload ${pageInfo.name} to Crowdin`);
        }

        if (crowdinAvailable) {
          try {
            await page.evaluate((name) => {
              return new Promise((resolve, reject) => {
                if (window.jipt && window.jipt.capture_screenshot) {
                  window.jipt.capture_screenshot(name, {
                    override: false,
                    success: resolve,
                    error: reject
                  });
                } else {
                  resolve('Crowdin capture not available');
                }
              });
            }, pageInfo.name);
            console.log(`✅ Crowdin in-context capture completed for ${pageInfo.name}`);
          } catch (e) {
            console.log(`⚠️ Crowdin in-context capture failed for ${pageInfo.name}: ${e.message}`);
          }
        }

      } catch (err) {
        console.error(`❌ Failed to process ${pageInfo.name}: ${err.message}`);
        continue;
      }
    }

    await captureSimulatorPage(page);

    console.log('🎉 Screenshot capture process completed!');

  } finally {
    await browser.close();
  }
}

async function captureSimulatorPage(page) {
  console.log('🔧 Capturing simulator page with interactions...');

  try {
    await page.goto('https://circuitverse.org/simulator');
    await page.waitForLoadState('networkidle');

    await page.waitForTimeout(3000);

    const screenshotPath = path.join(__dirname, 'screenshots', 'simulator_interactive.png');
    await page.screenshot({
      path: screenshotPath,
      fullPage: true,
    });

    console.log('✅ Simulator screenshot captured');
  } catch (err) {
    console.error(`❌ Failed to capture simulator page: ${err.message}`);
  }
}

if (require.main === module) {
  captureScreenshots().catch(console.error);
}

module.exports = { captureScreenshots };
