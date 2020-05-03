#variables 

array set position {
    posx 0
    posy 0
}
array set positionNew {
    posx 0
    posy 0
}

set heading 45
set WIDTH 400
set HALFWIDTH 200

wm geometry . "$WIDTH\x$WIDTH"
canvas .window -width $WIDTH -height $WIDTH
pack .window

#testing code to draw
repite 18 {
repite 36 {
av 10
gd 10
}
gd 20}



#procedimientos generales
proc getRadians { degrees } {
    return [expr 6.2831853*$degrees/360]
}

proc redraw {} {
    ::.window create line [expr $::position(posx)+$::HALFWIDTH] [expr $::position(posy)+$::HALFWIDTH] [expr $::positionNew(posx)+$::HALFWIDTH] [expr $::positionNew(posy)+$::HALFWIDTH] 
    set ::position(posx) $::positionNew(posx)
    set ::position(posy) $::positionNew(posy)
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
	puts $::heading
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


