# Run all test files in this directory.
# Usage: tclsh all.tcl ?options?

package require tcltest 2.5
namespace import ::tcltest::*

configure -testdir [file normalize [file dirname [info script]]] {*}$argv

exit [expr {[runAllTests] ? 1 : 0}]
