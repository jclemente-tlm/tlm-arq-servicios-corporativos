const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const PNG_FORMAT = 'png';
const SVG_FORMAT = 'svg';

const IGNORE_HTTPS_ERRORS = true;
const HEADLESS = true;
const IMAGE_VIEW_TYPE = 'Image';

// Validación de parámetros
if (process.argv.length < 4) {
  console.log("Usage: node export-diagrams.js <structurizrUrl> <png|svg> <outputDir> [username] [password]");
  process.exit(1);
}

const url = process.argv[2];
const format = process.argv[3];
const outputDir = process.argv[4] || '.';
const username = process.argv[5];
const password = process.argv[6];

if (format !== PNG_FORMAT && format !== SVG_FORMAT) {
  console.log("The output format must be '" + PNG_FORMAT + "' or '" + SVG_FORMAT + "'.");
  process.exit(1);
}

// Crear carpeta si no existe
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
  console.log(" - Output directory created: " + outputDir);
}

let expectedNumberOfExports = 0;
let actualNumberOfExports = 0;

(async () => {
  const browser = await puppeteer.launch({ ignoreHTTPSErrors: IGNORE_HTTPS_ERRORS, headless: HEADLESS });
  const page = await browser.newPage();

  // Login si hay credenciales
  if (username && password) {
    const parts = url.split('://');
    const signinUrl = parts[0] + '://' + parts[1].substring(0, parts[1].indexOf('/')) + '/dashboard';
    console.log(' - Signing in via ' + signinUrl);

    await page.goto(signinUrl, { waitUntil: 'networkidle2' });
    await page.type('#username', username);
    await page.type('#password', password);
    await page.keyboard.press('Enter');
    await page.waitForSelector('div#dashboard');
  }

  // Abrir página de diagramas
  console.log(" - Opening " + url);
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction('structurizr.scripting && structurizr.scripting.isDiagramRendered() === true');

  if (format === PNG_FORMAT) {
    // función para guardar PNG
    await page.exposeFunction('savePNG', (content, filename) => {
      const fullPath = path.join(outputDir, filename);
      console.log(" - " + fullPath);
      content = content.replace(/^data:image\/png;base64,/, "");
      fs.writeFile(fullPath, content, 'base64', function (err) {
        if (err) throw err;
      });

      actualNumberOfExports++;
      if (actualNumberOfExports === expectedNumberOfExports) {
        console.log(" - Finished");
        browser.close();
      }
    });
  }

  // Obtener vistas
  const views = await page.evaluate(() => structurizr.scripting.getViews());

  views.forEach(view => {
    expectedNumberOfExports += (view.type === IMAGE_VIEW_TYPE) ? 1 : 2;
  });

  console.log(" - Starting export");
  for (let i = 0; i < views.length; i++) {
    const view = views[i];

    await page.evaluate((view) => {
      structurizr.scripting.changeView(view.key);
    }, view);

    await page.waitForFunction('structurizr.scripting.isDiagramRendered() === true');

    if (format === SVG_FORMAT) {
      const diagramFilename = path.join(outputDir, view.key + '.svg');
      const diagramKeyFilename = path.join(outputDir, view.key + '-key.svg');

      const svgForDiagram = await page.evaluate(() => {
        return structurizr.scripting.exportCurrentDiagramToSVG({ includeMetadata: true });
      });

      console.log(" - " + diagramFilename);
      fs.writeFile(diagramFilename, svgForDiagram, function (err) {
        if (err) throw err;
      });
      actualNumberOfExports++;

      if (view.type !== IMAGE_VIEW_TYPE) {
        const svgForKey = await page.evaluate(() => {
          return structurizr.scripting.exportCurrentDiagramKeyToSVG();
        });

        console.log(" - " + diagramKeyFilename);
        fs.writeFile(diagramKeyFilename, svgForKey, function (err) {
          if (err) throw err;
        });
        actualNumberOfExports++;
      }

      if (actualNumberOfExports === expectedNumberOfExports) {
        console.log(" - Finished");
        browser.close();
      }
    } else {
      const diagramFilename = view.key + '.png';
      const diagramKeyFilename = view.key + '-key.png';

      page.evaluate((diagramFilename) => {
        structurizr.scripting.exportCurrentDiagramToPNG({ includeMetadata: true, crop: false }, function (png) {
          window.savePNG(png, diagramFilename);
        });
      }, diagramFilename);

      if (view.type !== IMAGE_VIEW_TYPE) {
        page.evaluate((diagramKeyFilename) => {
          structurizr.scripting.exportCurrentDiagramKeyToPNG(function (png) {
            window.savePNG(png, diagramKeyFilename);
          });
        }, diagramKeyFilename);
      }
    }
  }
})();
