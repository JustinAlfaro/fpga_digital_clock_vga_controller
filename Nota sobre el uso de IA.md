# Nota sobre el uso de IA

**Proyecto:** Reloj digital VGA en FPGA — Taller de Diseño SEM I 2026  
**Plataforma IA utilizada:** Claude (Anthropic) — modelo Claude Sonnet 4.6, vía Claude Code CLI  
**Autor:** JustinAlfaro

---

## Descripción general

A lo largo del desarrollo de este proyecto se utilizó inteligencia artificial generativa (Claude) como herramienta de asistencia en ingeniería. El modelo fue consultado en múltiples etapas: diseño de arquitectura, implementación de módulos Verilog, creación de testbenches, depuración de simulaciones, generación de scripts y documentación técnica.

En ningún caso el modelo operó de forma autónoma: todas las decisiones de diseño, criterios de aceptación y validaciones finales fueron tomadas por el desarrollador. La IA actuó como asistente técnico, no como autor del proyecto.

---

## Usos principales

### 1. Diseño de arquitectura del sistema

Se consultó al modelo para definir la estrategia de dominios de reloj, el modelo de pipeline del `vram_writer` y la elección de BRAM dual-puerto.

**Prompt:**
> "Tenemos una FPGA Nexys A7-100T con un CLK de 100 MHz. Necesito un reloj digital en VGA 640x480@60Hz. ¿Cómo manejo los dominios de reloj para no introducir metaestabilidad?"

**Respuesta relevante del modelo:**
> Se recomendó un único dominio de reloj a 100 MHz con clock enables (`tick_25mhz` para VGA con DIVISOR=4 y `tick_1hz` para los segundos con DIVISOR=100M). Esto evita cruces de dominio y simplifica el diseño: el módulo `div_freq` genera pulsos de un ciclo, no relojes reales, por lo que no es necesario ningún sincronizador adicional.

---

### 2. Implementación de módulos Verilog

El modelo asistió en la implementación de varios módulos del sistema, incluyendo `text_renderer`, `bg_rom`, `hour_converter`, `binary_bcd_decoder` y `vram_writer`.

**Prompt (ejemplo — bg_rom):**
> "Necesito una ROM BRAM que almacene una imagen de fondo de 160x120 píxeles y la escale a 640x480 en pantalla. ¿Cuál es la forma más eficiente de hacerlo en Verilog sin usar multiplicadores?"

**Respuesta relevante del modelo:**
> Se propuso almacenar la imagen a resolución reducida (160×120 = 19,200 píxeles, 16× menos memoria que a resolución completa) y escalar mediante extracción de bits:
> ```verilog
> bg_color <= mem[{v_count[8:2], h_count[9:2]}];
> ```
> Descartar los 2 bits menos significativos equivale a dividir entre 4, haciendo que cada píxel de la ROM ocupe un bloque de 4×4 píxeles en pantalla. Sin aritmética, solo selección de bits.

---

### 3. Creación de testbenches

El modelo generó 4 de los 8 testbenches del proyecto: `tb_fsm_adjust_mode`, `tb_binary_bcd_decoder`, `tb_hour_converter` y `tb_integration`. Los 4 testbenches originales (`tb_bcd_counter`, `tb_debounce`, `tb_div_freq`, `tb_vga_controller`) fueron escritos por el compañero hidalgojeulin.

**Prompt (tb_integration):**
> "Necesito un testbench de integración que pruebe la cadena completa: tres bcd_counter encadenados para segundos, minutos y horas; la FSM de ajuste; los decodificadores BCD; el convertidor 12h/24h; y los mux. Tiene que verificar rollover de 23:59:58 a 0, el modo de ajuste, y el cambio de formato 12h/24h."

**Respuesta relevante del modelo:**
> Se generó `tb_integration.v` con 9 casos de prueba: reset inicial, cadena sec→min→hour, propagación de carry, FSM en ADJ_HOUR y ADJ_MIN, sec_rst al cambiar de modo, decodificación BCD, conversión 12h (11→12→1 AM, 11→12 PM), modo 24h y rollover completo 23:59:58→00:00:00. Criterio de PASS: cadena exacta `TODOS LOS TESTS PASARON` en el log.

---

### 4. Depuración de simulaciones en xsim

