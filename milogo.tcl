#variables 

array set position {
    posx 0
    posy 0
}
array set position_new {
    posx 0
    posy 0
}

set rumbo 180

#dibujado
canvas .can

av 100
av 200

#.can create line 0 0 100 100

pack .can

#procedimientos movimiento
proc av {puntos} {
    set ::position_new(posx) [expr  $::position(posx)+$puntos ]
    set ::position_new(posy) [expr  $::position(posy)+$puntos ]
    ::.can create line $::position(posx) $::position(posy) $::position_new(posx) $::position_new(posy) 
}






