lappend auto_path /zvfs/home/papa/Documentos/fuentes/mylogo
lappend auto_path /zvfs/Users/oscar.polo/Documents/fuentes/mylogo/awthemes-10.3.0
lappend auto_path /zvfs/home/papa/Documentos/fuentes/mylogo/awthemes-10.3.0
lappend auto_path "awthemes-10.3.0/"

if { [lindex $tcl_platform(os) 0] eq "Linux" } {
   if { [ file exists "/home/papa/Documentos/fuentes/mylogo/load.png" ] == 0 } {
      set freewrapPath /zvfs/home/papa/Documentos/fuentes/mylogo
   } else {
      set freewrapPath /home/papa/Documentos/fuentes/mylogo
   }
} else {
   if { [ file exists "C:/Users/oscar.polo/Documents/fuentes/mylogo/load.png" ] == 0 } {
      set freewrapPath /zvfs/Users/oscar.polo/Documents/fuentes/mylogo
   } else {
      set freewrapPath "C:/Users/oscar.polo/Documents/fuentes/mylogo"
   }
}

source [file join $freewrapPath  ui.tcl ]
source [file join $freewrapPath  turtle.tcl ]
source [file join $freewrapPath  formatting.tcl ]
source [file join $freewrapPath  procedure_alias.tcl ]

bp


