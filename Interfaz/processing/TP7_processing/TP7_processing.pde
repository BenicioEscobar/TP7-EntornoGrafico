import processing.serial.*;

Serial puerto;
boolean conectado = false;

// Estados sincronizados con Arduino (0 = BAJO/APAGADO, 1 = ALTO/ENCENDIDO)
int e1 = 0;
int e2 = 0;
int l1 = 0;
int l2 = 0;

// === Geometría de la interfaz ===
// Entradas (rectángulos)
float xE1 = 310, yE1 = 90, wE = 110, hE = 65;
float xE2 = 470, yE2 = 90;

// Salidas (círculos: centro y radio)
float xL1 = 365, yL1 = 275, diamL = 100, radioL = 50;
float xL2 = 525, yL2 = 275;

void setup() {
  size(680, 400);
  textAlign(CENTER, CENTER);

  println("=== Puertos serie disponibles ===");
  printArray(Serial.list());

  // Selecciona el puerto donde está conectado Arduino.
  // Si tenés más de un puerto, cambiá el índice [0] o escribí el nombre directo,
  // por ejemplo: new Serial(this, "COM3", 9600); o "/dev/ttyACM0"
  if (Serial.list().length > 0) {
    try {
      String nombrePuerto = Serial.list()[2];
      puerto = new Serial(this, nombrePuerto, 115200);
      puerto.bufferUntil('\n');
      conectado = true;
      println("Conectado a: " + nombrePuerto);
    } catch (Exception e) {
      println("Error al abrir el puerto serie: " + e.getMessage());
    }
  } else {
    println("No se detectaron puertos serie.");
  }
}

void draw() {
  background(255);

  // Marco exterior de la ventana
  noFill();
  stroke(80);
  strokeWeight(2);
  rect(15, 15, width - 30, height - 30);

  // --- Etiqueta "Entradas" ---
  fill(135, 168, 208); // Azul similar al esquema
  stroke(50);
  strokeWeight(2);
  rect(65, 90, 175, 65);
  fill(0);
  textSize(24);
  text("Entradas", 65 + 175 / 2.0, 90 + 65 / 2.0);

  // --- Indicadores de Entradas (E1 y E2) ---
  dibujarEntrada(xE1, yE1, wE, hE, "E1", e1);
  dibujarEntrada(xE2, yE2, wE, hE, "E2", e2);

  // --- Etiqueta "Salidas" ---
  fill(253, 229, 208); // Naranja/durazno claro similar al esquema
  stroke(50);
  strokeWeight(2);
  rect(65, 242, 175, 65);
  fill(0);
  textSize(24);
  text("Salidas", 65 + 175 / 2.0, 242 + 65 / 2.0);

  // --- Controles/Indicadores de Salidas (L1 y L2) ---
  dibujarSalida(xL1, yL1, diamL, "L1", l1);
  dibujarSalida(xL2, yL2, diamL, "L2", l2);

  // Cursor interactivo sobre los círculos clickeables
  if (sobreCirculo(xL1, yL1, radioL) || sobreCirculo(xL2, yL2, radioL)) {
    cursor(HAND);
  } else {
    cursor(ARROW);
  }

  // Barra de estado inferior
  fill(90);
  textSize(13);
  String info = conectado
    ? "Conectado a Arduino | Hacé clic en L1 o L2 para conmutar las salidas"
    : "SIN CONEXIÓN SERIE | Verificá el puerto y cerrá el Monitor Serie de Arduino";
  text(info, width / 2.0, height - 32);
}

void dibujarEntrada(float x, float y, float w, float h, String etiqueta, int estado) {
  // Verde = ALTO (1), Blanco = BAJO (0)
  fill(estado == 1 ? color(76, 175, 80) : color(255));
  stroke(0);
  strokeWeight(3);
  rect(x, y, w, h);

  fill(estado == 1 ? 255 : 0);
  textSize(24);
  text(etiqueta, x + w / 2.0, y + h / 2.0);
}

void dibujarSalida(float cx, float cy, float d, String etiqueta, int estado) {
  // Rojo/naranja encendido = ALTO (1), Blanco = BAJO (0)
  fill(estado == 1 ? color(255, 87, 34) : color(255));
  stroke(0);
  strokeWeight(3);
  ellipse(cx, cy, d, d);

  fill(estado == 1 ? 255 : 0);
  textSize(24);
  text(etiqueta, cx, cy);
}

boolean sobreCirculo(float cx, float cy, float r) {
  return dist(mouseX, mouseY, cx, cy) <= r;
}

// Punto 2: envía comando al hacer clic sobre L1 o L2
void mousePressed() {
  if (!conectado) return;

  if (sobreCirculo(xL1, yL1, radioL)) {
    puerto.write('1');
  } else if (sobreCirculo(xL2, yL2, radioL)) {
    puerto.write('2');
  }
}


void serialEvent(Serial p) {
  String linea = p.readStringUntil('\n');
  if (linea == null) return;

  linea = trim(linea);
  String[] valores = split(linea, ',');

  if (valores.length == 4) {
    try {
      e1 = int(valores[0]);
      e2 = int(valores[1]);
      l1 = int(valores[2]);
      l2 = int(valores[3]);
    } catch (Exception ex) {
      println("Trama ignorada: " + linea);
    }
  }
}
