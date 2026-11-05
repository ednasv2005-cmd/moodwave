# MoodWave 🌊 (OndaVital)
### Diario de Emociones y Análisis de Hábitos Personales
**Instituto Politécnico Nacional (IPN) — UPIIT**  
*Unidad Profesional Interdisciplinaria de Ingeniería Campus Tlaxcala*  
*Materia: Programación de Dispositivos Móviles*  
*Proyecto 1 & 2: Incremento 1 (MVP) + Incremento 2 ("Descubre tus patrones")*

---

## 📱 Descripción del Proyecto

**MoodWave** es una aplicación móvil desarrollada en **Flutter** diseñada para acompañar a adolescentes y adultos jóvenes en el registro diario de su bienestar emocional y el descubrimiento de patrones entre sus actividades cotidianas y su estado de ánimo.

> **💡 Pregunta Guía:** *"¿Cómo influyen mis actividades cotidianas en cómo me siento, y qué tan confiable es esa afirmación con los datos que tengo?"*

---

## 🎨 Diseño Visual & Experiencia (Aesthetic Gen-Z)
- **Paleta Cyber-Pastel & Deep Obsidian:** Modo oscuro inmersivo (`#0B0F19`) con acentos en Cyber Lavender (`#8B5CF6`), Electric Cyan (`#06B6D4`) y Sunburst Amber (`#F59E0B`).
- **8 Códigos Cromáticos Oficiales:**
  - 1 🔴 Enojado (`#EF4444`)
  - 2 🟣 Triste (`#8B5CF6`)
  - 3 🔵 Deprimido/Desanimado (`#3B82F6`)
  - 4 🟠 Preocupado (`#F97316`)
  - 5 ⚪ Neutral (`#94A3B8`)
  - 6 🟢 Bien (`#10B981`)
  - 7 🟢 Feliz (`#059669`)
  - 8 🟡 Excelente (`#F59E0B`)
- **Microinteracciones Ingeniosas:** Widget interactivo de respiración consciente **4-7-8** con burbuja rítmica pulsante para momentos de estrés o frustración.

---

## 🚀 Funcionalidades Implementadas

### 📌 Etapa 1 — MVP: Registro y Seguimiento Emocional
1. **Registro Diario de Emociones:** Selección táctil de los 8 estados de ánimo con feedback visual y háptico.
2. **Nivel de Energía (1 al 10):** Permite diferenciar días de alta vitalidad (*Feliz 9/10*) de días serenos (*Feliz 3/10*).
3. **Diario Rápido / Reflexión:**
   - Campo de texto con fecha y hora automática.
   - Longitud máxima de caracteres configurable (140, 280, 500, 1000 caracteres) con contador en tiempo real.
   - Capacidad completa de edición y eliminación de registros anteriores.
4. **Actividades del Día:**
   - 10 actividades predefinidas con iconos: 💼 Trabajo, 📚 Estudio, 🏃 Ejercicio, 👨‍👩‍👧 Familia, 👥 Amigos, 🎮 Entretenimiento, 🛌 Descanso, ✈️ Viaje, 🛍️ Compras, 🧹 Tareas domésticas.
   - Botón **"+ Agregar actividad"** para crear etiquetas personalizadas con emojis propios.
5. **Línea de Tiempo Interactiva:** Tira cronológica en la pantalla principal con círculos cromáticos según el ánimo registrado.
6. **Vista de Calendario Mensual:** Calendario visual completo que permite detectar patrones de días positivos o negativos a lo largo del mes, con inspector interactivo por día.
7. **Privacidad y Bloqueo Seguro:**
   - Pantalla de bloqueo mediante **PIN de 4 dígitos**.
   - Compatibilidad con desbloqueo biométrico (huella digital).
   - Bloqueo automático por inactividad.

---

### 🔬 Etapa 2 — Analytics & Descubrimiento de Patrones

