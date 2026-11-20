const int PIN_E1 = 27; 
const int PIN_E2 = 26;
const int PIN_L1 = 2;   
const int PIN_L2 = 25;  

const unsigned long RETARDO_DEBOUNCE = 50;


bool estadoE1 = false;
bool estadoE2 = false;
bool estadoL1 = false;
bool estadoL2 = false;


bool ultimaLecturaE1 = false;
bool ultimaLecturaE2 = false;
unsigned long tiempoCambioE1 = 0;
unsigned long tiempoCambioE2 = 0;

void setup() {
  Serial.begin(115200);


  pinMode(PIN_E1, INPUT_PULLUP);
  pinMode(PIN_E2, INPUT_PULLUP);

  pinMode(PIN_L1, OUTPUT);
  pinMode(PIN_L2, OUTPUT);

  digitalWrite(PIN_L1, LOW);
  digitalWrite(PIN_L2, LOW);

  // Pequeña espera para separar la primera trama de los logs de arranque del ESP32
  delay(300);
  Serial.println();
  enviarEstados();
}

void loop() {
  bool huboCambio = false;

  // 1. Lectura de entradas físicas con antirrebote
  if (actualizarEntrada(PIN_E1, ultimaLecturaE1, tiempoCambioE1, estadoE1, estadoL1)) {
    huboCambio = true;
  }
  if (actualizarEntrada(PIN_E2, ultimaLecturaE2, tiempoCambioE2, estadoE2, estadoL2)) {
    huboCambio = true;
  }

  // 2. Recepción de comandos desde Processing
  while (Serial.available() > 0) {
    char comando = Serial.read();
    if (comando == '1') {
      estadoL1 = !estadoL1;
      huboCambio = true;
    } else if (comando == '2') {
      estadoL2 = !estadoL2;
      huboCambio = true;
    } else if (comando == 'S') {
      enviarEstados();
    }
  }

  // 3. Actualización de salidas físicas y notificación a la PC
  if (huboCambio) {
    digitalWrite(PIN_L1, estadoL1 ? HIGH : LOW);
    digitalWrite(PIN_L2, estadoL2 ? HIGH : LOW);
    enviarEstados();
  }
}

bool actualizarEntrada(int pin, bool &ultimaLectura, unsigned long &tiempoCambio,
                       bool &estadoEntrada, bool &estadoSalida) {
  bool lecturaActual = !digitalRead(pin);

  if (lecturaActual != ultimaLectura) {
    tiempoCambio = millis();
    ultimaLectura = lecturaActual;
  }

  if ((millis() - tiempoCambio) > RETARDO_DEBOUNCE) {
    if (lecturaActual != estadoEntrada) {
      estadoEntrada = lecturaActual;

      // Conmuta el LED en cada pulsación (flanco ascendente)
      if (estadoEntrada == true) {
        estadoSalida = !estadoSalida;
      }
      return true;
    }
  }
  return false;
}

void enviarEstados() {
  Serial.print(estadoE1 ? 1 : 0);
  Serial.print(',');
  Serial.print(estadoE2 ? 1 : 0);
  Serial.print(',');
  Serial.print(estadoL1 ? 1 : 0);
  Serial.print(',');
  Serial.println(estadoL2 ? 1 : 0);
}