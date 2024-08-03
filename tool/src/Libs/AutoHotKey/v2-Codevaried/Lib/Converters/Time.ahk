#Requires AutoHotkey v2.0


;todo---MARK: Class Time:

/**
 * Clase para obtener diferentes formatos de tiempo y fecha.
 */
class Time {

    /**
     * * Maneja los errores de formato lanzando una excepción ValueError.
     * @param {String} opc - La opción de formato que causó el error.
     * @throws {ValueError} Lanza un ValueError con el mensaje especificado.
     */
    static throwFormatError(opc) {
        throw ValueError('Tipo de Formato de fecha "' opc '" no válido.')
    }

    /**
     * * Obtiene la fecha en diferentes formatos.
     * @param {Integer} [opc=0] - El tipo de formato de fecha deseado.
     * @returns {String} La fecha formateada.
     * @throws {ValueError} Lanza un ValueError si la opción no es válida.
     * @example
     * Time.date(0) ; "HH:mm:ss dd/MM/yyyy"
     * Time.date(1) ; "dd/MM/yyyy"
     * Time.date(2) ; "d 'de' MMMM 'de' yyyy"
     * Time.date(3) ; "dddd, d 'de' MMMM 'de' yyyy"
     */
    static date(opc := 0) {
        switch opc {
            case 0:
                return FormatTime("", "HH:mm:ss dd/MM/yyyy")  ; HH:mm:ss 06/03/2024
            case 1:
                return FormatTime("", "dd/MM/yyyy")  ; 06/03/2024
            case 2:
                return FormatTime("", "d 'de' MMMM 'de' yyyy")  ; 6 de marzo de 2024
            case 3:
                return FormatTime("", "dddd, d 'de' MMMM 'de' yyyy")  ; miércoles, 6 de marzo de 2024
            default:
                Time.throwFormatError(opc)
        }
    }

    /**
     * * Obtiene el año en diferentes formatos.
     * @param {Integer} [opc=2] - El tipo de formato de año deseado.
     * @returns {String} El año formateado.
     * @throws {ValueError} Lanza un ValueError si la opción no es válida.
     * @example
     * Time.year(1) ; "24"
     * Time.year(2) ; "2024"
     */
    static year(opc := 2) {
        switch opc {
            case 1:
                return FormatTime("", "yy")   ; 24
            case 2:
                return FormatTime("", "yyyy") ; 2024
            default:
                Time.throwFormatError(opc)
        }
    }

    /**
     * * Obtiene el mes en diferentes formatos.
     * @param {Integer} [opc=2] - El tipo de formato de mes deseado.
     * @returns {String} El mes formateado.
     * @throws {ValueError} Lanza un ValueError si la opción no es válida.
     * @example
     * Time.month(1) ; "3"
     * Time.month(2) ; "03"
     * Time.month(3) ; "mar."
     * Time.month(4) ; "marzo"
     */
    static month(opc := 2) {
        switch opc {
            case 1:
                return FormatTime("", "M")    ; 3
            case 2:
                return FormatTime("", "MM")   ; 03
            case 3:
                return FormatTime("", "MMM")  ; mar.
            case 4:
                return FormatTime("", "MMMM") ; marzo
            default:
                Time.throwFormatError(opc)
        }
    }

    /**
     * * Obtiene el día en diferentes formatos.
     * @param {Integer} [opc=2] - El tipo de formato de día deseado.
     * @returns {String} El día formateado.
     * @throws {ValueError} Lanza un ValueError si la opción no es válida.
     * @example
     * Time.day(1) ; "6"
     * Time.day(2) ; "06"
     * Time.day(3) ; "mi."
     * Time.day(4) ; "miércoles"
     */
    static day(opc := 2) {
        switch opc {
            case 1:
                return FormatTime("", "d")    ; 6
            case 2:
                return FormatTime("", "dd")   ; 06
            case 3:
                return FormatTime("", "ddd")  ; mi.
            case 4:
                return FormatTime("", "dddd") ; miércoles
            default:
                Time.throwFormatError(opc)
        }
    }

    /**
     * * Obtiene la hora en formato HH:mm:ss.
     * @param {Integer} [opc=1] - El tipo de formato de tiempo deseado.
     * @returns {String} La hora formateada.
     * @throws {ValueError} Lanza un ValueError si la opción no es válida.
     * @example
     * Time.time(1) ; "HH:mm:ss"
     */
    static time(opc := 1) {
        switch opc {
            case 1:
                return FormatTime("", "HH:mm:ss")  ; HH:mm:ss
            default:
                Time.throwFormatError(opc)
        }
    }

    /**
     * * Obtiene la hora en diferentes formatos.
     * @param {Integer} [opc=1] - El tipo de formato de hora deseado.
     * @returns {String} La hora formateada.
     * @throws {ValueError} Lanza un ValueError si la opción no es válida.
     * @example
     * Time.hour(1) ; "h"
     * Time.hour(2) ; "hh"
     * Time.hour(3) ; "H"
     * Time.hour(4) ; "HH"
     */
    static hour(opc := 1) {
        switch opc {
            case 1:
                return FormatTime("", "h")  ; formato de 12 horas (1 – 12)
            case 2:
                return FormatTime("", "hh") ; formato de 12 horas (01 – 12)
            case 3:
                return FormatTime("", "H")  ; Horas sin cero inicial; formato de 24 horas (0 – 23)
            case 4:
                return FormatTime("", "HH") ; Horas con cero inicial; formato de 24 horas (00 – 23)
            default:
                Time.throwFormatError(opc)
        }
    }

    /**
     * * Obtiene los minutos en diferentes formatos.
     * @param {Integer} [opc=1] - El tipo de formato de minuto deseado.
     * @returns {String} Los minutos formateados.
     * @throws {ValueError} Lanza un ValueError si la opción no es válida.
     * @example
     * Time.minute(1) ; "m"
     * Time.minute(2) ; "mm"
     */
    static minute(opc := 1) {
        switch opc {
            case 1:
                return FormatTime("", "m")  ; Minutos sin cero inicial (0 – 59)
            case 2:
                return FormatTime("", "mm")  ; Minutos con cero inicial (00 – 59)
            default:
                Time.throwFormatError(opc)
        }
    }

    /**
     * * Obtiene los segundos en diferentes formatos.
     * @param {Integer} [opc=1] - El tipo de formato de segundo deseado.
     * @returns {String} Los segundos formateados.
     * @throws {ValueError} Lanza un ValueError si la opción no es válida.
     * @example
     * Time.second(1) ; "s"
     * Time.second(2) ; "ss"
     */
    static second(opc := 1) {
        switch opc {
            case 1:
                return FormatTime("", "s")   ; Segundos sin cero inicial (0 – 59)
            case 2:
                return FormatTime("", "ss")  ; Segundos con cero inicial (00 – 59)
            default:
                Time.throwFormatError(opc)
        }
    }
}