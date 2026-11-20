Componentes:
.2 Pulsadores de 4 patas
.1 led 
.1 resistencia de 220 ohms
. Protoboard
. Cables Dupont 
Resumen del código de arduino:
Declaramos los pines que utilizamos, definimos los pulsadores como int-pullup y los leds como output, luego inicia el puerto serie UART a 115200 baudios. 
en el loop se leen las pulsaciones de los botones ya con el efecto debounce activado para lograr que se leer correctamente
cuando se pulsan se invierten los estados de los leds (prendido o apagado)
Por ultimo Escucha si llegan los caracteres '1' o '2' desde la computadora para conmutar las salidas de forma remota y
ante cualquier cambio en entradas o salidas, envía una trama CSV por USB con los cuatro estados
Resumen del código de processing: 
Se abre el puerto serie del ESP 32 a 115200 baudios y se dibujan en pantalla la interfaz, como la del ejemplo, con las e1 e2 y las l1 y l2 interactivas
la linea serialevent lee cada linea del csv que envia el ESP y actualiza los colores en la pantalla
mousepressed detecta cuando se clickean los circulos y envia un 1 o 2 al puerto serie asi el arduino recibe esa señal y actualiza el estado del led
Link del video : https://drive.google.com/file/d/1c3XpdJ5Y8Br7Yod_jZWlTblSxfiD3ks-/view?usp=drive_link 
