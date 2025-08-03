#!/usr/bin/env python3

import re

# Leer el archivo
with open('design/systems/sita-messaging/sita-messaging-models.dsl', 'r') as f:
    content = f.read()

# Patrón para encontrar líneas con "-> this" con espacios antes
pattern = r'^\s+\w+\s*->\s*this\s+.*$'

# Eliminar todas las líneas que contengan "-> this"
lines = content.split('\n')
cleaned_lines = []

for line in lines:
    if not re.match(pattern, line):
        cleaned_lines.append(line)

# Escribir el archivo limpio
with open('design/systems/sita-messaging/sita-messaging-models.dsl', 'w') as f:
    f.write('\n'.join(cleaned_lines))

print("Relaciones internas eliminadas")
