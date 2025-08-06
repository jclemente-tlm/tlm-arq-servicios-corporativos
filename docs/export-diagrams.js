const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const PNG_FORMAT = 'png';
const SVG_FORMAT = 'svg';
const IMAGE_VIEW_TYPE = 'Image';

// Validación de parámetros
if (process.argv.length < 4) {
  console.log("Usage: node export-diagrams.js <structurizrLiteUrl> <png|svg> <outputDir>");
  process.exit(1);
}

const url = process.argv[2];
const format = process.argv[3];
const outputDir = process.argv[4] || '.';

if (format !== PNG_FORMAT && format !== SVG_FORMAT) {
  console.log("The output format must be '" + PNG_FORMAT + "' or '" + SVG_FORMAT + "'.");
  process.exit(1);
}

// Normaliza el outputDir para evitar duplicados
const staticDiagramsDir = path.resolve(outputDir);
if (!fs.existsSync(staticDiagramsDir)) {
  fs.mkdirSync(staticDiagramsDir, { recursive: true });
  console.log(" - Output directory created: " + staticDiagramsDir);
}

(async () => {
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  // Abrir página de diagramas (Structurizr Lite)
  console.log(" - Opening " + url);
  await page.goto(url, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction('structurizr.scripting && structurizr.scripting.isDiagramRendered() === true');

  // Obtener vistas
  const views = await page.evaluate(() => structurizr.scripting.getViews());

  // Filtrar solo diagramas principales (sin -key)
  const mainViews = views.filter(view => !view.key.endsWith('-key'));

  console.log(` - Exportando ${mainViews.length} diagramas a ${staticDiagramsDir}`);

  for (let i = 0; i < mainViews.length; i++) {
    const view = mainViews[i];
    const diagramFilename = view.key + (format === SVG_FORMAT ? '.svg' : '.png');
    const fullPath = path.join(staticDiagramsDir, diagramFilename);

    // Cambia a la vista actual
    await page.evaluate((key) => structurizr.scripting.changeView(key), view.key);
    await page.waitForTimeout(500); // Espera breve para renderizado

    if (format === SVG_FORMAT) {
      const svgForDiagram = await page.evaluate(() => {
        return structurizr.scripting.exportCurrentDiagramToSVG({ includeMetadata: true });
      });
      fs.writeFileSync(fullPath, svgForDiagram);
      console.log(" - " + fullPath);
    } else {
      const pngData = await page.evaluate(() => {
        return new Promise(resolve => {
          structurizr.scripting.exportCurrentDiagramToPNG({ includeMetadata: true, crop: false }, function (png) {
            resolve(png);
          });
        });
      });
      const base64Data = pngData.replace(/^data:image\/png;base64,/, "");
      fs.writeFileSync(fullPath, base64Data, 'base64');
      console.log(" - " + fullPath);
    }
  }

  await browser.close();
  console.log(" - Exportación finalizada");
})();