#### Nivel 1: Núcleo (Obligatorio)
1. **Estadísticas Descriptivas Exactas:**
   - Cálculo de **Media ($\bar{x}$)**, **Mediana**, **Moda**, **Desviación Estándar ($\sigma$)** y **Racha activa de días consecutivos**.
   - Filtros de análisis por ventana temporal: **7 días**, **30 días** y **90 días**.
2. **Tendencias y Suavizado por Media Móvil:**
   - Gráfica interactiva de línea con cálculo en tiempo real de la **Media Móvil (Moving Average)** para filtrar el ruido diario y revelar la dirección real del ánimo.
   - Cálculo del porcentaje de cambio y pendiente temporal sin bloqueos de interfaz.
3. **Análisis Actividad vs. Ánimo con Tamaño de Muestra ($n$):**
   - Muestra el promedio de ánimo y energía por actividad, comparándolo contra la media general.
   - Siempre incluye el número de observaciones $n$ correspondiente.
4. **Justificación Matemática del Método de Correlación:**
   - Se implementó la **Correlación Biserial-Puntual ($r_{pb}$)** y el **Tamaño del Efecto ($d$ de Cohen)**.
   - *Justificación:* La actividad es una variable dicotómica binaria ($X \in \{0, 1\}$) y el ánimo es una variable cuantitativa de 1 a 8. La correlación biserial-puntual es la derivación matemática formal de Pearson para este tipo de datos. El cálculo de $d$ de Cohen garantiza distinguir diferencias relevantes de variaciones pequeñas por azar.
5. **Visualizaciones Gráficas Variadas:**
   - Gráfica de línea con media móvil.
   - Gráfica de barras comparativa de actividades.
   - Matrices de cruzamiento para sueño y pasos.
6. **Lenguaje Responsable:**
   - Todos los insights utilizan la redacción rigurosa de *"se observa una relación o asociación"*, evitando terminología causal ("el ejercicio causa felicidad").
7. **Umbrales Mínimos de Calidad Estadística:**
   - No se emiten patrones sin al menos **14 días totales** y un mínimo de **5 registros** por actividad ($n \ge 5$). De lo contrario, se notifica claramente: *"Aún no hay datos suficientes ($n/5$)"*.

#### Nivel 2: Avanzado
1. **Hábitos Biológicos (Sueño y Pasos):**
   - Agrupación por franjas: Sueño (<6h, 6-7h, 7-9h, >9h) y Pasos (<2k, 2k-5k, 5k-8k, >8k) cruzados contra el estado de ánimo.
2. **Reporte Mensual en PDF:**
   - Exportación de reporte vectorial en PDF con desglose de indicadores clave, gráficos de distribución, tabla de actividades con $d$ de Cohen, conclusiones y advertencias éticas.
   - Visualización previa, guardado y opción de compartir.
3. **Respaldo Cifrado de Información:**
   - Exportación e importación de la base de datos en JSON cifrado mediante **PBKDF2-HMAC-SHA256 (10,000 iteraciones)** y flujo simétrico autenticado con firma HMAC contra manipulación.
4. **Generador de Datos Sintéticos (Condición de Partida):**
   - Botón integrado en Configuración para generar **90 días de datos sintéticos con patrones plantados** (ejercicio positivo +1.4 pts, trabajo demandante -0.7 pts, sueño óptimo 7-9h) para validar de inmediato todo el motor estadístico sin necesidad de capturar 3 meses a mano.

#### Nivel 3: Módulo de Inteligencia Artificial Local
- **A. Análisis de Sentimiento del Diario:**
  - Motor NLP local en español sensible a modismos y expresiones coloquiales mexicanas (*chido, padrísimo, agotado, bajón, harto*).
  - Detección de discrepancias emocionales: avisa con respeto si el usuario marcó "Excelente" pero escribió palabras asociadas a cansancio o sobrecarga.
- **B. Predicción Temporal de Estado de Ánimo:**
  - Modelo autorregresivo multivariable para pronosticar el día siguiente.
  - Validación walk-forward temporal (sin fuga de datos futuros) evaluada contra dos baselines triviales (persistencia "igual que ayer" y media histórica), reportando el **MAE (Mean Absolute Error)**.
