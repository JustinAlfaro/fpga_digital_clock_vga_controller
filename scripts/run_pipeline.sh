#!/bin/bash
# Script      : run_pipeline.sh
# Descripcion : Script maestro que ejecuta el pipeline completo:
#               1. Simula todos los testbenches (run_sim.sh)
#               2. Parsea los logs y genera el CSV de resultados (parse_sim_logs.sh)
#               3. Lanza síntesis+implementación y extrae recursos y latencia
#                  (parse_utilization.sh)
# Uso         : ./scripts/run_pipeline.sh [--skip-synth]
#                 --skip-synth  Omite Vivado en el paso 3; usa reportes existentes.

SKIP_SYNTH_FLAG=""
[[ "$1" == "--skip-synth" ]] && SKIP_SYNTH_FLAG="--skip-synth"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS=("run_sim.sh" "parse_sim_logs.sh" "parse_utilization.sh")
NAMES=("Ejecutar simulaciones" "Parsear logs y generar CSV" "Síntesis, recursos y latencia")

for i in "${!SCRIPTS[@]}"; do
    script="$SCRIPT_DIR/${SCRIPTS[$i]}"
    name="${NAMES[$i]}"

    echo ""
    echo "========================================"
    echo "Paso $((i+1))/${#SCRIPTS[@]}: $name"
    echo "========================================"

    if [[ ! -x "$script" ]]; then
        echo "Error: $script no encontrado o sin permisos de ejecucion."
        echo "  Ejecuta: chmod +x scripts/*.sh"
        exit 1
    fi

    args=""
    [[ "$script" == *parse_utilization.sh && -n "$SKIP_SYNTH_FLAG" ]] && args="$SKIP_SYNTH_FLAG"
    bash "$script" $args

    if [[ $? -ne 0 ]]; then
        echo ""
        echo "Error: fallo el paso $((i+1)) ($script). Pipeline detenido."
        exit 1
    fi
done

echo ""
echo "========================================"
echo "Pipeline completado."
echo "Resultados simulación : sim_results/resultados.csv"
echo "Recursos FPGA         : synth_results/utilizacion.csv"
echo "Latencia              : synth_results/latencia.csv"
echo "========================================"
