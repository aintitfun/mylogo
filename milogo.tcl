lappend auto_path /zvfs/home/papa/Documentos/fuentes/mylogo
#lappend auto_path /zvfs/usr/lib/tcltk/x86_64-linux-gnu/itk4.1.0
#lappend auto_path /home/papa/Documentos/fuentes/mylogo/itk4.1.0
#lappend auto_path /zvfs/papa/Documentos/fuentes/mylogo/itk4.1.0
#lappend auto_path /usr/share/tcltk/itk3.4
#lappend auto_path /usr/lib/tcltk/x86_64-linux-gnu/itk3.4

#package require Tk 8.6
#package require Iwidgets
#lappend auto_path "awthemes-10.3.0/"
#package require awdark

if { [ file exists "/home/papa/Documentos/fuentes/mylogo/load.png" ] == 0 } {
   set freewrapPath /zvfs/home/papa/Documentos/fuentes/mylogo
} else {
   set freewrapPath /home/papa/Documentos/fuentes/mylogo
}

ttk::setTheme clam
package require Ttk

#turtle variables
array set position {
    posx -200
    posy -200
}

array set positionNew {
    posx 0
    posy 0
}

set heading 0
set WIDTH 1024
set HEIGHT 768
set HALFWIDTH [expr $WIDTH/2]
set isPenDown 1

#otras variables
set logoCommands {av gd gi repite haz bp sl bla}
set myhistory ""

##########################################################################
#                          wm & #controls
##########################################################################
wm geometry . "$WIDTH\x$HEIGHT"

ttk::panedwindow .panedWindow \
	-orient horizontal \

ttk::frame .panedWindow.drawing 
ttk::frame .panedWindow.editor
ttk::frame .panedWindow.editor.toolBar
.panedWindow add .panedWindow.drawing 
.panedWindow add .panedWindow.editor 

canvas .panedWindow.drawing.window -width 700
text .panedWindow.editor.proceduresText 
label .panedWindow.drawing.commandsLabel -text "Immediate Commands Window:"
ttk::entry .panedWindow.drawing.commandsEntry -textvar commandsVar

#iwidgets::toolbar .panedWindow.editor.toolBar \
#   -balloonbackground #336699 \
#	-balloonforeground white \
#	-balloondelay1 500 \
#	-balloondelay2 150 \
#	-orient horizontal \
#	-helpvariable helpVar



ttk::button .panedWindow.editor.toolBar.load -image [image create photo -file [file join $freewrapPath load.png]] -command load
ttk::button .panedWindow.editor.toolBar.save -image [image create photo -file [file join $freewrapPath save.png]] -command save
label .panedWindow.editor.proceduresLabel -text "Logo Editor(procedure editor):"
#.panedWindow.editor.toolBar add button load \
#		-balloonstr "load a script" \
#		-helpstr "this will load a logo script" \
#		-command load \
#		-image [image create photo -file load.png]
#.panedWindow.editor.toolBar add frame spacer \
#   -borderwidth 1 \
#	-width 10 \
#	-height 10
#.panedWindow.editor.toolBar add button save \
#		-balloonstr "save a script" \
#		-helpstr "this will save a logo script" \
#		-command save \
#		-image [image create photo -file save.png]

canvas .turtle -width 10 -height 10 
.turtle create poly 1 1 10 5  1 10 -fill yellow -outline green  -tag turtle

pack .panedWindow.drawing.window \
   -fill both \
   -expand 1

pack .panedWindow.editor.toolBar -side top
pack .panedWindow.editor.toolBar.load -side left -anchor n
pack .panedWindow.editor.toolBar.save -side left -anchor n
pack .panedWindow.editor.proceduresLabel -side top -anchor w
pack .panedWindow.editor.proceduresText -anchor e -side bottom -expand 1 -fill both

#grid .panedWindow.editor.load -column 0 -row 0 -columnspan 1 -rowspan 1
#grid .panedWindow.editor.save -column 1 -row 0 -columnspan 1 -rowspan 1
#grid .panedWindow.editor.proceduresText -column 0 -row 1 -columnspan 26 -rowspan 1 
pack .panedWindow.drawing.commandsLabel -anchor w
pack .panedWindow.drawing.commandsEntry \
   -fill x

#pack .panedWindow.editor.toolBar \
#	-fill x \
#	-pady 5

pack .panedWindow \
	-fill both \
	-expand 1


#procedimientos generales
proc getRadians { degrees } {
    return [expr 6.2831853*$degrees/360]
} 

#https://wiki.tcl-lang.org/page/Canvas+Rotation
proc RotateItem {w tagOrId Ox Oy angle} {
   set angle [expr {$angle * atan(1) * 4 / 180.0}] ;# Radians
   foreach id [$w find withtag $tagOrId] {     ;# Do each component separately
       set xy {}
       foreach {x y} [$w coords $id] {
           # rotates vector (Ox,Oy)->(x,y) by angle clockwise

           set x [expr {$x - $Ox}]             ;# Shift to origin
           set y [expr {$y - $Oy}]

           set xx [expr {$x * cos($angle) - $y * sin($angle)}] ;# Rotate
           set yy [expr {$x * sin($angle) + $y * cos($angle)}]

           set xx [expr {$xx + $Ox}]           ;# Shift back
           set yy [expr {$yy + $Oy}]
           lappend xy $xx $yy
       }
       $w coords $id $xy
   }
}


