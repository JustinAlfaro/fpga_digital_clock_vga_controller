# Script      : run_synth_impl.tcl
# Descripcion : Abre el proyecto Vivado, lanza síntesis e implementación
#               y cierra. Invocado por parse_utilization.sh en modo batch.
# Uso         : vivado -mode batch -source run_synth_impl.tcl \
#                       -tclargs <project.xpr>

set xpr [lindex $argv 0]
open_project $xpr

reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    puts "ERROR: La síntesis falló."
    close_project
    exit 1
}

reset_run impl_1
launch_runs impl_1 -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
    puts "ERROR: La implementación falló."
    close_project
    exit 1
}

close_project
exit 0
