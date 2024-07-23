## Documentación de FileTreeGen

### Introducción

**FileTreeGen** es un programa desarrollado en AutoHotkey v2.0 que permite generar un árbol de archivos y los contenidos de archivos de tipos específicos dentro de una carpeta seleccionada. Proporciona una interfaz gráfica (GUI) para facilitar la selección de carpetas y la generación de la estructura de directorios y el contenido de los archivos.

### Funcionalidades Principales

- Selección de carpetas mediante un diálogo o arrastrando y soltando.
- Generación de la estructura de directorios.
- Extracción del contenido de archivos con extensiones permitidas.
- Combinación de la estructura de directorios y contenido de archivos en un solo archivo de salida.
- Copia del resultado final al portapapeles para facilitar su uso.

### Requisitos

- AutoHotkey v2.0 o superior (si se usa el script .ah2).
- Archivo `AllowedExtensions.txt` que contiene las extensiones permitidas.
- Carpeta de destino con los archivos a procesar.

### Estructura de Archivos

La estructura de archivos del proyecto es la siguiente:

```
Files
│   AllowedExtensions.txt
│   FileTreeGen.ah2
│   FileTreeGen.exe
│   FileTreeGen.ico
│   output.tree
│   README.md
│
└───tests
    └───1
        │   1.txt
        │
        ├───a
        │       a.txt
        │
        ├───b
        │       b.txt
        │
        ├───c
        │       c.exe
        │
        └───d
                d.txt
```

### Contenido de los Archivos

#### AllowedExtensions.txt

Este archivo contiene las extensiones de archivos permitidas para la extracción de contenidos. El contenido es el siguiente:

```
# Archivos de texto
txt
md
csv
log
ini

# Lenguajes de programación
ahk
ah2
py
java
cpp
js
html
css
json
xml
rb
php
sh
bat
ps1

# Archivos de configuración y otros
conf
cfg
toml
yaml
yml
properties
```

#### FileTreeGen.ah2

Este es el archivo principal del programa escrito en AutoHotkey v2.0. El contenido incluye varias secciones de código que manejan la GUI, la generación del árbol de directorios, la extracción de contenidos de archivos y la combinación de resultados.

### Secciones del Código

#### Variables Globales

Variables para almacenar el nombre del programa, los archivos requeridos, archivos temporales y una bandera para evitar ejecuciones concurrentes.

#### Configuración del Entorno

Configuraciones relacionadas con la ejecución del script, como la limitación de teclas y deshabilitación de ciertas características de depuración.

#### Gestión de la GUI

Funciones para crear y gestionar la interfaz gráfica del usuario, que permite seleccionar una carpeta y generar el árbol de archivos y el contenido de archivos.

#### Funciones de Utilidad

Funciones auxiliares para normalizar rutas, validar carpetas, leer extensiones permitidas, generar nombres de archivos temporales y mostrar mensajes en pantalla.

#### Gestión del Proceso

Funciones para inicializar el script, verificar si el proceso de generación está en curso y procesar la carpeta seleccionada.

#### Generación del Árbol de Directorios

Funciones para generar el árbol de archivos de la carpeta seleccionada utilizando PowerShell y procesar el resultado para eliminar líneas innecesarias.

#### Generación de Contenidos de Archivos

Funciones para extraer el contenido de archivos con extensiones permitidas y combinar estos contenidos en un archivo temporal.

#### Gestión de Archivos

Funciones para eliminar archivos si existen y unir los archivos temporales en uno solo según los checkboxes activados en la GUI. También incluye la copia del contenido final al portapapeles.

### Ejecución del Programa

Para ejecutar el programa, tiene dos opciones:

1. **Usar el Archivo Ejecutable**: Ejecute `FileTreeGen.exe` directamente. No se requiere la instalación de AutoHotkey. La GUI se mostrará permitiendo la selección de una carpeta y la generación del árbol de archivos y contenidos de archivos.

2. **Usar el Script en AutoHotkey**: Asegúrese de tener AutoHotkey v2.0 instalado y ejecute `FileTreeGen.ah2`. La GUI se mostrará permitiendo la selección de una carpeta y la generación del árbol de archivos y contenidos de archivos.

### Ejemplo de Uso

1. **Seleccione una Carpeta**: Puede arrastrar una carpeta a la GUI o seleccionarla manualmente utilizando el botón "Seleccionar Carpeta".
2. **Generar Estructura y Contenido**: Asegúrese de que las casillas "Directory Tree" y "Files Contents" estén marcadas según lo que desea generar.
3. **Resultado**: El resultado se combinará en un archivo `output.tree` y se copiará al portapapeles para facilitar su uso.

### Archivos de Ejemplo

Ejemplos de archivos de prueba ubicados en la carpeta `tests`:

- `tests\1\1.txt`:

  ```
  Archivo 1
  line 2
  line 3
  ```

- `tests\1\a\a.txt`:

  ```
  Archivo a
  line 2
  line 3
  ```

- `tests\1\b\b.txt`:

  ```
  Archivo b
  line 2
  line 3
  ```

- `tests\1\d\d.txt`:
  ```
  Archivo d
  line 2
  line 3
  ```

Estos archivos de ejemplo permiten probar la funcionalidad del programa y verificar que el contenido y la estructura de los archivos se generan correctamente.

### Conclusión

**FileTreeGen** es una herramienta útil para la generación de estructuras de directorios y la extracción de contenidos de archivos de tipos específicos, facilitando la documentación y el análisis de proyectos.
