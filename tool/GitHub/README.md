## Índice de Herramientas

1. [gitAutoUpdate.sh](#gitAutoUpdate)

## gitAutoUpdate

Documentación para el script `gitAutoUpdate.sh`

### Descripción

Este script en Bash automatiza el proceso de añadir cambios al índice de git, realizar un commit y hacer push a la rama principal (`main` o `master`) del repositorio. Está diseñado para ser ejecutado desde cualquier subdirectorio dentro del repositorio, y manejará automáticamente el cambio al directorio principal del repositorio.

### Uso

```bash
./gitAutoUpdate.sh [mensaje_del_commit]
```

- `mensaje_del_commit` (opcional): El mensaje que se usará para el commit. Si no se proporciona, se utilizará un mensaje por defecto que incluye el nombre del repositorio y una indicación de que es una actualización automática.

### Detalles del Script

#### Colores

El script utiliza colores para proporcionar retroalimentación visual sobre el estado de las operaciones:

- **Verde (`$GREEN`)**: Éxito.
- **Rojo (`$RED`)**: Error.
- **Amarillo (`$YELLOW`)**: Aviso.
- **Púrpura (`$PURPLE`)**: Información de git.
- **Sin color (`$NC`)**: Restablecer al color por defecto del terminal.

### Ejemplo de Ejecución

```bash
./gitAutoUpdate.sh "Actualización de documentación y refactorización de código"
```

Si no se proporciona un mensaje de commit, el script utilizará uno por defecto como el siguiente:

```
<nombre_del_repositorio> automatic update from (gitAutoUpdate.sh)
```

### Notas

> [!NOTE]  
> Asegúrese de tener permisos de ejecución para el script:
>
> ```bash
> chmod +x gitAutoUpdate.sh
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

---
