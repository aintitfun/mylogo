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
	if { [string trim $mytext] != "" } {
	    set tmp2 [FormatProcedures $mytext]
	    eval $tmp2 
	    puts $tmp2
	}
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

proc ReplaceRepeats {command} {
    #set command [string map {repite \nav} $command]   
    #set command [regsub -all {repite([0-9]*)} $command {for \{set i 0\}\{\$i<(\1)\}\{incr \$i\}\{"} ]
    set command [regsub -all {repite ([^\s]+)} $command { for { set i 0 } { $i<\1 } {incr i } } ]
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
    set command [regsub -all {:([a-z]*[0-9]*)} $command {$::\1} ]
    return $command
}

proc FormatCommand {command} {
    set command [SetSeparationOnEachCommand $command]
    set command [ChangeBrackets $command]
    set command [FormatVariables $command]
    #set command [ReplaceRepeats $command]
    
    return $command
}

proc FormatProcedures {myprocedures} {
    set 1stline [string range $myprocedures 0 [string first \n $myprocedures] ]
    set 1stline [string map {para proc} $1stline ]
    set firstpointspos [string first ":" $1stline]
    if {$firstpointspos > -1 } {
        set variables [ string range $1stline $firstpointspos+1  [ string length $1stline ]  ]
        
        set 1stline [string replace $1stline $firstpointspos $firstpointspos "\{"]
        #previous command removes the first ":" but we need to remove the rest if there are more variables
        set 1stline [string map { ":" ""}  $1stline ]
    
        set 1stline [string map { "\n" "\} \{\n" } $1stline]
    } else {
        set 1stline [string map { "\n" " \{\} \{\n" } $1stline]

    }
    set tempa [string first "\{" $1stline ]
    set tempb [expr {[string first \n $myprocedures]+2}]
    if { $tempa == $tempb } {
        set 1stline [ string map { "\} \{\n" " \{\} \{\n" } $1stline ]
	}

    set rest [string range $myprocedures [string first \n $myprocedures] [string length $myprocedures]]
    set myprocedures "$1stline $rest "
	set myprocedures [string map {"fin" \} } $myprocedures]
    set myprocedures [string map { \: \$ } $myprocedures]
    
    set myprocedures [SetSeparationOnEachCommand $myprocedures]
    set myprocedures [ChangeBrackets $myprocedures]
    set myprocedures [ReplaceRepeats $myprocedures]
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

set comment {
proc repite { cont commands} {
    for {set i 0} {$i<$cont} {incr i} {
	eval $commands
    }
}
}

proc bl {} {
    set ::isPenDown 1
}

proc sl {} {
    set ::isPenDown 0
}


proc haz {variable value} {
    set command "global $variable;set ::$variable [expr $value]"
    eval $command
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
