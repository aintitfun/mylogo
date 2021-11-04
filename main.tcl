#setting the paths to work with freewrap fs both on win & linux
lappend auto_path /zvfs/home/papa/Documentos/fuentes/mylogo
lappend auto_path /zvfs/Users/oscar.polo/Documents/fuentes/mylogo/awthemes-10.3.0
lappend auto_path /zvfs/home/papa/Documentos/fuentes/mylogo/awthemes-10.3.0
lappend auto_path "awthemes-10.3.0/"

if { [lindex $tcl_platform(os) 0] eq "Linux" } {
   if { [ string first "/zvfs" [ info script ] ] == 0 } {
      set freewrapPath /zvfs/home/papa/Documentos/fuentes/mylogo
   } else {
      set freewrapPath [pwd]
   }
} else {
   if { [ string first "/zvfs" [ info script ] ] == 0 } {
      set freewrapPath /zvfs/Users/oscar.polo/Documents/fuentes/mylogo
   } else {
      set freewrapPath [pwd]
   }
}

source [file join $freewrapPath  ui.tcl ] 
source [file join $freewrapPath  turtle.tcl ]
source [file join $freewrapPath  formatting.tcl ]
source [file join $freewrapPath  procedure_alias.tcl ]

bp