proc ReDrawTurtle {} {
    #.window move turtle [expr $::position(posx)+$::HALFWIDTH] [expr $::position(posy)+$::HALFWIDTH]
    .turtle delete -tag turtle
    .turtle create poly 1 1 10 5  1 10 -fill yellow -outline green  -tag turtle
    RotateItem .turtle turtle 5 5 $::heading
    place configure .turtle -x [expr $::position(posx)+$::HALFWIDTH-5] -y [expr $::position(posy)+$::HALFWIDTH-5]
    #.window coords turtle 100 100
    update
}

proc ReDraw {} {
    if { $::isPenDown eq 1} {
        upvar #0 cs cs
        .panedWindow.drawing.window create line [expr $::position(posx)+$::HALFWIDTH] [expr $::position(posy)+$::HALFWIDTH] [expr $::positionNew(posx)+$::HALFWIDTH] [expr $::positionNew(posy)+$::HALFWIDTH] -fill black
    }
    set ::position(posx) $::positionNew(posx)
    set ::position(posy) $::positionNew(posy)
    update
    #ShowTurtle
}

proc FormatRepeats {command} {
    #set command [string map {repite \nav} $command]   

    #buscamos en la expresion regular el repite más lo ue siga hasta que encontremos un espacio
    #set command [regsub -all {repite ([^\s]+)} $command { for { set XXXXX($::forVariablesSequentia) 0 } { $XXXXX($::forVariablesSequentia)<\1 } {incr XXXXX($::forVariablesSequentia) } } ]
    #ademas soportamos hasta 6 niveles de anidacion por eso no le ponemos un -all al regsub y cambiamos el nombre de variable en cada sustitucion, para que no colisionen.
    set command [regsub {repite ([^\s]+)} $command { for { set XXXXX1 0 } { $XXXXX1<\1 } {incr XXXXX1 } } ]
    set command [regsub {repite ([^\s]+)} $command { for { set XXXXX2 0 } { $XXXXX2<\1 } {incr XXXXX2 } } ]
    set command [regsub {repite ([^\s]+)} $command { for { set XXXXX3 0 } { $XXXXX3<\1 } {incr XXXXX3 } } ]
    set command [regsub {repite ([^\s]+)} $command { for { set XXXXX4 0 } { $XXXXX4<\1 } {incr XXXXX4 } } ]
    set command [regsub {repite ([^\s]+)} $command { for { set XXXXX5 0 } { $XXXXX5<\1 } {incr XXXXX5 } } ]
    set command [regsub {repite ([^\s]+)} $command { for { set XXXXX6 0 } { $XXXXX6<\1 } {incr XXXXX6 } } ]

}
#This is to format correctly the commands and procedures (\n before each command).
#Also we should apply these to our procedure names as they are new commands,
#but we should ensure to not apply on procedure header (proc \n name throws error on tcl)
proc SetSeparationOnEachCommand {command} {
    # para poder soportar más de un comando en linea debemos usar el separador de tcl que es el punto y coma
    foreach word $::logoCommands {
        set command [string map [list $word \n$word] $command]
    }
    # también tenemos que hacer lo mismo para los procedimientos hechos por el usuario
    #...
    return $command
}

proc ChangeBrackets {command} {
    # necesitamos cambiar los corchetes por llaves para que lo entienda tcl
    set command [string map {\[ \{} $command]
    set command [string map {\] \}} $command]   
}

