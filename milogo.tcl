#variables 

array set position {
    posx 0
    posy 0
}
array set positionNew {
    posx 0
    posy 0
}

set heading 5

wm geometry . 800x800
canvas .window -width 800 -height 800
pack .window

#dibujado

#set a [getRadians 270]
#puts $a

puts [winfo height .]

av 100
gd 90
av 100
gd 90
av 100
gd 90
av 90

#.can create line 0 0 100 100



#procedimientos generales
proc getRadians { degrees } {
    return [expr 6.2831853*$degrees/360]
}

proc redraw {} {
    ::.window create line [expr $::position(posx)+400] [expr $::position(posy)+400] [expr $::positionNew(posx)+400] [expr $::positionNew(posy)+400] 
    set ::position(posx) $::positionNew(posx)
    set ::position(posy) $::positionNew(posy)
}

#procedimientos movimiento
proc av {dots} {
    set ::positionNew(posx) [expr  $::position(posx)+cos([getRadians $::heading]) * $dots ]
    set ::positionNew(posy) [expr  $::position(posy)+sin( [getRadians $::heading] )* $dots ]
   
    redraw
    puts "$::positionNew(posx) $::positionNew(posy)"
}

proc gd {degrees} {
    set ::heading [expr $::heading+$degrees]
    if { abs($::heading) > 360 } {
	set ::heading ::heading%360
    }
}

proc gi {degrees} {
    set ::heading $::heading-$degrees
}




