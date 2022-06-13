const puppeteer = require('puppeteer');
const { createCursor } = require("ghost-cursor");

const { PuppeteerScreenRecorder } = require("puppeteer-screen-recorder");
const {installMouseHelper} = require('./install-mouse-helper.js');

const waitTillHTMLRendered = async (page, timeout = 30000) => {
  const checkDurationMsecs = 1000;
  const maxChecks = timeout / checkDurationMsecs;
  let lastHTMLSize = 0;
  let checkCounts = 1;
  let countStableSizeIterations = 0;
  const minStableSizeIterations = 3;

  while(checkCounts++ <= maxChecks){
    let html = await page.content();
    let currentHTMLSize = html.length; 

    let bodyHTMLSize = await page.evaluate(() => document.body.innerHTML.length);

    if(lastHTMLSize != 0 && currentHTMLSize == lastHTMLSize) 
      countStableSizeIterations++;
    else 
      countStableSizeIterations = 0; //reset the counter

    if(countStableSizeIterations >= minStableSizeIterations) {
      break;
    }

    lastHTMLSize = currentHTMLSize;
    await page.waitForTimeout(checkDurationMsecs);
  }  
};

var TOKEN=(process.argv.slice(2))[0];
if ( !TOKEN ) {
    throw "Please provide a Jenkins password as the first argument";
}

const Config = {
  followNewTab: true,
  fps: 30,
  ffmpeg_Path: 'ffmpeg' || null,
  videoFrame: {
    width: 1920,
    height: 1080
  },
  aspectRatio: '16:9'
};