proc FormatVariables {command} {
    #quitamos las comillas dobles de los haz
    set command [string map {\" \ } $command]
    set command [regsub -all {:([a-z]*[0-9]*)} $command {$\1} ]
    return $command
}

proc FormatCommand {command} {
    set command [SetSeparationOnEachCommand $command]
    set command [ChangeBrackets $command]
    set command [FormatVariables $command]
    return $command
}

proc FormatProcedureHeader {procLine} {

    #quito el corchete de inicio de proc
    set procLine [string replace $procLine [string first "\[" $procLine] [string first "\[" $procLine] "."] 
    #obtengo las distintas partes de la cabecera
    set words [ split $procLine "\ "]
        
    #la segunda palabra debe ser el nombre del proc(la primera es el para que ignoramos)
    set procedureName [lindex $words 1]

    #add command to the logo command list to take into account for separations
    lappend ::logoCommands $procedureName
    
    #el resto han de ser parámetros
    set params [lrange $words 2 end]
    set params [string map {":" ""} $params]

    #pongo las llaves a los parametros
    set headerNew "proc $procedureName \{ $params \} \{"
 
    return $headerNew
}

proc FormatProcedures {myprocedures} {
    #head of the procedure formatting
#    set myprocedures [ regsub {(para )(\w*)( )(:)?(\w*)?( )?(:)?(\w*)?} $myprocedures {\2\{\5\8\}\{} ]

    
    #set myprocedures [FormatProcedureHeader $myprocedures ]
    
    set myprocedures [string map {"fin" \} } $myprocedures]
    #set myprocedures [string map { \: \$ } $myprocedures]
    
    set myprocedures [ChangeBrackets $myprocedures]
    set lines [split $myprocedures \n]
    
    #iteramos por las lineas para procesar cada cabecera de cada procedimiento
    set pos 0
    foreach line $lines {
        #si la primera palabra es un "para" es que es una cabecera por lo que la procesamos
        #y sustituimos la linea
        #en caso contrario añadimos la linea y le aplicamos los separadores (en el header no se
        #deben aplicar puesto que: "proc \n myproc" da error en tcl por el salto de linea).
        if {[string first "para" $line] == 0} {
            lappend procLines [FormatProcedureHeader $line]
        } else {
            lappend procLines [SetSeparationOnEachCommand $line]
        }
    incr pos
    }

    return [join $procLines \n]
}

#procedimientos auxiliares de movimiento

proc NormalizeHeading {degrees} {
    if { abs($::heading) > 360 } {
        set ::heading [expr $::heading%360]
    }
    if {$::heading<0} {
      set ::heading [expr $::heading+360]
    }
}

#procedimientos logo
proc av {dots} {
    set ::positionNew(posx) [expr  $::position(posx)+cos([getRadians $::heading]) * $dots ]
    set ::positionNew(posy) [expr  $::position(posy)+sin( [getRadians $::heading] )* $dots ]
    ReDraw
    ReDrawTurtle 
}

proc gd {degrees} {
    set ::heading [expr $::heading+$degrees]
    NormalizeHeading $::heading
    ReDrawTurtle 
}

proc gi {degrees} {
    set ::heading [expr $::heading-$degrees]
    NormalizeHeading $::heading
    ReDrawTurtle 
}



proc bla {} {
    set ::isPenDown 1
}

proc sl {} {
    set ::isPenDown 0
}


proc haz {variable value} {
    upvar $variable _variable
    set _variable [expr $value]
}
 

proc re {dots} {
     set ::positionNew(posx) [expr  $::position(posx)-cos([getRadians $::heading]) * $dots ]
     set ::positionNew(posy) [expr  $::position(posy)-sin( [getRadians $::heading] )* $dots ]
     ReDraw
     ReDrawTurtle 
}

proc bp {} {
        set ::position(posx) -200
        set ::position(posy) -200
        set ::heading 0
        
        upvar #0 cs cs
        .panedWindow.drawing.window delete all
   ReDrawTurtle
}

################################### START OF THE PROGRAM ITSELF
#1st of all a clear screen 

source [file join $freewrapPath  procedure_alias.tcl ]
bp

global myhistory
global myhistory_pos 0

#proc bgproc {script} {
#    thread::send -async 1 $script _result
#    vwait _result
#    return $::_result
#}

#events
bind .panedWindow.drawing.commandsEntry <Key> {
   if {"%K" in {Enter Return}} {
      
      set proceduresText [.panedWindow.editor.proceduresText get 1.0 end]
      if { [string trim $proceduresText] != "" } {
          set tmp [FormatProcedures $proceduresText]
          set tmp [FormatRepeats $tmp]
          set tmp [FormatVariables $tmp]
          eval $tmp
          puts $tmp
      }
      set tmp [FormatCommand $commandsVar]
      set tmp [FormatRepeats $tmp]
      eval  $tmp
      lappend ::myhistory [list $commandsVar]
      set commandsVar ""
        set  myhistory_pos 0
   }
    
   if {"%K" in {Up}} {
        incr ::myhistory_pos
        if {$myhistory_pos > [expr [llength $myhistory]] } {set myhistory_pos [expr [llength $myhistory]]}
        set tempos [expr [llength $myhistory] - $myhistory_pos ]

        puts [lindex  $myhistory  $tempos]
        set commandsVar [join [lindex  $myhistory $tempos] " "]
   }
    if {"%K" in {Down}} {
        incr ::myhistory_pos -1
        if {$myhistory_pos < 0} {set myhistory_pos 0}

        set tempos [expr [llength $myhistory] - $myhistory_pos ]

        puts [lindex  $myhistory  $tempos]
        set commandsVar [join [lindex  $myhistory $tempos] " "]
   }
}

proc save {} {
    set logofile [open [tk_getSaveFile -initialdir . -confirmoverwrite false] w+]
    puts $logofile [c$(editor).proceduresText get 1.0 end]
    close $logofile
}

proc load {} {
   upvar #0 cs cs 
   set logofile [open [tk_getOpenFile -initialdir .] r]
   .panedWindow.editor.proceduresText insert 1.0 [read $logofile]
   close $logofile
}