## Índice de la Documentación de FileTreeGen v1.5

- [Introducción](#introducción)
- [Funcionalidades Principales](#funcionalidades-principales)
- [Requisitos](#requisitos)
- [Estructura de Archivos](#estructura-de-archivos)
- [Contenido de los Archivos](#contenido-de-los-archivos)
  - [FilesContents.conf](#filescontentsconf)
- [Resumen del Código](#resumen-del-código)
- [Ejecución del Programa](#ejecución-del-programa)
- [Ejemplo de Uso](#ejemplo-de-uso)
- [Archivos de Ejemplo](#archivos-de-ejemplo)
- [Notas Adicionales](#notas-adicionales)
- [Conclusión](#conclusión)

### Introducción

**FileTreeGen** es un programa desarrollado en AutoHotkey v2.0.18 que permite generar un árbol de archivos y los contenidos de archivos de tipos específicos dentro de una carpeta seleccionada. Proporciona una interfaz gráfica (GUI) para facilitar la selección de carpetas y la generación de la estructura de directorios y el contenido de los archivos. La versión actual del programa es la **v1.5**.

### Funcionalidades Principales

- Selección de carpetas mediante un diálogo o arrastrando y soltando.
- Generación de la estructura de directorios.
- Extracción del contenido de archivos con extensiones permitidas.
- Combinación de la estructura de directorios y contenido de archivos en un solo archivo de salida.
- Copia del resultado final al portapapeles para facilitar su uso.

### Requisitos

- AutoHotkey v2.0.18 o superior (si se usa el script .ah2).
- Archivo `FilesContents.conf` que contiene las extensiones permitidas y archivos ignorados.
- Carpeta de destino con los archivos a procesar.

### Estructura de Archivos

La estructura de archivos del proyecto es la siguiente:

```tree
FileTreeGen
│   FilesContents.conf
│   FileTreeGen.ah2
│   output.md
│   README.md
│
├───bin
│       FileTreeGen.exe
│       FileTreeGen.ico
│
├───files_tests
│       ..file
│       .1.file
│       .file
│       1..file
│       1.file
│       false
│       file
│       true
│
└───tree_tests
    │   1.txt
    │
    └───1
        │   2.txt
        │
        ├───a
        │       a.txt
        │
        ├───b
        │       b.md
        │
        ├───c
        │       c.exe
        │
        └───d
                d.js
```

### Contenido de los Archivos

#### FilesContents.conf

Este archivo contiene la configuración de las extensiones de archivos permitidas y los archivos que deben ser ignorados durante el procesamiento.

```conf
#*** Configuración para el procesamiento de contenidos de archivos

##? ♦ Extensiones de Archivos Permitidas
#; Define las extensiones de archivo permitidas para el procesamiento.
#; Cada línea debe contener una extensión sin el punto inicial.
#; Se ignoran las líneas que comienzan con "#" y las que contienen un "." (indicando archivos completos).

###* Extensiones de Archivos de Texto
txt
md
csv
log
ini
rtf
tex

###* Extensiones de Lenguajes de Programación
ahk
ah2
py
java
cpp
js
ts
html
css
json
xml
rb
php
sh
bat
ps1
sql

###* Extensiones de Archivos de Configuración y Otros
conf
cfg
toml
yaml
yml
properties

##? ♦ Archivos Ignorados (NO Usar Patrones De Archivos)
#; Define los archivos completos que deben ser ignorados durante el procesamiento.
#; Cada línea debe contener la ruta completa del archivo junto con su extensión.
#; Se pueden usar rutas absolutas y relativas.
#; No se pueden usar patrones de búsqueda o de coincidencia de archivos.
#; Se ignoran las líneas que comienzan con "#".

###* Archivo de Salida Combinado
output.md

##? Tests
#; Extensiones y archivos de pruebas que se encuentran en las carpetas `files_tests` y `tree_tests`.

###* Extensiones de Archivos de Pruebas (files_tests)
#;💹
# file

###* Archivos de Pruebas (files_tests)
#;💹
# ..file
# .1.file
# .file
# 1..file
# 1.file

###* Archivos de Pruebas (tree_tests)
#;💹
# 1.txt
# 1\d\d.js
# .\1\..\1\d\d.js

###! En Desarrollo (Incompatible)
#;⛔
# 1\d\*.js
# 1\d\d.*
# 1\d\*
```

### Resumen del Código

El script de AutoHotkey para FileTreeGen se organiza en varias secciones clave:

- **Variables Globales**: Definición de variables globales para la configuración del programa y archivos temporales.
- **Configuración del Entorno**: Ajustes del entorno de ejecución.
- **Gestión de la GUI**: Funciones para crear y gestionar la interfaz gráfica de usuario.
- **Funciones de Utilidad**: Funciones auxiliares para manejar rutas, validar carpetas y leer configuraciones.
- **Gestión del Proceso**: Funciones para inicializar el script, verificar ejecuciones concurrentes y procesar la carpeta seleccionada.
- **Generación del Árbol de Directorios**: Funciones para crear el árbol de directorios de la carpeta seleccionada.
- **Generación de Contenidos de Archivos**: Funciones para extraer el contenido de los archivos permitidos.
- **Gestión de Archivos**: Funciones para manejar la eliminación y combinación de archivos temporales.

### Ejecución del Programa

Para ejecutar el programa, tiene dos opciones:

1. **Usar el Archivo Ejecutable**: Ejecute `bin/FileTreeGen.exe` directamente. No se requiere la instalación de AutoHotkey. La GUI se mostrará permitiendo la selección de una carpeta y la generación del árbol de archivos y contenidos de archivos.

2. **Usar el Script en AutoHotkey**: Asegúrese de tener AutoHotkey v2.0.18 instalado y ejecute `FileTreeGen.ah2`. La GUI se mostrará permitiendo la selección de una carpeta y la generación del árbol de archivos y contenidos de archivos.

### Ejemplo de Uso

1. **Seleccione una Carpeta**: Puede arrastrar una carpeta a la GUI o seleccionarla manualmente utilizando el botón "Seleccionar Carpeta".
2. **Generar Estructura y Contenido**: Asegúrese de que las casillas "Directory Tree" y "Files Contents" estén marcadas según lo que desea generar.
3. **Resultado**: El resultado se combinará en un archivo `output.md` y se copiará al portapapeles para facilitar su uso. La salida del texto está en formato Markdown, incluyendo al copiarse en el portapapeles.

### Archivos de Ejemplo

Ejemplos de archivos de prueba ubicados en la carpeta `tree_tests`:

`````markdown
#### Archivo `1.txt`:

```txt
File in the main path
```

#### Archivo `1\2.txt`:

```txt
File in the secondary path
```

#### Archivo `1\a\a.txt`:

```txt
Line 1
Line 2
Text Text
```

#### Archivo `1\b\b.md`:

````md
##### Line 1

##### Line 2

```
MarkDown code
```
````

#### Archivo `1\d\d.js`:

```js
console.log("Line 1");
console.log("Line 2");
// JavaScript comment
```
`````

Estos archivos de ejemplo permiten probar la funcionalidad del programa y verificar que el contenido y la estructura de los archivos se generan correctamente.

### Notas Adicionales

> [!NOTE]  
> FileTreeGen puede generar tanto la estructura de directorios como el contenido de archivos específicos en una carpeta seleccionada. La GUI facilita la selección de carpetas y la configuración de opciones de generación.

> [!TIP]
> Puede arrastrar y soltar una carpeta directamente en la GUI de FileTreeGen para una selección rápida. Asegúrese de que las casillas "Directory Tree" y "Files Contents" estén marcadas según sus necesidades antes de iniciar la generación.
> También puede agregar archivos específicos que deben ser ignorados por la función Files Contents en el archivo `FilesContents.conf`. Asegúrese de listar estos archivos correctamente para que sean omitidos durante el procesamiento.

> [!IMPORTANT]  
> El archivo `FilesContents.conf` debe estar presente en el directorio adecuado. Define las extensiones de archivos permitidas para la extracción de contenidos. Sin este archivo, FileTreeGen no funcionará correctamente.

> [!WARNING]  
> Las rutas relativas deberían funcionar correctamente. Asegúrese de proporcionar rutas relativas precisas para evitar errores en la generación de contenidos y estructuras de archivos.

> [!CAUTION]
> Los patrones de archivos como el uso de `*` o `?` aún no están implementados y pueden causar errores si se utilizan. Se planea añadir esta funcionalidad en el futuro, pero por ahora, evite usarlos. Asegúrese de que el archivo `FilesContents.conf` esté bien configurado y que las líneas estén estructuradas según la sintaxis requerida.

### Conclusión

**FileTreeGen** es una herramienta útil para la generación de estructuras de directorios y la extracción de contenidos de archivos de tipos específicos, facilitando la documentación y el análisis de proyectos.