Durante la integración de los testbenches al pipeline de simulación (`xsim`, Vivado 2024.1), varios archivos fallaban con errores de compilación. El modelo identificó que `xvlog` opera en modo Verilog-2001 estricto y rechaza construcciones SystemVerilog.

**Prompt:**
> "El testbench tb_debounce falla con XVLOG_FAILED. El log dice 'unsupported system task'. ¿Qué puede ser?"

**Respuesta relevante del modelo:**
> Se identificaron tres construcciones incompatibles con Verilog-2001 en xsim:
> - `fork/join_any` → reemplazar con bucle `repeat`
> - `disable named_block` → eliminar
> - Caracteres Unicode en `$display` → usar solo ASCII
>
> Se corrigieron todos los testbenches afectados para compilar sin flags adicionales en xvlog.

---

### 5. Scripts de automatización

El modelo implementó el pipeline completo de simulación en bash: `run_sim.sh`, `parse_sim_logs.sh` y `run_pipeline.sh`; además del script `parse_utilization.sh` para extraer métricas de síntesis.

**Prompt:**
> "Quiero un script que corra todos los testbenches con xsim, guarde los logs, y luego otro script que parsee esos logs y genere un CSV con PASS o FAIL por cada testbench."

**Respuesta relevante del modelo:**
> Se implementó `run_sim.sh` que compila con `xvlog`, elabora con `xelab` y simula con `xsim -runall` cada testbench en un directorio temporal aislado, guardando logs en `sim_logs/`. El script `parse_sim_logs.sh` lee cada `tb_*.log`, detecta los estados PASS / FAIL / COMPILE_ERROR / ELAB_ERROR / TIMEOUT, y genera `sim_results/resultados.csv`. El script `run_pipeline.sh` los orquesta secuencialmente.

---

### 6. Documentación técnica (TerosHDL)

El modelo convirtió las cabeceras de los 8 testbenches al formato TerosHDL, compatible con la generación automática de documentación en Vivado.

**Prompt:**
> "Convierte las cabeceras de los 7 testbenches al formato TerosHDL con los campos @title, @file, @brief, @details, @author y @date."

**Respuesta relevante del modelo:**
> Se actualizaron los 7 archivos con el formato de bloque `/** ... */` compatible con TerosHDL, preservando el autor original (`hidalgojeulin`) en los 4 testbenches escritos por el compañero y usando `JustinAlfaro` en los restantes.

---

### 7. Asistencia puntual durante el desarrollo (esta sesión)

Durante la sesión de revisión final, el modelo respondió consultas técnicas sobre el proyecto y corrigió un error en el archivo de proyecto de Vivado.

**Prompt:**
> "¿Porqué usamos imágenes de 160x120 pixeles y cómo fue que los escalamos?"

**Respuesta del modelo:**
> La resolución reducida permite almacenar 16× menos datos en BRAM. El escalado se realiza descartando los 2 bits bajos de cada coordenada (`h_count[9:2]`, `v_count[8:2]`), lo que repite cada píxel en un bloque de 4×4 píxeles en pantalla sin usar multiplicadores ni divisores.

---

**Prompt:**
> "Antes me dijiste que hicimos 9 testbenches: 8 modulares y uno integrador, pero ese testbench integrador no me aparece cuando abro Vivado."

**Respuesta del modelo:**
> Se inspeccionó el archivo `Project_1.xpr` y se detectó que solo 4 de los 8 testbenches estaban declarados en el `FileSet sim_1`. Los 4 faltantes (`tb_binary_bcd_decoder`, `tb_fsm_adjust_mode`, `tb_hour_converter`, `tb_integration`) existían en disco pero no estaban registrados en el proyecto Vivado. Se agregaron manualmente al `.xpr` con el atributo `AutoDisabled` para que aparezcan en el panel de Simulation Sources sin interferir con el top activo.

---

## Consideraciones éticas y académicas

- El uso de IA fue una herramienta de productividad, no un sustituto del aprendizaje.
- Todos los resultados generados por el modelo fueron revisados, comprendidos y validados antes de ser integrados al proyecto.
- El desarrollador entiende el funcionamiento de cada módulo, testbench y script presente en el repositorio.
- El modelo cometió errores (ejemplo: indicar incorrectamente que había 9 testbenches en lugar de 8) que fueron detectados y corregidos por el desarrollador.
