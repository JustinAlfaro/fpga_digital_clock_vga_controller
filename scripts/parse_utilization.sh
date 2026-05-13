#!/bin/bash
# Script      : parse_utilization.sh
# Descripcion : Lanza síntesis e implementación en Vivado (batch) y extrae
#               recursos (LUTs, FFs, BRAM, DSPs) y latencia del camino crítico.
# Uso         : ./scripts/parse_utilization.sh [--skip-synth]
#                 --skip-synth  Omite Vivado y usa los reportes existentes.
# Salida      : synth_results/utilizacion.csv
#               synth_results/latencia.csv

VIVADO=/tools/Xilinx/Vivado/2024.1/bin/vivado
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_XPR="$REPO_ROOT/Project_1/Project_1.xpr"
SYNTH_DIR="$REPO_ROOT/Project_1/Project_1.runs/synth_1"
IMPL_DIR="$REPO_ROOT/Project_1/Project_1.runs/impl_1"
RESULTS_DIR="$REPO_ROOT/synth_results"
OUTPUT_CSV="$RESULTS_DIR/utilizacion.csv"
TIMING_CSV="$RESULTS_DIR/latencia.csv"
TCL_SCRIPT="$REPO_ROOT/scripts/run_synth_impl.tcl"

SKIP_SYNTH=0
[[ "$1" == "--skip-synth" ]] && SKIP_SYNTH=1

# ── 1. Síntesis e implementación ─────────────────────────────────────────────
if [[ $SKIP_SYNTH -eq 0 ]]; then
    echo "Lanzando síntesis e implementación (Vivado batch)…"
    "$VIVADO" -mode batch -source "$TCL_SCRIPT" -tclargs "$PROJECT_XPR"
    if [[ $? -ne 0 ]]; then
        echo "Error: Vivado terminó con fallo."
        exit 1
    fi
fi

# ── 2. Recursos ───────────────────────────────────────────────────────────────
RPT_FILE=$(ls "$SYNTH_DIR"/*_utilization_synth.rpt 2>/dev/null | head -1)
if [[ -z "$RPT_FILE" ]]; then
    echo "Error: No se encontró reporte de utilización en $SYNTH_DIR/"
    echo "  Ejecuta primero la síntesis o quita --skip-synth."
    exit 1
fi
echo "Reporte recursos : $RPT_FILE"

parse_row() {
    local pattern="$1" file="$2"
    grep -m1 "| $pattern" "$file" | awk -F'|' '{
        gsub(/[[:space:]]/,"",$3); gsub(/[[:space:]]/,"",$6); gsub(/[[:space:]]/,"",$7);
        print $3","$6","$7
    }'
}

luts=$(parse_row "Slice LUTs"      "$RPT_FILE"); luts=${luts:-"N/A,N/A,N/A"}
ffs=$(parse_row  "Slice Registers" "$RPT_FILE"); ffs=${ffs:-"N/A,N/A,N/A"}
bram=$(parse_row "Block RAM Tile"  "$RPT_FILE"); bram=${bram:-"N/A,N/A,N/A"}
dsps=$(parse_row "DSPs"            "$RPT_FILE"); dsps=${dsps:-"N/A,N/A,N/A"}

mkdir -p "$RESULTS_DIR"
{
    echo "recurso,usado,disponible,util_pct"
    echo "Slice LUTs,$luts"
    echo "Slice Registers,$ffs"
    echo "Block RAM Tile,$bram"
    echo "DSPs,$dsps"
} > "$OUTPUT_CSV"

# ── 3. Latencia (timing post-route) ──────────────────────────────────────────
TIMING_RPT=$(ls "$IMPL_DIR"/*_timing_summary_routed.rpt 2>/dev/null | head -1)
if [[ -z "$TIMING_RPT" ]]; then
    echo "Aviso: No se encontró reporte de timing en $IMPL_DIR/ — omitiendo latencia."
else
    echo "Reporte timing   : $TIMING_RPT"

    # WNS: primera línea numérica tras "Design Timing Summary"
    wns=$(awk '/Design Timing Summary/{f=1} f && /^ *-?[0-9]/{print $1; exit}' "$TIMING_RPT")

    # Período y frecuencia: la línea del reloj tiene la forma
    #   sys_clk_pin  {0.000 5.000}  10.000  100.000
    # Los decimales en orden son: rise, fall, periodo, frecuencia
    clk_line=$(grep -m1 "sys_clk_pin" "$TIMING_RPT")
    period=$(echo "$clk_line" | grep -oP '\d+\.\d+' | sed -n '3p')
    freq=$(echo   "$clk_line" | grep -oP '\d+\.\d+' | sed -n '4p')

    # Retardo del camino crítico (primer valor ns en "Data Path Delay")
    cpd=$(grep -m1 "Data Path Delay:" "$TIMING_RPT" | grep -oP '\d+\.\d+(?=ns)' | head -1)

    # Latencia efectiva = período - WNS  (tiempo máximo real usado)
    if [[ -n "$period" && -n "$wns" ]]; then
        eff=$(LC_ALL=C awk "BEGIN {printf \"%.3f\", $period - ($wns)}")
    else
        eff="N/A"
    fi

    {
        echo "metrica,valor,unidad"
        echo "Reloj,${freq:-N/A},MHz"
        echo "Periodo,${period:-N/A},ns"
        echo "WNS,${wns:-N/A},ns"
        echo "Retardo camino critico,${cpd:-N/A},ns"
        echo "Latencia efectiva (periodo-WNS),${eff},ns"
    } > "$TIMING_CSV"
fi

# ── 4. Impresión en pantalla ──────────────────────────────────────────────────
echo ""
printf "%-22s %8s %12s %8s\n" "Recurso" "Usado" "Disponible" "Util%"
echo "------------------------------------------------------"
while IFS=',' read -r recurso usado disponible util; do
    [[ "$recurso" == "recurso" ]] && continue
    printf "%-22s %8s %12s %8s\n" "$recurso" "$usado" "$disponible" "$util"
done < "$OUTPUT_CSV"

if [[ -f "$TIMING_CSV" ]]; then
    echo ""
    printf "%-35s %10s %6s\n" "Métrica" "Valor" "Unidad"
    echo "------------------------------------------------------"
    while IFS=',' read -r metrica valor unidad; do
        [[ "$metrica" == "metrica" ]] && continue
        printf "%-35s %10s %6s\n" "$metrica" "$valor" "$unidad"
    done < "$TIMING_CSV"
fi

echo ""
echo "CSV recursos : $OUTPUT_CSV"
[[ -f "$TIMING_CSV" ]] && echo "CSV latencia : $TIMING_CSV"
