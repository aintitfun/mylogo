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
set WIDTH 800
set HEIGHT 500
set HALFWIDTH [expr $WIDTH/2]
set isPenDown 1
global variablesArray
global proceduresArray

#widgets
wm geometry . "$WIDTH\x$HEIGHT"
canvas .window -width $WIDTH -height $WIDTH
text .proceduresText -width 40 -height 27
entry .commandsEntry -textvar commandsVar -width 100
grid .window .commandsEntry .proceduresText
place .window -x 0 -y 0
place .commandsEntry -x 0 -y [expr $HEIGHT-25]
place .proceduresText -x [expr $WIDTH-200] -y 0

#events
bind .commandsEntry <Key> {
    if {"%K" in {Enter Return}} {
	
	set mytext [.proceduresText get 1.0 end]
	set tmp2 [FormatProcedures $mytext]
	eval [FormatCommand $tmp2 ]
	puts $tmp2
	eval  [FormatCommand $commandsVar]
	set commandsVar "" 
    }
}



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

proc FormatCommand {command} {
    #quitamos las comillas dobles de los haz
    set command [string map {\" \ } $command]
    #set ::commandsVar [string map {\: \$\:\:variables\( } $::commandsVar]
    set command [regsub -all {:([a-z]*[0-9]*)} $command {$::variablesArray(\1)} ]
    # necesitamos cambiar los corchetes por llaves para que lo entienda tcl
    set command [string map {\[ \{} $command]
    set command [string map {\] \}} $command]
    # para poder soportar más de un comando en linea debemos usar el separador de tcl que es el punto y coma
    set command [string map {av ;av} $command]
    set command [string map {gd ;gd} $command]
    set command [string map {gi ;gi} $command]
    set command [string map {repite ;repite} $command]
    set command [string map {haz ;haz} $command]
    set command [string map {bp ;bp} $command]
    # también tenemos que hacer lo mismo para los procedimientos hechos por el usuario
    #...
    return $command
}

proc FormatProcedures {myprocedures} {

	
	#if {$myprocedures -neq ""} {
    		set myprocedures [regsub -all {para ([a-z]*[0-9]*)\n} $myprocedures  "proc \\1  \{\} \{ " ]
    		#set myprocedures [string map {"para" "proc" } $myprocedures]
	    	set myprocedures [string map {"fin" \} } $myprocedures]
    		#set myprocedures [string map {\[\ \] \{\}\ \{} $myprocedures]
	#}
	return $myprocedures
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
