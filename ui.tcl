ttk::setTheme awdark
package require Ttk
package require tooltip

set heading 0
set WIDTH 1024
set HEIGHT 768
set HALFWIDTH [expr $WIDTH/2]

wm geometry . "$WIDTH\x$HEIGHT"
ttk::panedwindow .panedWindow	-orient horizontal 
ttk::frame .panedWindow.drawing 
ttk::frame .panedWindow.editor
ttk::frame .panedWindow.editor.toolBar
.panedWindow add .panedWindow.drawing 
.panedWindow add .panedWindow.editor 
canvas .panedWindow.drawing.window -width 700 -bg black -highlightthickness 0 
text .panedWindow.editor.proceduresText 
ttk::label .panedWindow.drawing.commandsLabel -text "Immediate Commands Window:"
ttk::entry .panedWindow.drawing.commandsEntry -textvar commandsVar
ttk::button .panedWindow.editor.toolBar.load -image [image create photo -file [file join $freewrapPath load.png]] -command load
ttk::button .panedWindow.editor.toolBar.save -image [image create photo -file [file join $freewrapPath save.png]] -command save
ttk::label .panedWindow.editor.proceduresLabel -text "Logo Editor(procedure editor):"
canvas .turtle -width 10 -height 10 -bg black -highlightcolor black
.turtle create poly 1 1 10 5  1 10 -fill white -tag turtle

tooltip::tooltip .panedWindow.editor.toolBar.save "Save Logo Editor contents to file"
tooltip::tooltip .panedWindow.editor.toolBar.load "Load LOGO file contents to Logo Editor"

pack .panedWindow.drawing.window -fill both -expand 1
pack .panedWindow.editor.toolBar -side top -pady 5 -fill x 
pack .panedWindow.editor.toolBar.load  -side left
pack .panedWindow.editor.toolBar.save -side left
pack .panedWindow.editor.proceduresLabel -side top -anchor w
pack .panedWindow.editor.proceduresText -anchor e -side bottom -expand 1 -fill both
pack .panedWindow.drawing.commandsLabel -anchor w
pack .panedWindow.drawing.commandsEntry -fill x
pack .panedWindow -fill both -expand 1

bind .panedWindow.drawing.commandsEntry <Key> {
   if {"%K" in {Enter Return}} {
      
      set proceduresText [.panedWindow.editor.proceduresText get 1.0 end]
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
      lappend ::myhistory [list $commandsVar]
      set commandsVar ""
        set  myhistory_pos 0
   }
    
   if {"%K" in {Up}} {
        incr ::myhistory_pos
        if {$myhistory_pos > [expr [llength $myhistory]] } {set myhistory_pos [expr [llength $myhistory]]}
        set tempos [expr [llength $myhistory] - $myhistory_pos ]

        puts [lindex  $myhistory  $tempos]
        set commandsVar [join [lindex  $myhistory $tempos] " "]
   }
    if {"%K" in {Down}} {
        incr ::myhistory_pos -1
        if {$myhistory_pos < 0} {set myhistory_pos 0}

        set tempos [expr [llength $myhistory] - $myhistory_pos ]

        puts [lindex  $myhistory  $tempos]
        set commandsVar [join [lindex  $myhistory $tempos] " "]
   }
}

proc save {} {
    set logofile [tk_getSaveFile -initialdir . -confirmoverwrite false]
    if {$logofile != "" } {
      set myfile [ open $logofile w+ ]
      puts $myfile [.panedWindow.editor.proceduresText get 1.0 end]
      close $myfile
    }
}

proc load {} {
   upvar #0 cs cs 
   set logofile [tk_getOpenFile -initialdir .]
   if {$logofile != ""} {
      set myfile [open $logofile r]
      .panedWindow.editor.proceduresText insert 1.0 [read $myfile]
      close $myfile
   }
}