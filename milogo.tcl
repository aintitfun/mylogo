package require Tk 8.6
lappend auto_path "/home/papa/Descargas/awthemes-10.3.0/"
package require awdark
ttk::setTheme awdark


#variables tortuga
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

#wm & canvas
wm geometry . "$WIDTH\x$HEIGHT"
canvas .window -width $WIDTH -height $WIDTH -bg black
#controls
text .proceduresText -width 41 -height 41
ttk::entry .commandsEntry -textvar commandsVar -width 127
ttk::button .save  -text Save -command {save}
ttk::button .load  -text Load -command {load}
#turtle
canvas .turtle -width 10 -height 10 -bg black
.turtle create poly 1 1 10 5  1 10 -fill yellow -outline green  -tag turtle
#places
#grid .window .commandsEntry .proceduresText 
place .window -x 0 -y 0


place .commandsEntry -x 0 -y [expr $HEIGHT-25]
#pack .proceduresText -side right 
place .proceduresText -x [expr $WIDTH-335] -y 32


#pack .load -side top -padx 200  
#pack .save -side top 
#pack .commandsEntry -side bottom
place .save -x [expr $WIDTH-71] -y 1
place .load -x [expr $WIDTH-131] -y 1

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
    place configure .turtle -x [expr $::position(posx)+$::HALFWIDTH-4] -y [expr $::position(posy)+$::HALFWIDTH-4]
    #.window coords turtle 100 100 
}

proc ReDraw {} {
    if { $::isPenDown eq 1} {
        ::.window create line [expr $::position(posx)+$::HALFWIDTH] [expr $::position(posy)+$::HALFWIDTH] [expr $::positionNew(posx)+$::HALFWIDTH] [expr $::positionNew(posy)+$::HALFWIDTH] -fill white
    }
    set ::position(posx) $::positionNew(posx)
    set ::position(posy) $::positionNew(posy)
    
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

#procedimientos movimiento
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

proc NormalizeHeading {degrees} {
    if { abs($::heading) > 360 } {
        set ::heading [expr $::heading%360]
    }
    if {$::heading<0} {
      set ::heading [expr $::heading+360]
    }
}

proc bl {} {
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
        .window delete all
   ReDrawTurtle
}

#1st of all a clear screen 
bp

global myhistory "start"
global myhistory_pos 0


#events
bind .commandsEntry <Key> {
   if {"%K" in {Enter Return}} {
      
      set proceduresText [.proceduresText get 1.0 end]
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
      lappend ::myhistory $tmp
      set commandsVar "" 
   }
    
   if {"%K" in {Up}} {
      incr ::myhistory_pos
      set tempos ::$myhistory_pos
      puts [lindex [ expr ( [ llength ::$myhistory ] - tempos ) ] ::$myhistory] 
   }
}

proc save {} {
    set logofile [open [tk_getSaveFile -initialdir . -confirmoverwrite false] w+]
    puts $logofile [.proceduresText get 1.0 end]
    close $logofile
}

proc load {} {
   set logofile [open [tk_getOpenFile -initialdir .] r]
   .proceduresText insert 1.0 [read $logofile]
   close $logofile
}