(async () => {
    const browser = await puppeteer.launch({
      //args: ["--no-sandbox", "--disabled-setupid-sandbox","--enable-font-antialiasing", "--high-dpi-support=1", "--font-render-hinting=none","--disable-gpu","--force-color-profile=srgb"],
      // args: ["--no-sandbox", "--disabled-setupid-sandbox", "--font-render-hinting=none","--disable-gpu","--force-color-profile=srgb"],
      args: ["--enable-automation","--no-sandbox", "--disabled-setupid-sandbox", "--enable-font-antialiasing","--font-render-hinting=medium","--disable-gpu","--force-color-profile=srgb","--window-size=1920,1080"],
      //executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
      slowMo: 0,
      headless : true
    });

    const page = await browser.newPage();
    await page.setUserAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36");
    const cursor = createCursor(page);
    await installMouseHelper(page); // Install Mouse Helper
    await page.setViewport({ width: 1920, height: 1080 });
    const timeout = 20000;
    page.setDefaultTimeout(timeout);
    const recorder = new PuppeteerScreenRecorder(page, Config);
    await recorder.start("screenrecording.mp4");

    async function waitForSelectors(selectors, frame, options) {
      for (const selector of selectors) {
        try {
          return await waitForSelector(selector, frame, options);
        } catch (err) {
          console.error(err);
        }
      }
      throw new Error('Could not find element for selectors: ' + JSON.stringify(selectors));
    }

    async function scrollIntoViewIfNeeded(element, timeout) {
      await waitForConnected(element, timeout);
      const isInViewport = await element.isIntersectingViewport({threshold: 0});
      if (isInViewport) {
        return;
      }
      await element.evaluate(element => {
        element.scrollIntoView({
          block: 'center',
          inline: 'center',
          behavior: 'auto',
        });
      });
      await waitForInViewport(element, timeout);
    }

    async function waitForConnected(element, timeout) {
      await waitForFunction(async () => {
        return await element.getProperty('isConnected');
      }, timeout);
    }

    async function waitForInViewport(element, timeout) {
      await waitForFunction(async () => {
        return await element.isIntersectingViewport({threshold: 0});
      }, timeout);
    }

    async function waitForSelector(selector, frame, options) {
      if (!Array.isArray(selector)) {
        selector = [selector];
      }
      if (!selector.length) {
        throw new Error('Empty selector provided to waitForSelector');
      }
      let element = null;
      for (let i = 0; i < selector.length; i++) {
        const part = selector[i];
        if (element) {
          element = await element.waitForSelector(part, options);
        } else {
          element = await frame.waitForSelector(part, options);
        }
        if (!element) {
          throw new Error('Could not find element: ' + selector.join('>>'));
        }
        if (i < selector.length - 1) {
          element = (await element.evaluateHandle(el => el.shadowRoot ? el.shadowRoot : el)).asElement();
        }
      }
      if (!element) {
        throw new Error('Could not find element: ' + selector.join('|'));
      }
      return element;
    }

    async function waitForElement(step, frame, timeout) {
      const count = step.count || 1;
      const operator = step.operator || '>=';
      const comp = {
        '==': (a, b) => a === b,
        '>=': (a, b) => a >= b,
        '<=': (a, b) => a <= b,
      };
      const compFn = comp[operator];
      await waitForFunction(async () => {
        const elements = await querySelectorsAll(step.selectors, frame);
        return compFn(elements.length, count);
      }, timeout);
    }

    async function querySelectorsAll(selectors, frame) {
      for (const selector of selectors) {
        const result = await querySelectorAll(selector, frame);
        if (result.length) {
          return result;
        }
      }
      return [];
    }

    async function querySelectorAll(selector, frame) {
      if (!Array.isArray(selector)) {
        selector = [selector];
      }
      if (!selector.length) {
        throw new Error('Empty selector provided to querySelectorAll');
      }
      let elements = [];
      for (let i = 0; i < selector.length; i++) {
        const part = selector[i];
        if (i === 0) {
          elements = await frame.$$(part);
        } else {
          const tmpElements = elements;
          elements = [];
          for (const el of tmpElements) {
            elements.push(...(await el.$$(part)));
          }
        }
        if (elements.length === 0) {
          return [];
        }
        if (i < selector.length - 1) {
          const tmpElements = [];
          for (const el of elements) {
            const newEl = (await el.evaluateHandle(el => el.shadowRoot ? el.shadowRoot : el)).asElement();
            if (newEl) {
              tmpElements.push(newEl);
            }
          }
          elements = tmpElements;
        }
      }
      return elements;
    }

    async function waitForFunction(fn, timeout) {
      let isActive = true;
      setTimeout(() => {
        isActive = false;
      }, timeout);
      while (isActive) {
        const result = await fn();
        if (result) {
          return;
        }
        await new Promise(resolve => setTimeout(resolve, 100));
      }
      throw new Error('Timed out');
    }
    {
        console.log("Set Viewport to 1080p");
        const targetPage = page;
        await targetPage.setViewport({"width":1920,"height":1080})
    }
    {
        console.log("Goto login URL");
        const targetPage = page;
        const promises = [];
        promises.push(targetPage.waitForNavigation());
        await targetPage.goto("https://login.ves.volterra.io/auth/realms/f5-amer-ent-qyyfhhfj/protocol/openid-connect/auth?state=05ac22aa-1bec-4f3f-87af-134893790d75&nonce=22f5b7f4-f9a5-455d-9709-6babff6bf091&response_type=code&client_id=ves-oidc-f5-amer-ent-qyyfhhfj&scope=openid%20profile&redirect_uri=https://f5-amer-ent.console.ves.volterra.io/",{waitUntil: 'networkidle0'});
        // await targetPage.goto("https://login.ves.volterra.io/auth/realms/f5-amer-ent-qyyfhhfj/protocol/openid-connect/auth?response_type=code&client_id=ves-oidc-f5-amer-ent-qyyfhhfj&scope=openid%20profile&redirect_uri=https://f5-amer-ent.console.ves.volterra.io/");
       //  await targetPage.goto("https://f5-amer-ent.console.ves.volterra.io/");
        await waitTillHTMLRendered(targetPage);
        await Promise.all(promises);
    }
    {
        // Click Sign in with Azure
        console.log("Click Sign in");
        const targetPage = page;
        const promises = [];
        promises.push(targetPage.waitForNavigation());
        const element = await waitForSelectors([["aria/Sign in with Azure","aria/[role=\"generic\"]"],["#new-zocial-azure-oidc > span"]], targetPage, { timeout: 20000, visible: true });
        await scrollIntoViewIfNeeded(element, timeout);
        await cursor.click(element);
        //await waitTillHTMLRendered(targetPage);
        await targetPage.waitForTimeout(2000);
        await Promise.all(promises);
    }
/*
    {
        console.log("Click username field in login form");
        const targetPage = page;
        const element = await waitForSelectors([["aria/Enter your email, phone, or Skype."],["#i0116"]], targetPage, { timeout, visible: true });
        await scrollIntoViewIfNeeded(element, timeout);
        await cursor.click(element);
    }
*/
    {
        console.log("Enter email address in login form");
        const targetPage = page;
        const element = await waitForSelectors([["aria/Enter your email, phone, or Skype."],["#i0116"]], targetPage, { timeout, visible: true });
        await scrollIntoViewIfNeeded(element, timeout);
        const type = await element.evaluate(el => el.type);
        if (["textarea","select-one","text","url","tel","search","password","number","email"].includes(type)) {
          await element.type("r.mordasiewicz@f5.com");
        } else {
          await element.focus();
          await element.evaluate((el, value) => {
            el.value = value;
            el.dispatchEvent(new Event('input', { bubbles: true }));
            el.dispatchEvent(new Event('change', { bubbles: true }));
          }, "r.mordasiewicz@f5.com");
        }
    }
    {
        console.log("Click Next after entering email address");
        const targetPage = page;
        const element = await waitForSelectors([["aria/Next"],["#idSIButton9"]], targetPage, { timeout, visible: true });
        await scrollIntoViewIfNeeded(element, timeout);
        await cursor.click(element);
        await waitTillHTMLRendered(targetPage);
        await targetPage.waitForTimeout(2000);
    }
/*
    {
        console.log("Click password form field");
        const targetPage = page;
        const element = await waitForSelectors(["#i0118"], targetPage, { timeout, visible: true });
        await scrollIntoViewIfNeeded(element, timeout);
        await cursor.click(element);
    }
*/
    {
        console.log("Enter password into form");
        const targetPage = page;
        const element = await waitForSelectors([["aria/Enter the password for r.mordasiewicz@f5.com"],["#i0118"]], targetPage, { timeout, visible: true });
        await scrollIntoViewIfNeeded(element, timeout);
        const type = await element.evaluate(el => el.type);
        if (["textarea","select-one","text","url","tel","search","password","number","email"].includes(type)) {
          await element.type(TOKEN);
        } else {
          await element.focus();
          await element.evaluate((el, value) => {
            el.value = value;
            el.dispatchEvent(new Event('input', { bubbles: true }));
            el.dispatchEvent(new Event('change', { bubbles: true }));
          }, TOKEN);
        }
    }
    {
        console.log("Click Sign In - DUO Approval");
        const targetPage = page;
        const element = await waitForSelectors([["aria/Sign in"],["#idSIButton9"]], targetPage, { timeout, visible: true });
        await scrollIntoViewIfNeeded(element, timeout);
        await cursor.click(element);
        await targetPage.waitForTimeout(4000);
    }
    {
        console.log("Click Yes to continue");
        console.log("Timeout is long to wait for DUO approval");
        const targetPage = page;
        const element = await waitForSelectors([["aria/Yes"],["#idSIButton9"]], targetPage, { timeout: 120000, visible: true });
        await scrollIntoViewIfNeeded(element, timeout);
        await cursor.click(element);
       // await waitTillHTMLRendered(targetPage);
        // await targetPage.waitForTimeout(2000);
    }
/*
*/
    await page.waitForTimeout(10000);
    await recorder.stop();
    await browser.close();
})();
