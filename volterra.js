const puppeteer = require('puppeteer');
const { createCursor } = require("ghost-cursor");
const {installMouseHelper} = require('./install-mouse-helper.js');

(async () => {
    console.log("Start the Browser");
    const browser = await puppeteer.launch({
       // args: ["--disable-dev-shm-usage","--user-data-dir=./.chrome","--start-fullscreen","--kiosk","--disable-session-crashed-bubble","--noerrdialogs","--no-default-browser-check","--useAutomationExtension","--disable-infobars","--ignore-certificate-errors","--start-maximized","--enable-automation","--no-sandbox", "--disabled-setupid-sandbox", "--enable-font-antialiasing","--font-render-hinting=none","--disable-gpu","--force-color-profile=srgb","--window-size=1664,936","--hide-scrollbars","--high-dpi-support=1","--force-device-scale-factor=1"],
       //args: ["--disable-dev-shm-usage","--user-data-dir=./.chrome","--start-fullscreen","--kiosk","--disable-session-crashed-bubble","--noerrdialogs","--no-default-browser-check","--useAutomationExtension","--disable-infobars","--ignore-certificate-errors","--start-maximized","--enable-automation","--no-sandbox", "--disabled-setupid-sandbox", "--enable-font-antialiasing","--font-render-hinting=medium","--disable-gpu","--force-color-profile=srgb","--window-size=1664,936","--hide-scrollbars"],
       args: ["--disable-dev-shm-usage","--user-data-dir=./.chrome","--start-fullscreen","--kiosk","--disable-session-crashed-bubble","--noerrdialogs","--no-default-browser-check","--useAutomationExtension","--disable-infobars","--ignore-certificate-errors","--start-maximized","--enable-automation","--no-sandbox", "--disabled-setupid-sandbox", "--enable-font-antialiasing","--font-render-hinting=full","--disable-gpu","--force-color-profile=generic-rgb","--window-size=1664,936","--hide-scrollbars"],
      //executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
      //executablePath: '/opt/google/chrome-unstable/google-chrome-unstable',
      slowMo: 0,
      //ignoreDefaultArgs: ["--enable-automation","--enable-blink-features=IdleDetection"],
      ignoreDefaultArgs: ["--enable-automation"],
      ignoreHTTPSErrors: true,
      headless : false
    });

    console.log("Get a page handler");
    //const context = await browser.createIncognitoBrowserContext();
    //const page = await context.newPage();
    const page = await browser.newPage();
    console.log("Set the user agent");
    await page.setUserAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36");
    const cursor = createCursor(page);
    console.log("Install mouse helper");
    await installMouseHelper(page);
    console.log("Set page Viewport");
    await page.setViewport({ width: 1664, height: 936 });
    console.log("define a timeout variable for 70 seconds");
    const timeout = 70000;
    console.log("set default timeout on page");
    page.setDefaultTimeout(timeout);
    console.log("Pause for 5 seconds");
    await page.waitForTimeout(5000);

    {
        console.log("Set Viewport to 936p");
        const targetPage = page;
        await targetPage.setViewport({"width":1664,"height":936})
    }
    {
        console.log("Goto login URL");
        const targetPage = page;
        const promises = [];
        promises.push(targetPage.waitForNavigation());
        await targetPage.goto("https://f5-amer-ent.console.ves.volterra.io/", {waitUntil: 'networkidle0'});
        await Promise.all(promises);
    }

    console.log("Closing the browser");
    await browser.close();
    console.log("exit puppeteer script");
    process.exit(0);
})();

