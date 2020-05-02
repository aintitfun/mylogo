#variables 

array set position {
    posx 0
    posy 0
}
array set positionNew {
    posx 0
    posy 0
}

set rumbo 45

canvas .can

#dibujado

#set a [getRadians 270]
#puts $a

av 100
av 200

#.can create line 0 0 100 100

pack .can

#procedimientos generales
proc getRadians { grads } {
    return [expr 6.2831853*$grads/360]
}


#procedimientos movimiento
proc av {puntos} {
    set ::positionNew(posx) [expr  $::position(posx)+cos([getRadians $::rumbo]) * $puntos ]
    set ::positionNew(posy) [expr  $::position(posy)+sin( [getRadians $::rumbo] )* $puntos ]
    
    puts "$::positionNew(posx) $::positionNew(posy)"
    
    
   
    ::.can create line $::position(posx) $::position(posy) $::positionNew(posx) $::positionNew(posy) 
}






