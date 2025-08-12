#! /bin/bash

node ./export-diagrams.js http://localhost:8090/workspace/diagrams png ./diagrams/servicios-corporativos

# Eliminar imágenes con sufijo -key.png
target_dir=./diagrams/servicios-corporativos
find "$target_dir" -type f -name '*-key.png' -delete