array set position {
    posx -200
    posy -200
}

array set positionNew {
    posx 0
    posy 0
}

set isPenDown 1

set logoCommands {av re gd gi repite haz bp sl bla fd lt rt cs bk pu pd repeat forward left right clearscreen back penup pendown}
set myhistory ""

set pencilColor 1

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

proc GetTkColor {logoColor} {
   switch $logoColor {
    0 {
        return black
    }
    1 {
        return red
    }
    2 {
        return white 
    }
    default {
         return white
    }
   }
}

proc poncl {logoColor} {
    set ::pencilColor $logoColor
}

proc ReDrawTurtle {} {
   .turtle delete -tag turtle
   .turtle configure -bd 0 -highlightcolor black -highlightthickness 0
   .turtle create poly 1 1 10 5  1 10 -fill white -outline white -tag turtle
   RotateItem .turtle turtle 5 5 $::heading
   place configure .turtle -x [expr $::position(posx)+$::HALFWIDTH-5] -y [expr $::position(posy)+$::HALFWIDTH-5]
   #.window coords turtle 100 100
   update
}

proc ReDraw {} {
   if { $::isPenDown eq 1} {
      upvar #0 cs cs
      set tempColor [ GetTkColor $::pencilColor ]  
      .panedWindow.drawing.window create line \
         [expr $::position(posx)+$::HALFWIDTH] \
         [expr $::position(posy)+$::HALFWIDTH] \
         [expr $::positionNew(posx)+$::HALFWIDTH] \
         [expr $::positionNew(posy)+$::HALFWIDTH] \
         -fill $tempColor
   }
   set ::position(posx) $::positionNew(posx)
   set ::position(posy) $::positionNew(posy)
   update
   #ShowTurtle
}

proc NormalizeHeading {degrees} {
   if { abs($::heading) > 360 } {
      set ::heading [expr $::heading%360]
   }
   if {$::heading<0} {
      set ::heading [expr $::heading+360]
   }
}

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
