#variables 
array set position {
    posx 0
    posy 0
}

array set positionNew {
    posx 0
    posy 0
}

set heading 0
set WIDTH 400
set HEIGHT [expr $WIDTH+100]
set HALFWIDTH [expr $WIDTH/2]
set isPenDown 1
global variablesArray
global proceduresArray

#ventana y canvas
wm geometry . "$WIDTH\x$HEIGHT"
canvas .window -width $WIDTH -height $WIDTH
pack .window

#entrada de comandos
pack [entry .commandsEntry -textvar commandsVar -width 50]
bind .commandsEntry <Key> {
    if {"%K" in {Enter Return}} {
	ParseCommand
	eval  $commandsVar
	set commandsVar "" 
    }
}

#testing code to draw
#repite 18 {
#repite 36 {
#;av 100
#;gd 100
#}
#gd 20}



#procedimientos generales
proc getRadians { degrees } {
    return [expr 6.2831853*$degrees/360]
}

proc redraw {} {
    if { $::isPenDown eq 1} {
	::.window create line [expr $::position(posx)+$::HALFWIDTH] [expr $::position(posy)+$::HALFWIDTH] [expr $::positionNew(posx)+$::HALFWIDTH] [expr $::positionNew(posy)+$::HALFWIDTH] 
    }
    set ::position(posx) $::positionNew(posx)
    set ::position(posy) $::positionNew(posy)
}

proc ParseCommand {} {
    #quitamos las comillas dobles de los haz
    set ::commandsVar [string map {\" \ } $::commandsVar]
    #set ::commandsVar [string map {\: \$\:\:variables\( } $::commandsVar]
    set ::commandsVar [regsub -all {:([a-z]*[0-9]*)} $::commandsVar {$::variablesArray(\1)} ]
    # necesitamos cambiar los corchetes por llaves para que lo entienda tcl
    set ::commandsVar [string map {\[ \{} $::commandsVar]
    set ::commandsVar [string map {\] \}} $::commandsVar]
    # para poder soportar más de un comando en linea debemos usar el separador de tcl que es el punto y coma
    set ::commandsVar [string map {av ;av} $::commandsVar]
    set ::commandsVar [string map {gd ;gd} $::commandsVar]
    set ::commandsVar [string map {gi ;gi} $::commandsVar]
    set ::commandsVar [string map {repite ;repite} $::commandsVar]
    set ::commandsVar [string map {haz ;haz} $::commandsVar]
    set ::commandsVar [string map {bp ;bp} $::commandsVar]
    # también tenemos que hacer lo mismo para los procedimientos hechos por el usuario
    #...
}

#procedimientos movimiento
proc av {dots} {
    set ::positionNew(posx) [expr  $::position(posx)+cos([getRadians $::heading]) * $dots ]
    set ::positionNew(posy) [expr  $::position(posy)+sin( [getRadians $::heading] )* $dots ]
    redraw
    #puts "$::positionNew(posx) $::positionNew(posy)"
}

proc gd {degrees} {
    set ::heading [expr $::heading+$degrees]
    NormalizeHeading $::heading
}

proc gi {degrees} {
    set ::heading [expr $::heading-$degrees]
    NormalizeHeading $::heading
}

proc NormalizeHeading {degrees} {
    if { abs($::heading) > 360 } {
	set ::heading [expr $::heading%360]
    }
    if {$::heading<0} {
      set ::heading [expr $::heading+360]
    }
}

proc repite { cont commands} {
    for {set i 0} {$i<$cont} {incr i} {
	eval $commands
    }
}

proc bl {} {
    set ::isPenDown 1
}

proc sl {} {
    set ::isPenDown 0
}

proc haz {variable value} {
    eval "set ::variablesArray($variable) [expr $value]"
}

proc re {dots} {
     set ::positionNew(posx) [expr  $::position(posx)-cos([getRadians $::heading]) * $dots ]
     set ::positionNew(posy) [expr  $::position(posy)-sin( [getRadians $::heading] )* $dots ]
     redraw
}

proc bp {} {
	set ::positionNew(posx) 0
    	set ::positionNew(posy) 0
	set ::heading 0
	.window delete all
}
