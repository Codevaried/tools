/**
 * Clase para gestionar operaciones con el ratón.
 */
class Mouse {
	static SmallMove := 20
	static MediumMove := 70
	static BigMove := 200

	static HorizontalSeparator := 20
	static VerticalSeparator := 7

	static TopY := A_ScreenHeight // Mouse.VerticalSeparator
	static MiddleY := A_ScreenHeight // 2
	static LowY := Round(A_ScreenHeight / 1080 * 740)
	static BottomY := A_ScreenHeight // Mouse.VerticalSeparator * 6

	static FarLeftX := A_ScreenWidth / Mouse.HorizontalSeparator
	static HighLeftX := A_ScreenWidth / Mouse.HorizontalSeparator * 3
	static MiddleLeftX := A_ScreenWidth / Mouse.HorizontalSeparator * 5
	static LowLeftX := A_ScreenWidth / Mouse.HorizontalSeparator * 7
	static LessThanMiddleX := A_ScreenWidth / Mouse.HorizontalSeparator * 9
	static MiddleX := A_ScreenWidth // 2
	static MoreThanMiddleX := A_ScreenWidth / Mouse.HorizontalSeparator * 11
	static LowRightX := A_ScreenWidth / Mouse.HorizontalSeparator * 13
	static MiddleRightX := A_ScreenWidth / Mouse.HorizontalSeparator * 15
	static HighRightX := A_ScreenWidth / Mouse.HorizontalSeparator * 17
	static FarRightX := A_ScreenWidth / Mouse.HorizontalSeparator * 19

	/**
	 * Mantiene presionado un botón del ratón si no lo está actualmente.
	 * Si ya está presionado, lo libera.
	 * @param {Char} which El botón del ratón a mantener presionado o liberar.
	 * Solo admite "L" (izquierda), "R" (derecha), "M" (medio).
	 */
	static HoldIfUp(which) {
		if GetKeyState(which "Button")
			Click(which " Up")
		else
			Click(which " Down")
	}

	/**
	 * Mueve el ratón hacia la izquierda una distancia especificada.
	 * @param {Integer} howMuch - La distancia en píxeles para mover el ratón.
	 */
	static MoveLeft(howMuch) => MouseMove(-howMuch, 0, , "R")

	/**
	 * Mueve el ratón hacia arriba una distancia especificada.
	 * @param {Integer} howMuch - La distancia en píxeles para mover el ratón.
	 */
	static MoveUp(howMuch) => MouseMove(0, -howMuch, , "R")

	/**
	 * Mueve el ratón hacia abajo una distancia especificada.
	 * @param {Integer} howMuch - La distancia en píxeles para mover el ratón.
	 */
	static MoveDown(howMuch) => MouseMove(0, howMuch, , "R")

	/**
	 * Mueve el ratón hacia la derecha una distancia especificada.
	 * @param {Integer} howMuch - La distancia en píxeles para mover el ratón.
	 */
	static MoveRight(howMuch) => MouseMove(howMuch, 0, , "R")

	/**
	 * Hace clic en las coordenadas especificadas y luego mueve el ratón a su posición inicial.
	 * @param {String} coordinates Coordenadas en formato "123 123".
	 */
	static ClickThenGoBack(coordinates) {
		MouseGetPos(&initX, &initY)
		Click(coordinates)
		MouseMove(initX, initY)
	}

	/**
	 * Hace clic usando SendEvent en las coordenadas especificadas y luego mueve el ratón a su posición inicial.
	 * @param {String} coordinates Coordenadas en formato "123 123".
	 */
	static ClickThenGoBack_Event(coordinates) {
		MouseGetPos(&initX, &initY)
		SendEvent("{Click " coordinates "}")
		MouseMove(initX, initY)
	}

	/**
	 * Hace un ControlClick en la posición actual del ratón en la ventana activa.
	 * @param {String} winTitle Especifica un título de ventana si no deseas usar la ventana activa.
	 * @param {String} whichButton "L" para el botón izquierdo del ratón, "R" para el botón derecho del ratón.
	 */
	static ControlClick_Here(winTitle := "A", whichButton := "L") {
		MouseGetPos(&locX, &locY)
		ControlClick("X" locX " Y" locY, winTitle, , whichButton)
	}
}