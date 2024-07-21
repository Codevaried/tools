## Índice de Herramientas

1. [gitCommitPushAll.sh](#gitCommitPushAll)
2. [gitRepoTool.sh](#gitRepoTool)

## gitCommitPushAll

Documentación para el script `gitCommitPushAll.sh`

### Descripción

Este script en Bash automatiza el proceso de añadir cambios al índice de git, realizar un commit y hacer push a la rama principal (`main` o `master`) del repositorio. Está diseñado para ser ejecutado desde cualquier subdirectorio dentro del repositorio, y manejará automáticamente el cambio al directorio principal del repositorio. El script se puede ejecutar tanto desde la terminal (recomendado) como desde cualquier otro entorno.

### Uso

```bash
./gitCommitPushAll.sh [mensaje_del_commit]
```

- `mensaje_del_commit` (opcional): El mensaje que se usará para el commit. Si no se proporciona, se utilizará un mensaje por defecto que incluye el nombre del repositorio y una indicación de que es una actualización automática.

### Detalles del Script

#### Colores

El script utiliza colores para proporcionar retroalimentación visual sobre el estado de las operaciones:

- **Verde (`$GREEN`)**: Éxito.
- **Rojo (`$RED`)**: Error.
- **Amarillo (`$YELLOW`)**: Aviso.
- **Púrpura (`$PURPLE`)**: Información de git.
- **Azul (`$BLUE`)**: Input del usuario.
- **Sin color (`$NC`)**: Restablecer al color por defecto del terminal.

#### Confirmar el inicio del proceso

Antes de iniciar el proceso, el script solicitará confirmación al usuario para proceder. Se mostrará un mensaje con una descripción del proceso y se pedirá al usuario que confirme si desea continuar:

```bash
Iniciando el proceso de guardado, commit y push de cambios.
Este script guardará los cambios actuales, hará un commit y los enviará al repositorio remoto.
commit: '<mensaje_del_commit>'
repositorio remoto: '<nombre_del_repositorio>'

¿Desea proceder con la ejecución del script? (s/n):
```

### Ejemplo de Ejecución

```bash
./gitCommitPushAll.sh "Actualización de documentación y refactorización de código"
```

Si no se proporciona un mensaje de commit, el script utilizará uno por defecto como el siguiente:

```
<nombre_del_repositorio> automatic update from (gitCommitPushAll.sh)
```

### Notas

> [!NOTE]  
> Asegúrese de tener permisos de ejecución para el script:
>
> ```bash
> chmod +x gitCommitPushAll.sh
> ```

> [!TIP]
> El script debe estar ubicado en una carpeta dentro del repositorio desde la cual se desea realizar las operaciones de git.

> [!IMPORTANT]  
> El script maneja posibles errores y proporciona mensajes de estado claros para facilitar la depuración y el seguimiento de las operaciones realizadas.

> [!WARNING]  
> Asegúrese de que su entorno de git esté correctamente configurado y que tenga acceso de escritura al repositorio remoto.

> [!CAUTION]
> La ejecución de este script realizará un push directo a la rama principal del repositorio. Asegúrese de que los cambios locales sean correctos antes de ejecutar el script.

> [!NOTE]  
> Reconsidere la posibilidad de añadir el script al archivo `.gitignore` si no desea que se envíe al repositorio remoto. A pesar de que el script necesita estar dentro de la carpeta del repositorio, puede excluirse del control de versiones para evitar que se incluya en los commits y pushs.

> [!TIP]
> El script se puede ejecutar tanto desde la terminal (recomendado) como desde cualquier otro entorno, siempre que el bash de git esté correctamente configurado. Asegúrese de que su entorno pueda interpretar scripts de Bash adecuadamente.

## gitRepoTool

Documentación para el script `gitRepoTool.sh`

### Descripción

Este script en Bash automatiza varias tareas de gestión de repositorios GitHub, tales como clonar repositorios, inicializar nuevos repositorios, limpiar repositorios existentes y crear ramas personalizadas. Está diseñado para ser ejecutado desde cualquier entorno y maneja automáticamente las interacciones con el repositorio remoto.

### Uso

```bash
./gitRepoTool.sh
```

El usuario puede elegir entre inicializar un nuevo repositorio o reiniciar uno existente, siguiendo las indicaciones en pantalla para ingresar la URL del repositorio y la ruta de clonación.

### Pasos a Seguir

#### 1. Ejecutar el script

```bash
./gitRepoTool.sh
```

#### 2. Seleccionar una opción

Se te presentarán tres opciones:

```bash
Introduce tu elección (1 o 2):
1) Inicializar el repositorio
2) Reiniciar el repositorio
3) Salir
```

#### 3. Introducir la URL del repositorio remoto

Cuando se te pida:

```bash
Introduce la URL del repositorio remoto:
```

Ejemplo:

```bash
Introduce la URL del repositorio remoto: https://github.com/usuario/nuevo-repo.git
```

#### 4. Introducir la ruta donde se clonará el repositorio (opcional)

Puedes proporcionar una ruta específica o dejarlo en blanco para usar la ruta actual:

```bash
Introduce la ruta donde se clonará el repositorio (Opcional, por defecto es la ruta actual):
```

Ejemplo:

```bash
Introduce la ruta donde se clonará el repositorio (Opcional, por defecto es la ruta actual): /ruta/al/repositorio
```

#### Crear ramas adicionales (opcional)

Puedes crear ramas adicionales si lo deseas:

```bash
Introduce los nombres de las ramas iniciales, separados por espacios (Opcional):
```

Ejemplo:

```bash
Introduce los nombres de las ramas iniciales, separados por espacios (Opcional): dev staging
```

Resultado:

```bash
Creando y cambiando a la rama 'dev' desde la rama main...
Creando README.md para la rama 'dev'...
Agregando README.md para la rama 'dev'...
Haciendo commit del README.md en la rama 'dev'...
Enviando la rama 'dev' al remoto...
Volviendo a la rama main...
Creando y cambiando a la rama 'staging' desde la rama main...
Creando README.md para la rama 'staging'...
Agregando README.md para la rama 'staging'...
Haciendo commit del README.md en la rama 'staging'...
Enviando la rama 'staging' al remoto...
Volviendo a la rama main...
```

### Notas

> [!NOTE]  
> Asegúrese de tener permisos de ejecución para el script:
>
> ```bash
> chmod +x gitRepoTool.sh
> ```

> [!IMPORTANT]  
> El script maneja posibles errores y proporciona mensajes de estado claros para facilitar la depuración y el seguimiento de las operaciones realizadas.

> [!WARNING]  
> Asegúrese de que su entorno de git esté correctamente configurado y que tenga acceso de escritura al repositorio remoto.

> [!CAUTION]
> La ejecución de este script realizará operaciones críticas en el repositorio, como eliminar ramas y archivos. Asegúrese de que los cambios locales sean correctos antes de ejecutar el script.

> [!TIP]
> El script se puede ejecutar tanto desde la terminal (recomendado) como desde cualquier otro entorno, siempre que el bash de git esté correctamente configurado. Asegúrese de que su entorno pueda interpretar scripts de Bash adecuadamente.

---