- **C. Clustering Conductual de Días:**
  - Agrupación en 4 arquetipos: *Días de Vitalidad*, *Días Exigentes*, *Días de Tensión* y *Días de Recarga*.
- **D. Detección de Anomalías:**
  - Detecta caídas sostenidas por debajo de 1.2 desviaciones estándar durante 3 días seguidos y activa una recomendación preventiva de autocuidado.
- **E. Insights en Lenguaje Natural con Explicabilidad:**
  - Cada recomendación incluye la etiqueta *"Explicabilidad: ¿Por qué veo esto?"* con el tamaño de muestra $n$ y el rango de datos.

---

### 🛡️ Ética y Seguridad (Requisito Transversal)
- **Aviso Visible Permanente:**  
  *"MoodWave es una herramienta de autoobservación y análisis de hábitos personales. No realiza diagnósticos médicos ni sustituye la atención profesional."*
- **Protocolo ante Señales de Riesgo:**  
  Si el texto del diario detecta palabras asociadas a crisis emocional severa o ideación autolesiva, la app activa de forma inmediata un diálogo empático y proporciona los teléfonos de auxilio directo:
  - **Línea de la Vida (México):** 800 911 2000 (24 hrs / Gratuita)
  - **SAPTEL:** 55 5259 8121
  - **Emergencias Nacionales:** 911
- **Control Total y Derecho al Olvido:**  
  El usuario tiene la potestad de ver, exportar de forma cifrada y borrar la totalidad de sus datos con un solo clic.

---

## 🏛️ Arquitectura del Software

El proyecto sigue una arquitectura limpia desacoplada en capas:

```
lib/
├── core/                  # Constantes, paleta de colores, protocolo ético y cifrado PBKDF2
│   ├── constants/         # AppColors, MoodConstants (8 estados y 10 actividades)
│   ├── ethics/            # EthicsProtocol y recursos de auxilio
│   ├── security/          # CryptoService (derivación y cifrado)
│   └── theme/             # AppTheme (Material 3 Cyber-Aesthetic)
├── data/                  # Persistencia y acceso a datos
│   ├── datasources/       # DatabaseHelper (SQLite + SQL aggregations), PreferenceHelper
│   ├── models/            # MoodEntry, ActivityModel
│   └── repositories/      # MoodRepository
├── domain/                # Motor de análisis puro (sin dependencias de Android/UI)
│   ├── analytics/         # EmotionalStatsCalculator, TrendAnalyzer, CorrelationEngine, SyntheticDataGenerator
│   ├── ai/                # SentimentAnalyzer, MoodPredictor, PatternClusterer, NaturalInsightsGenerator
│   └── pdf/               # PdfReportGenerator
└── presentation/          # Interfaz de usuario y estado
    ├── providers/         # MoodProvider, SecurityProvider, ThemeProvider
    ├── screens/           # Dashboard, Calendario, Análisis, IA Hub, Reporte PDF, Configuración, PIN Lock
    └── widgets/           # BreathingWidget (4-7-8), EnergySlider, MoodBadge, StatCard
```

---

## 🧪 Pruebas Unitarias

El motor de análisis es un módulo puro y cuenta con una suite completa de pruebas unitarias que verifican:
- Cálculo manual exacto de media, mediana, moda y desviación estándar.
- Comportamiento del generador de 90 días sintéticos y detección de correlaciones plantadas.
- Análisis de sentimiento en español y detección de discrepancias.
- Pronóstico temporal y reporte de métricas MAE frente al baseline.
- Cifrado y descifrado con validación de clave incorrecta.
- Protocolo de detección de señales de riesgo.

Para ejecutar las pruebas:
```bash
flutter test
```

---

## 📦 Compilación y Generación del APK

Para compilar la aplicación para Android:
```bash
flutter build apk --release
```
El archivo APK resultante se genera en:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 👤 Autor & Créditos
- **Desarrollado para:** Programación de Dispositivos Móviles — UPIIT IPN
- **Autor:** Edna Andrea Serrano Vela (`ednasv2005-cmd`)
- **Versión:** 2.0.0
