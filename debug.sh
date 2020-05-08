lscpu | grep Arch | grep 64
if [ $? -eq 0 ]
then
./dbgp_tcldebug -dbgp localhost:9000 -app-file milogo.tcl \
        -app-shell /usr/bin/wish
else 
./dbgp_tcldebug_32 -dbgp localhost:9000 -app-file milogo.tcl \
        -app-shell /usr/bin/wish
fi
