
if { $::argc < 1  } {
    puts "please pass in the name of the folder containing your application"
    exit
}

source fool/fool.tcl

set ::apphome [exec {pwd}]/[lindex $::argv 0]
source ${::apphome}/app.tcl
