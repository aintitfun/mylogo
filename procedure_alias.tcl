set LogoPrimitives {
   {av avanza fd forward}
   {re retrocede bk back}
   {gd giraderecha rt right}
   {gi giraizquierda lt left}
   {dummy repite dummy repeat}
   {dummy haz dummy make}
   {bp borrapantalla cs clearscren}
   {sl subelapiz pu penup}
   {bla bajalapiz pd pendown}
   {ponpl ponpaleta dummy dummy}
   {ot ocultatortuga dummy dummy}
   {mt muestratortuga dummy dummy}
}

proc dummy {} {
    
}

foreach {primitive} $::LogoPrimitives {
    for {set i 1} {$i<[llength $primitive]} {incr i} {
        set arguments [info args [lindex $primitive 0]]
        set bodyArguments ""
        if { $arguments != ""} { set bodyArguments "\$$arguments" }
        set primitiveToClone [lindex $primitive 0]
        set alias [lindex $primitive $i]
        set command "proc $alias \{ $arguments \} \{ $primitiveToClone $bodyArguments \}"
        eval $command
    }
}


