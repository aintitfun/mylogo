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


#widgets
wm geometry . "$WIDTH\x$HEIGHT"
canvas .window -width $WIDTH -height $WIDTH
text .proceduresText -width 40 -height 27
entry .commandsEntry -textvar commandsVar -width 100
grid .window .commandsEntry .proceduresText
place .window -x 0 -y 0
place .commandsEntry -x 0 -y [expr $HEIGHT-25]
place .proceduresText -x [expr $WIDTH-200] -y 0

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

proc SetSeparationOnEachCommand {command} {
    # para poder soportar más de un comando en linea debemos usar el separador de tcl que es el punto y coma
    set command [string map {av \nav} $command]
    set command [string map {gd \ngd} $command]
    set command [string map {gi \ngi} $command]
    set command [string map {repite \nrepite} $command]
    set command [string map {haz \nhaz} $command]
    set command [string map {bp \nbp} $command]
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

proc FormatProcedureHeader {myprocedures} {
    set lines [ split $myprocedures \n ]
    set header [ lindex $lines 0 ]
    set headerNew ""

    #quito el corchete de inicio de proc
    set header [string replace $header [string first "\[" $header] [string first "\[" $header] "."] 
    #obtengo las distintas partes de la cabecera
    set words [ split $header "\ "]
    set pos 0
    if {[lindex $words 0] != "para"} {
	#lanzar error: la primera palabra de la cabecera debe ser "para"
    }
    
    #la segunda palabra debe ser el nombre del proc
    set procedureName [lindex $words 1]
    
    #el resto han de ser parámetros
    set params [lrange $words 2 end]

    #pongo las llaves a los parametros
    set headerNew "proc $procedureName \{ $params \} \{"  
 
    
    set ret "$headerNew [join [lrange $lines 1 end] \n]"
    return $ret
}

proc FormatProcedures {myprocedures} {
    #head of the procedure formatting
#    set myprocedures [ regsub {(para )(\w*)( )(:)?(\w*)?( )?(:)?(\w*)?} $myprocedures {\2\{\5\8\}\{} ]

    set myprocedures [FormatProcedureHeader $myprocedures ]
    
    set myprocedures [string map {"fin" \} } $myprocedures]
    #set myprocedures [string map { \: \$ } $myprocedures]
    
    set myprocedures [SetSeparationOnEachCommand $myprocedures]
    set myprocedures [ChangeBrackets $myprocedures]
    return $myprocedures
    
}

#procedimientos movimiento
proc av {dots} {
    set ::positionNew(posx) [expr  $::position(posx)+cos([getRadians $::heading]) * $dots ]
    set ::positionNew(posy) [expr  $::position(posy)+sin( [getRadians $::heading] )* $dots ]
    redraw
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
     redraw
}

proc bp {} {
	set ::positionNew(posx) 0
	    set ::positionNew(posy) 100
	set ::heading 0
	.window delete all
}
