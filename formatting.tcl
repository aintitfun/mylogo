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

    set command [regsub {repeat ([^\s]+)} $command { for { set XXXXX1 0 } { $XXXXX1<\1 } {incr XXXXX1 } } ]
    set command [regsub {repeat ([^\s]+)} $command { for { set XXXXX2 0 } { $XXXXX2<\1 } {incr XXXXX2 } } ]
    set command [regsub {repeat ([^\s]+)} $command { for { set XXXXX3 0 } { $XXXXX3<\1 } {incr XXXXX3 } } ]
    set command [regsub {repeat ([^\s]+)} $command { for { set XXXXX4 0 } { $XXXXX4<\1 } {incr XXXXX4 } } ]
    set command [regsub {repeat ([^\s]+)} $command { for { set XXXXX5 0 } { $XXXXX5<\1 } {incr XXXXX5 } } ]
    set command [regsub {repeat ([^\s]+)} $command { for { set XXXXX6 0 } { $XXXXX6<\1 } {incr XXXXX6 } } ]

}
#This is to format correctly the commands and procedures (\n before each command).
#Also we should apply these to our procedure names as they are new commands,
#but we should ensure to not apply on procedure header (proc \n name throws error on tcl)
proc SetSeparationOnEachCommand {command} {
    # para poder soportar más de un comando en linea debemos usar el separador de tcl que es el punto y coma
    foreach word $::logoCommands {
        set command [string map [list $word \n$word] $command]
    }
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

proc FormatProcedureHeader {procLine} {

    #quito el corchete de inicio de proc
    set procLine [string replace $procLine [string first "\[" $procLine] [string first "\[" $procLine] "."] 
    #obtengo las distintas partes de la cabecera
    set words [ split $procLine "\ "]
        
    #la segunda palabra debe ser el nombre del proc(la primera es el para que ignoramos)
    set procedureName [lindex $words 1]

    #add command to the logo command list to take into account for separations
    lappend ::logoCommands $procedureName
    
    #el resto han de ser parámetros
    set params [lrange $words 2 end]
    set params [string map {":" ""} $params]

    #pongo las llaves a los parametros
    set headerNew "proc $procedureName \{ $params \} \{"
 
    return $headerNew
}

proc FormatProcedures {myprocedures} {
    #head of the procedure formatting
#    set myprocedures [ regsub {(para )(\w*)( )(:)?(\w*)?( )?(:)?(\w*)?} $myprocedures {\2\{\5\8\}\{} ]

    
    #set myprocedures [FormatProcedureHeader $myprocedures ]
    
    set myprocedures [string map {"fin" \} } $myprocedures]
    set myprocedures [string map {"end" \} } $myprocedures]

    #set myprocedures [string map { \: \$ } $myprocedures]
    
    set myprocedures [ChangeBrackets $myprocedures]
    set lines [split $myprocedures \n]
    
    #iteramos por las lineas para procesar cada cabecera de cada procedimiento
    set pos 0
    foreach line $lines {
        #si la primera palabra es un "para" es que es una cabecera por lo que la procesamos
        #y sustituimos la linea
        #en caso contrario añadimos la linea y le aplicamos los separadores (en el header no se
        #deben aplicar puesto que: "proc \n myproc" da error en tcl por el salto de linea).
        if {[string first "para" $line] == 0 || [string first "to" $line] == 0} {
            lappend procLines [FormatProcedureHeader $line]
        } else {
            lappend procLines [SetSeparationOnEachCommand $line]
        }
    incr pos
    }

    return [join $procLines \n]
}

#procedimientos auxiliares de movimiento



proc haz {variable value} {
    upvar $variable _variable
    set _variable [expr $value]
}
