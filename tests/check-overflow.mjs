// Check that every slide fits on the page.
//
// Fails (exit code 1) if any slide has content below or to the right of the
// slide, or a code block that needs its own scrollbar. Such content is cut
// off when presenting, and missing from the PDF.
//
// Runs inside the astefanutti/decktape container, which has Chromium and
// Puppeteer:
//   docker run --rm -v "$PWD/presentation/_html":/slides -v "$PWD/tests":/tests \
//     --entrypoint node astefanutti/decktape /tests/check-overflow.mjs /slides/index.html

import { createRequire } from 'module';
const require = createRequire('/decktape/package.json');
const puppeteer = require('puppeteer');

const file = process.argv[2] || '/slides/index.html';

const browser = await puppeteer.launch({
  executablePath: '/usr/bin/chromium-browser',
  args: ['--no-sandbox', '--disable-gpu'],
});
const page = await browser.newPage();
await page.setViewport({ width: 1280, height: 720 });
await page.goto('file://' + file, { waitUntil: 'networkidle0' });
await page.waitForFunction('window.Reveal && Reveal.isReady()');

const n = await page.evaluate(() => Reveal.getSlides().length);
let failures = 0;

for (let i = 0; i < n; i++) {
  await page.evaluate((i) => {
    const idx = Reveal.getIndices(Reveal.getSlides()[i]);
    Reveal.slide(idx.h, idx.v, 99); // 99: show all fragments
  }, i);
  await new Promise((r) => setTimeout(r, 200));

  const res = await page.evaluate((i) => {
    const s = Reveal.getSlides()[i];
    const { width, height } = Reveal.getConfig();
    const heading = s.querySelector('h1, h2, h3');
    const title = heading ? heading.textContent.trim() : '(no title)';
    const issues = [];
    if (s.scrollHeight > height + 1) {
      issues.push(`too tall: ${s.scrollHeight}px > ${height}px`);
    }
    if (s.scrollWidth > width + 1) {
      issues.push(`too wide: ${s.scrollWidth}px > ${width}px`);
    }
    s.querySelectorAll('pre, pre code, table').forEach((el) => {
      if (el.scrollHeight > el.clientHeight + 1 && el.clientHeight > 0) {
        issues.push(`${el.tagName.toLowerCase()} scrolls vertically: ${el.scrollHeight}px > ${el.clientHeight}px`);
      }
      if (el.scrollWidth > el.clientWidth + 1 && el.clientWidth > 0) {
        issues.push(`${el.tagName.toLowerCase()} scrolls horizontally: ${el.scrollWidth}px > ${el.clientWidth}px`);
      }
    });
    // anything (e.g., an image) extending past the bottom of the slide
    const box = s.getBoundingClientRect();
    const scale = box.width / width;
    s.querySelectorAll('img, pre, table, p, li').forEach((el) => {
      const r = el.getBoundingClientRect();
      if (r.height > 0 && r.bottom > box.top + height * scale + 2) {
        issues.push(`${el.tagName.toLowerCase()} ends ${Math.round((r.bottom - box.top) / scale)}px below top (> ${height}px)`);
      }
    });
    return { title, issues: [...new Set(issues)], h: Reveal.getIndices(s).h, v: Reveal.getIndices(s).v || 0 };
  }, i);

  const where = `slide ${i + 1} (${res.h}/${res.v}) "${res.title}"`;
  if (res.issues.length > 0) {
    failures++;
    console.log(`FAIL ${where}`);
    res.issues.forEach((x) => console.log(`     - ${x}`));
  } else {
    console.log(`ok   ${where}`);
  }
}

await browser.close();
console.log(`\n${n} slides checked, ${failures} with overflow.`);
process.exit(failures > 0 ? 1 : 0);
