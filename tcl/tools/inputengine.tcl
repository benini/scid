###
###    inputengine.tcl
###
###    This file adds input eninge protocol support to scid chess
###    database. It adds menue with subitems to the tools-menue and
###    additionally a button to enable the engine from within the GUI.
###    This module is selfcontained and can just be linked into the Scid
###    database upon built.
###
###    $Id: inputengine.tcl,v 1.4 2008/11/15 16:49:49 arwagner Exp $
###    Last change: <Sat, 2008/11/15 17:44:16 arwagner ingata>
###    Author     : Alexander Wagner
###    Language   : TCL
###
#----------------------------------------------------------------------
# Toolbar icons to display current status to the user

# Engine is connecting (searching the board, initialising)
image create photo tb_eng_connecting -data {
  R0lGODlhFgAWAOfcAAACAAQHAgAKBAARAQESAw0TBwccAQkcAwUfBwQiAwUjBAgnCgwnAwcsCQgt
  Cw4wBxMwDxQxEBNICQtNDQ9QEBNaEg5fDRZcFBNiEAhnFRJsGwxyFxZuHBdvHRxwFhN1GhpxHxV2
  HBl2EhxyIB1zIQ98GBh4Hhx4FRp5Hx55FhN+Ght6IB96FxV/Gw6FFxeAHBuAEyd4HyV5JxGGGRmB
  Hh2BFCB9IyZ6KBuCHx+CFRyDICCDFiN/JRWIGyh8KSp6NR6EISKEGBiJHCWBJx+FIip+KxmKHSeC
  KCGGIyWGGhOQGRuLHiyALSKHJCuDITV6Nh2MHzZ7Ny6BLieIHCSIJSmFKjd8OB+NISONFyWKJhiT
  GyyHLBqUHS2ILTCIJSKQIyaQGS6JLjOGMyqNKR6WHyWSJTGLMCCXICeTJiGYIRqdHCiUJzONMS+R
  LRyeHS2SNSuWKSWaJDaPMy6TNiyXKiabJSCgIDiRNSKhIS+ZLCSiIiajIyyfKTCcNy6gKjaZPEKT
  PymlJj+XOyunJzKkLkaXQyqpMjSlLzyfQUCgOy2rNDanMTioMkicTTapOzqqNEahSkOlRz2sNjut
  Pz6tN1WfUVagUketQD+xQkCyQ1KpTEqwQk2rWU6sWky1Tki4SWOnYE62T2CrXE+3UFa0TlC4UVyw
  YFK7U1i4WFy5U1m6WXCvbmC6YWS4Zm6za2S7XF/AX2LCYW+9c36zgG/AaH23fXq6eG/CcHjCcou4
  hoq/i3zKf4vAjITJf4PLh4nOhJHMkJfHm5POk5XPlJrVmaPRnqTQqp3YnJ/anqbZnqbdp6feqKnf
  qazirbHitMfew8DlwMHrvsDtxtTn09LqztLy1Njw1NPz1dny1eHw4+338v7//P//////////////
  ////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////yH+FUNyZWF0ZWQgd2l0aCBU
  aGUgR0lNUAAh+QQBCgD/ACwAAAAAFgAWAAAI/gD/CRwoEEAAAwoMCCDIkKCACFEgfcp0aRIaDg4W
  NhQYIMqpUp5Q7fp16xKjQB4CbCzQiZUyZ8yQJSPmi1aqTYGEEGAooFMsZNiqRWs2zJWoVq9CMfKz
  Q6VAAU9iOcN2TZozYJa8gHLS6ZIkPXYsaISgatg0atCYDbNFY9q2VUAS+fET5wwDgT9CFSsECJAc
  OVucGNv2VkeeOHXSXPgXABGqWoWeSZ78TBvhVTrQYFEyA8GBSb5mWSJMuvRlJ2OuXFGgYNIwXVsq
  yZ5Nu5IlKWKmQFFwgBIuXU5qC6/kREqVKQoCGPIky8kq09Bp+OBBRAGAK4xYmaryfFs2XuDBpuvS
  BcOKDRYH/nnwUypUJBzdgzkxs+VIDCkrYuCgIJDBnksmJaLDc6s4IUgbY1QRAwnnKfBUBnss5Qcd
  OshhYBtTvLBCByC0IIFGjAERBx9xoNHGHXOMkYQNIYAwQggbIMAQASrEkQYXV1CBRBUokBCCCS14
  4MBGAVSABRhYTKGDCiuwkMMJEqS30T8CLFABDUsY0UMQIUiQQAFTMoQAawokIONGAQEAOw==
}

# Engine is disconnected (default)
image create photo tb_eng_disconnected -data {
  R0lGODlhFgAWAOeWAAEBAQICAggICAkJCQoKCg4ODg8PDxMTExoaGhsbGxwcHB0dHSAgICIiIiMj
  IyoqKisrKywsLC0tLS4uLjk5OTo6Ojs7Ozw9PUhISE1NTU5OTl1dXWJjY2NjY2RkZGVmZmZmZmdn
  Z2doaGlpaWlrbmlsbmptcGttb2xucG9vb29wcG9wcnFxcXBydXFyc3JycnFzc3Nzc3N0dnJ1d3V1
  dnV2dnV2d3Z3eHd3eHh4eXh5e3h6fHp6ent7e3t7fHp8fnx8fHx9fX19fnx+f31+fn1+gH5+fn9/
  f4CAgYGBgYGChIKDhIODg4OEhYOEhoWFhYWGh4WGiPxUVIaHiIeHh4eHiIeIiIiJiYmJiYmKi4qK
  i4yMjIyNjY6Ojo+Pj4+PkI+QkZGRkZKSk5SUlJWVlZaWlpeXl5iYmJiYmZqampubm5ycnJ2dnZ6e
  np+fn6CgoKKioqSkpKampqenp6mpqaqqqqysrK6urq+vr7CwsLGxsbKysrW1tba2tre3t7i4uLm5
  ubu7u7+/v8DAwMHBwcLCwsXFxcfHx8zMzM3Nzc7OztTU1NbW1tfX19jY2Nzc3N/f3+Dg4OLi4ufn
  5+np6ff39///////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////yH+FUNyZWF0ZWQgd2l0aCBU
  aGUgR0lNUAAh+QQBCgD/ACwAAAAAFgAWAAAI/gD/CRwoMMCABA0SECDIkCCBCTHG+JkIZ8sICAsb
  ChTAgg4cRIgmvnnDZo0HARoPtOlTCFEjkHvm3DFjZk0PAwwFsAHEaFGjRocmzplD0wyZFCgFEmDx
  55EUKYeiTvQzx42ZMme0aMgoAY8jSk+hxjxkiapVMmGSNBD4Io8kQYLCTrVU1o0XL1+qZPg3gAyf
  SIKiho0Kia4fM160TImxAAEdRIkC0bUUdjJdxFOgGGnQoM4iQlMnyp065wgVJUAaIJBjSBGe0H5G
  Uz0ypAiPBgLg2BnUJ06l37/DAj9yRAeOBgCowPmT542a35PghoVr2oaIBf9AvNFTx82YOZUsjc1B
  gyUs8SM1Lgh8sIaOHDZktswRbwYJlLAmXITA/o/ABjNupCGGFWYQZQYVVBzxVAkwVJDRPwKk0AUZ
  YFwRBE0JEncCCShwoABDBXTwBBdZNIFEDlT8MEMLK7jAQQQaCYBBD0ws4UQUS+wgAw0fUJCARkox
  gIEKQhDhww0fWKDAg0AKtIADUDrAX0MBAQA7
}

# Engine reported an error
image create photo tb_eng_error -data {
  R0lGODlhFgAWAOf4AAYAAAcAAAkBAA8AABABARYAAyIBASUAAxkFCScBACoAAC0AAC0AAS4BAjIA
  ADMAADgAAjkAAzwBADsHCzwIDF4AAF8AAGEAAmQBAHQAAXYAAHcAAH0AAIIAAIQDAIsAA4sADI0B
  BY0BDY4DBpYAA5gAAJgABJAFAJkCAKAAAZkDBaEAApgDDaIAA6AACYgMC6MCBJIKCZEKEKsAAJsH
  B6wAAaUEAIsPDa0AAaUEBa4AAq4BCrQAAJQOErADA7cAALUABrgAALkAALcAB4YWF50MEK8EC7kA
  CbEGBJYSE8AABKgMB8MAAMIABcQAAMMABrwFAsYBALwFC8UBCKkPEL0IA8cEAM4ABLMMDs8ABKsR
  EYweIbUOB88ADtAAD44fHcgHAKMWGpwaGI8gHpUdILYRCMgICookIrYREMoLAZAiJJcfIckLC4wm
  JJ8eIJIkJqcbHcsOAsERD8kMFJQlIZMlJssODJojJJQmJ8ITEJwkH48qK8wRDaofIM0TDtYOE58o
  J6ApKKcmJc4WF6gnJpUvL5stLK8lI9AYEJYwMM8YGM8YH8gdHJ8wL5ozM9IcGskfI8EjJtMeG7Ur
  LcMlJ6kxLps2OtMeIpg5OtQgIs0kJdUiI5s8PNcjJM8nJ9YkKtglJbwyMtApLp8/P684OdIqKcot
  MdMrKqs8PsUyMK0+P88yL9cwLL08O8M6PdE1N9I2N9o0Nds1O9U5Od02N9A9OMk/QcBHRctCQ8ZF
  Qs5ERahWWN1BQKZaWdhFRKdbWsFQT81LTahcW9tHRslPUtxIR6peXd1JSONHSsFXWLBjYuJOS+FO
  UcFeYdpXV99bW8RnZsVoZ+JdXONfXdxvbr9/feVwcuZxc8d/geZ/gOiAgciOkOSFiM2TlemIhuaN
  jeuLj9WbnO6bmc6pqu6cn/Ceoeyhoe2iou6jo++kpPClpdS2te64uN3AvvS3ufK9vOfQzPHMzPjL
  zvXP0PfR0vjS0+3g4f7//P///////////////////////////////yH+FUNyZWF0ZWQgd2l0aCBU
  aGUgR0lNUAAh+QQBCgD/ACwAAAAAFgAWAAAI/gD/CRwoMEAAAw0MCCDIkOAACnhCffIEaRGaFxEG
  NBwYAA8tWKFaQYOWLFIePx4CbESAi9m3cI529eq1602uUl50FGAYwNYyc/HWCbtH9N4bYLAkgbGh
  UuAAOsfM0Ys3zljRe46ClXrEhgkHjf8m0PI2rx67bnuKwnOka5EXM0+qPBA4JpY6ee/MYSNStF2j
  Woj8TFGihMM/AZR8nXN3zhu0tETboXrl54qSIENqJDgA6po6cd6oJdvSV5WorkKQ8ODRQAErb+ZC
  O7u1pR3RbaQ8sXEipEYN1gcePctmTZquVrWJVqvEqEoVIDBa1Ggw4A+rZ9OOyTIFyPa95YuqwPBY
  QmOFjQYBsHRhxkwWRTiJRo3aMqlM5hUsVKBI8O8Fm1WrsDIII2FgUk01ZwhixBIunMDCDhgIJMEV
  oHwySB5DiOBdNYBokQMJMZCAggICCcBBHFzlgYaGytERRgwveLBCBWD9Q0AOTrDxRBliKGOPPZYk
  4oYIIrBwwgEMFbBCFVIcoYUbZOBhCRk9iHiCBBsFkEEQQhhBRR+BuFFECipcgORG/wTwQAYt6IDF
  EkucgIECC6FJ0AEN5MkAiRsFBAA7
}

# Engine is connected, communication established
image create photo tb_eng_ok -data {
  R0lGODlhFgAWAOe/AAABBAAHCgIIDAMKDQYMDwQOFQoQEgkVHwoWIAsXIA0XIQ4ZIxAbJBEbJQ4d
  KxEgLxQjMRQkMhUkMxYlNB43UB84USI7VCQ9VSdGZCpIZy1LaihNcSxRdS9UeDFVeSxYgS1ZgjRX
  fC5agy9bhDBbhTJchjNdhzReiD9cezVfiTtegzxfhEFefTdhi0ZdeD1ghThijDJkkz5hhjljjTNl
  lDpkjjVmlUBjiDtlj0FkiTxmkDdol0Jlij5nkThpmT9okkRnjDlqmkBpk0VojTprm0FqlDtsnD1t
  nT5unkRtlz9vn0pskkBwoEttkzpyp0FxoUdwmkJyolJuj0hxm0Nzo1NvkEpynk9xl1BymEB3rVZy
  k0F4rlJ0mlN1m092okp5qVV3nVZ4nlJ5pUx7q1t3mEt9p0d9s018rVR7p1l6oFR/pF97nFB/sGB8
  nVx9pFKAsUyCuFh/q11+pVSCs1qBrWCBqGWBommAnWGCqWaCo2KDqliGt2OEq12IrV+Gs1mKtVyK
  vGKJtl+MvnKJpnSMqGmPvGqQvWiSuGuRv3CRuW6VwnKXt3CXxHGbwXKcw3mZwoKZtnqfwIGdwHug
  wYKewYKivoCkxoWlwYunvYaqzJGoxo2typyrvpCvzJWty5qtxpiwzpywyJS00Juy0Ju3zqK1zqW1
  yKO2z6C31py82aO62aS/1qXA16bB2azA2bTAzrLB1a7C27PD1rDE3a/G2LTE177K2MTQ3sbS4MfT
  4czV3cvX5dfg6OXq7f7//P//////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////yH+FUNyZWF0ZWQgd2l0aCBU
  aGUgR0lNUAAh+QQBCgD/ACwAAAAAFgAWAAAI/gD/CRwoEECAAw0OBCDIkKCACSzSCAIEaI8VDxEG
  NBwIwIWhQ4USZfL0KNAYNhwEbDSQp1GqWatUnQqFqQ0JMHGKFGAIoA+jWLty0RKlaVGbNb1yuBkT
  Y6FAASwYtQoaaxSlRnlu9PL1SkaaLxtU/pOAyFVQWqAsJdIj45Wvt3mWeEHyQCCKQ61utfIUKVGf
  JoTevu11YwoVDf8CiHnEqtYlSIfoqJGxVTCvHEuY9FCgANAmV59UpMkjR0YpwVyBcIGSBEmDBoBE
  kSJEaE0VLVJQw1Ih50sQH0QS7qGECciupCtYCX6lQg+aIz10EHEwYA4gQkve2sr9FpYMOmWeswRJ
  EcNGAwBW5nThJHjXW14q6qBBUmRGihQqFPzTMEfNDFuo9cKDGGNQgYQNJ5gQgwUCScAGH22o4NZb
  dmBRBhVE2FBCCAk68FQIZrwhhgqf+FJKRFME0YIJIoQAAwVi/QNAD1+U8YUKplTRBRQ+wLBhCCSE
  kABDBZjAhIEmqFCfCiqUcAIMJESwEQAYIPFEETb0cJ8JM5RAwQEbPdUABtIR4YMNJFigAABhMqTA
  a6/pt1FAADs=
}

image create photo tb_eng_dgt -data {
  R0lGODlhFgAWAKEDAAAAAAAA//8AAP///yH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAh+QQBCgAD
  ACwAAAAAFgAWAAACLZyPqcvtD02YMyJarcR60z5gwQOUJWieXQqgqWuCoEDTcy3ctW53eC4LCoeD
  AgA7
}

image create photo tb_eng_query -data {
  R0lGODlhFgAWAOe+AAEBAQICAggICAkJCQoKCg4ODg8PDxMTExoaGhsbGxwcHB0dHSAgICIiIiMj
  IyoqKisrKywsLC0tLS4uLjk5OTo6Ojs7Ozw9PUhISE1NTU5OTl1dXWJjY2NjY2RkZGVmZmZmZmdn
  Z2doaGlpaWhrbmlrbmlsbmptcGttb2xucG9vb29wcG9wcnFxcXBydXFyc3JycnFzc3FzdXNzc3F0
  dXF0dnN0dnJ1d3V1dnN2d3R2eHV2dnV2d3Z3eHd3eHZ4enh4eXh5e3h6fHp6enl7fHp7e3t7e3t7
  fHp8fnx8fHt9f3x9fX19fnx+f31+fn1+gH5+fn9/f4CAgICAgX+BgoCBg4GBgYGChIKDhIODg4KE
  hYOEhYOEhoSEhIWFhYWGh4WGiIaGhoaHiIeHh4eHiIeIiIiJiYiJiomJiYmKi4qKioqKi4uLi4uL
  jIyMjIyNjY2NjY2Oj46Ojo+PkI+QkI+QkZCQkJGRkZGSkpKSkpKSk5KTk5OTk5OTlJSUlJSUlZWV
  lZWVlpaWlpeXl5iYmJiYmZmZmZqampubm5ycnJ2dnZ6enp+fn6CgoKGhoaKioqOjo6SkpKWlpaam
  pqioqKmpqaqqqqysrK2tra6urq+vr7CwsLGxsbKysrW1tba2tre3t7i4uLm5ubu7u7y8vL29vcDA
  wMHBwcLCwsXFxcbGxsfHx8zMzM3Nzc7OztPT09TU1NbW1tjY2Nzc3N3d3d7e3uDg4OLi4unp6evr
  6+zs7PDw8PPz8/X19f//////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////yH+FUNyZWF0ZWQgd2l0aCBU
  aGUgR0lNUAAh+QQBCgD/ACwAAAAAFgAWAAAI/gD/CRwoMMCABA0SECDIkCCBCTP8UJok6ZGbERAW
  NhQooEWlR4oMLXLUqJGiRB4EbDyw6BMqP5pk9eolK5OfSImMGGAoQJGoWLA8+RpKdNUdRYBUqBRI
  oEWoWbpeASJK9Y4gQms0aJQQkxeuVo0QeZFyiWiePIDuWGkgEMamW7tqpeIkKRGcSETt8Okzh0yG
  fwMAeaplixUpTpUOSck1VFYXQXvWiJmxAEElVrRajeqE6dEYWUN7hfETiI6YL1AaNLAES9apTpco
  IVpE1I8dP3jWYLmSpAGCSalcjcJECdKgVENTsRHUJ46YJk+GNBDw6JKpT5UiOfID2heoOX/swJyp
  8iOIjwYAxjwKtSlSWDtq2Ljp0qZOGixEaPAQseAfiEacWMIIIn5YoYovvRSCRhpaICGDDDtcINAD
  iVQyCVJuuEGULFN8oUQNJ7wQQn//ELDBIIwcokcZbWwYBRU6kGBCDBVo9I8AKsgBSB1mLFEKgog4
  kQMKJaTAgQIMFdCBF2+kscUUQBSBxA0usPACBxFsJAAGRmSBBRdgYCGEDTh8QEECGzHFAAYrMOHE
  ET18YIECNqYp0AIO5OkAiQ0FBAA7
}

#----------------------------------------------------------------------


namespace eval ExtHardware {

  set engine     "dgtdrv2.i686";
  set port       "/dev/ttyUSB0"
  set param      "la"

  # the hardware configured by default:
  #  1 : Novag Citrine
  #  2 : Input Engine
  set hardware   1

  set bindbutton "::novag::connect"
  set showbutton 0

  #----------------------------------------------------------------------
  # Save the hardware options
  #----------------------------------------------------------------------
  proc saveHardwareOptions {} {
     set optionF ""
     if {[catch {open [scidConfigFile ExtHardware] w} optionF]} {
        tk_messageBox -title "Scid: Unable to write file" -type ok -icon warning \
           -message "Unable to write options file: [scidConfigFile InputEngine]\n$optionF"
     } else {
        puts $optionF "# Scid options file"
        puts $optionF "# Version: $::scidVersion, $::scidVersionDate"
        puts $optionF "# This file contains commands in the Tcl language format."
        puts $optionF "# If you edit this file, you must preserve valid Tcl"
        puts $optionF "# format or it will not set your Scid options properly."
        puts $optionF ""

        foreach i { ::ExtHardware::engine     \
                    ::ExtHardware::port       \
                    ::ExtHardware::param      \
                    ::ExtHardware::hardware   \
                    ::ExtHardware::showbutton \
                    ::ExtHardware::bindbutton } {
           puts $optionF "set $i [list [set $i]]"
        }

     }
     close $optionF
     set ::statusBar "External hardware options were saved to: [scidConfigFile correspondence]"

     # Check if the hw connect button exists already. If not, add it.
     if { [winfo exists .button.exthardware]} { 
        return 
     } else {
        if { $::ExtHardware::showbutton == 1 } {

           frame .button.space4 -width 15
           button .button.exthardware -image tb_eng_disconnected
           .button.exthardware configure -relief flat -border 1 -highlightthickness 0 \
               -anchor n -takefocus 0
           bind .button.exthardware <Any-Enter> "+.button.exthardware configure -relief groove"
           bind .button.exthardware <Any-Leave> "+.button.exthardware configure -relief flat; statusBarRestore %W; break"
           pack .button.space4 .button.exthardware -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0

          .button.exthardware configure -command $::ExtHardware::bindbutton
        }
     }

  }

  #----------------------------------------------------------------------
  # Set the hardware connect button image
  #----------------------------------------------------------------------
  proc HWbuttonImg {img} {

    if { $::ExtHardware::showbutton == 1 } {
      .button.exthardware configure -image $img -relief flat
    }
  }

  #----------------------------------------------------------------------
  # Set the hardware connect button command binding
  #----------------------------------------------------------------------
  proc HWbuttonBind {cmd} {

    if { $::ExtHardware::showbutton == 1 } {
       set ::ExtHardware::bindbutton $cmd
    }
  }

  #----------------------------------------------------------------------
  # config:
  #    Opens the configuration dialog to input driver engines binary
  #    and parameters required to fire up the engine
  #----------------------------------------------------------------------
  proc config {} {
    global ::ExtHardware::port ::ExtHardware::engine ::ExtHardware::param ::ExtHardware::hardware

    ###  .button.exthardware configure -image tb_eng_query -relief flat
    ::ExtHardware::HWbuttonImg tb_eng_query

    set w .exthardwareConfig
    if { [winfo exists $w]} { return }
    toplevel $w
    wm title $w [::tr ExtHWConfigConnection]

    label $w.lport -text  [::tr ExtHWPort]
    entry $w.eport -width 50 -textvariable ::ExtHardware::port

    label $w.lengine -text [::tr ExtHWEngineCmd]
    entry $w.eengine -width 50 -textvariable ::ExtHardware::engine

    label $w.lparam -text  [::tr ExtHWEngineParam]
    entry $w.eparam -width 50 -textvariable ::ExtHardware::param

    label $w.options -text [::tr ExtHWHardware]
    
    checkbutton $w.showbutton -text [::tr ExtHWShowButton] -variable ::ExtHardware::showbutton

    #--------------
    # Add a new radio button for subsequent new hardware here:
    radiobutton $w.novag    -text [::tr ExtHWNovag]  -variable ::ExtHardware::hardware -value 1 -command { \
       set ::ExtHardware::bindbutton "::novag::connect"
       .exthardwareConfig.eengine configure -state disabled
       .exthardwareConfig.eparam  configure -state disabled
    }
    radiobutton $w.inputeng -text [::tr ExtHWInputEngine]   -variable ::ExtHardware::hardware -value 2 -command { \
       set ::ExtHardware::bindbutton "::inputengine::connectdisconnect"
       .exthardwareConfig.eengine configure -state normal
       .exthardwareConfig.eparam  configure -state normal
    }
    #--------------

    if { $::ExtHardware::hardware == 1 } {
       .exthardwareConfig.eengine configure -state disabled
       .exthardwareConfig.eparam  configure -state disabled
    }

    button $w.bOk -text OK -command { ::ExtHardware::saveHardwareOptions
       ::ExtHardware::HWbuttonBind $::ExtHardware::bindbutton
       destroy .exthardwareConfig
       $::ExtHardware::bindbutton
    }
    button $w.bCancel -text [::tr Cancel] -command "::ExtHardware::HWbuttonImg tb_eng_disconnected ; destroy $w"


    grid $w.options    -stick ew    -row 0 -column 0
    grid $w.novag      -stick w     -row 0 -column 1
    grid $w.inputeng   -stick w     -row 1 -column 1

    grid $w.lport      -stick ew    -row 2 -column 0 
    grid $w.eport                   -row 2 -column 1

    grid $w.lengine    -stick ew    -row 3 -column 0
    grid $w.eengine                 -row 3 -column 1

    grid $w.lparam     -stick ew    -row 4 -column 0 
    grid $w.eparam                  -row 4 -column 1

    grid $w.showbutton -stick w     -row 5 -column 1

    grid $w.bOk        -stick e     -row 6 -column 0 
    grid $w.bCancel    -stick w     -row 6 -column 1

    bind $w <F1> { helpWindow HardwareConfig}

  }

}
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # source the options file to overwrite the above setup

  set scidConfigFiles(ExtHardware) "hardware.dat"
  if {[catch {source [scidConfigFile ExtHardware]} ]} {
    #::splash::add "Unable to find the options file: [file tail $optionsFile]"
  } else {

     # Add the button to connect the engine to the button bar
     if { $::ExtHardware::showbutton == 1 } {

        frame .button.space4 -width 15
        button .button.exthardware -image tb_eng_disconnected
        .button.exthardware configure -relief flat -border 1 -highlightthickness 0 \
            -anchor n -takefocus 0
        bind .button.exthardware <Any-Enter> "+.button.exthardware configure -relief groove"
        bind .button.exthardware <Any-Leave> "+.button.exthardware configure -relief flat; statusBarRestore %W; break"
        pack .button.space4 .button.exthardware -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0

       .button.exthardware configure -command $::ExtHardware::bindbutton
     }

    ::splash::add "External hardware configuration was found and loaded."
  }



#======================================================================

namespace eval inputengine {

  set engine     "dgtdrv2.i686";
  set port       "/dev/ttyUSB0"
  set param      "la"

  set InputEngine(pipe)     ""
  set InputEngine(log)      ""
  set InputEngine(logCount) 0
  set InputEngine(init)     0
  set connectimg            tb_eng_ok
  set MovingPieceImg        $::board::letterToPiece(.)80
  set MoveText              "     "

  set NoClockTime           "--:--"

  set WhiteClock            $::inputengine::NoClockTime
  set BlackClock            $::inputengine::NoClockTime
  set toMove                "White"

  font create moveFont -family Helvetica -size 56 -weight bold

  #----------------------------------------------------------------------
  # Generate the console window also used for status display
  #----------------------------------------------------------------------
  proc consoleWindow {} {

    set w .inputengineconsole
    if { [winfo exists $w]} { 
       ::inputengine::disconnect
       return
    }
    toplevel $w

    wm title $w [::tr IEConsole]

    scrollbar $w.ysc     -command { .inputengineconsole.console yview }
    text      $w.console -height 5  -width 80 -wrap word -yscrollcommand "$w.ysc set"

    label     $w.lmode   -text [::tr IESending]

    ::board::new $w.bd 25
     $w.bd configure -relief solid -borderwidth 1

    label     $w.engine      -text "$::ExtHardware::engine $::ExtHardware::port $::ExtHardware::param"

    radiobutton $w.sendboth  -text [::tr Both]  -variable send -value 1 -command { ::inputengine::sendToEngine sendboth  }
    radiobutton $w.sendwhite -text [::tr White] -variable send -value 2 -command { ::inputengine::sendToEngine sendwhite }
    radiobutton $w.sendblack -text [::tr Black] -variable send -value 3 -command { ::inputengine::sendToEngine sendblack }

    button $w.bInfo          -text Info           -command { ::inputengine::sysinfo }

    ###---### rotate does not work yet
    button $w.bRotate        -text [::tr IERotate]       -command { ::inputengine::rotateboard }

    button $w.bSync          -text [::tr IESynchronise]  -command { ::inputengine::synchronise }
    button $w.bClose         -text [::tr Close]   -command { ::inputengine::connectdisconnect }

    # Buttons for visual move announcement
    button $w.bPiece -image $inputengine::MovingPieceImg
    button $w.bMove  -font moveFont -text  $inputengine::MoveText
    $w.bPiece configure -relief flat -border 0 -highlightthickness 0 -takefocus 0
    $w.bMove  configure -relief flat -border 0 -highlightthickness 0 -takefocus 0

    # Buttons for clock display
    button $w.wClock -text  $inputengine::WhiteClock
    button $w.bClock -text  $inputengine::BlackClock
    $w.wClock configure -relief flat -border 0 -highlightthickness 0 -takefocus 0
    $w.bClock configure -relief flat -border 0 -highlightthickness 0 -takefocus 0

    grid $w.console   -stick ns    -column 0  -row 0 -columnspan 12
    grid $w.ysc       -stick ns    -column 12 -row 0

    grid $w.engine    -stick ewns   -column 0  -row 1 -columnspan 9

    grid $w.lmode     -stick ew    -column 0  -row 2
    grid $w.sendboth  -stick e     -column 2  -row 2 
    grid $w.sendwhite              -column 4  -row 2 
    grid $w.sendblack -stick w     -column 6  -row 2 

    grid $w.bInfo     -stick ew    -column 0  -row 3
    ###---### grid $w.bRotate   -stick ew    -column 0  -row 4
    grid $w.bSync     -stick ew    -column 0  -row 5
    grid $w.bClose    -stick ew    -column 0  -row 6

    grid $w.bPiece    -stick nwes  -column 2  -row 3 -rowspan 9 -columnspan 3
    grid $w.bMove     -stick nwes  -column 5  -row 3 -rowspan 9 -columnspan 3

    grid $w.wClock    -stick nwes  -column 9 -row 12 -columnspan 7
    grid $w.bClock    -stick nwes  -column 9 -row 1  -columnspan 7

    grid $w.bd        -stick nw    -column 9  -row 2 -rowspan 9 -columnspan 7

    bind $w <Destroy> { catch ::novag::disconnect }
    bind $w <F1> { helpWindow InputEngine}
  }

  proc updateConsole {line} {
    set t .inputengineconsole.console
    $t insert end "$line\n"
    $t yview moveto 1
  }

  ### #----------------------------------------------------------------------
  ### # userSend:
  ### #    Send arbitrary stings to the input engine
  ### #----------------------------------------------------------------------
  ### proc userSend {} {

  ###   set w .inputengineSend
  ###   set toSend "bla"
  ###   if { [winfo exists $w]} { return }
  ###   toplevel $w
  ###   wm title $w "Send command to Engine"
  ###   frame $w.f1
  ###   frame $w.f2
  ###   pack $w.f1 $w.f2

  ###   label $w.f1.lengine -text "Command:"
  ###   entry $w.f1.eengine -width 125 -textvariable toSend
  ###   pack $w.f1.lengine $w.f1.eengine

  ###   button $w.f2.bOk -text OK -command "destroy $w ; ::inputengine::sendToEngine display ; ::inputengine::sendToEngine getposition"
  ###   button $w.f2.bCancel -text Cancel -command "destroy $w"
  ###   pack $w.f2.bOk $w.f2.bCancel -side left
  ### }

  #----------------------------------------------------------------------
  # connectdisconnect()
  #   Connects or disconnects depending on the current status of the
  #   external input engine
  #----------------------------------------------------------------------
  proc connectdisconnect {} {
    global  ::inputengine::InputEngine

    set connection $::inputengine::InputEngine(pipe)

    if {$connection == ""} {
      consoleWindow
      ::inputengine::connect
    } else {
      ::inputengine::disconnect
    }
  }

  #----------------------------------------------------------------------
  # connect():
  #     Fire upt the input engine and connect it to a local pipe.
  #     Also register the eventhandler
  #----------------------------------------------------------------------
  proc connect {} {
    global ::inputengine::InputEngine ::inputengine::engine \
        ::inputengine::port ::inputengine::param

    ::ExtHardware::HWbuttonImg tb_eng_connecting

    if {[catch {set InputEngine(pipe) [open "| $engine $port $param" "r+"]} result]} {
      ::ExtHardware::HWbuttonImg tb_eng_error
      tk_messageBox -title "Scid: Input Engine" -icon warning -type ok \
          -message "[::tr IEUnableToStart]\n$engine $port $param"
      ::inputengine::resetEngine
      return
    }

    ::inputengine::Init
  }

  #----------------------------------------------------------------------
  # disconnect()
  #    Disconnect and close the input engine
  #----------------------------------------------------------------------
  proc disconnect {} {
    global ::inputengine::InputEngine
    set pipe $::inputengine::InputEngine(pipe)

    set ::inputengine::connectimg tb_eng_connecting 

    ::inputengine::sendToEngine "stop"
    ::inputengine::sendToEngine "quit"
    set ::inputengine::connectimg tb_eng_disconnected
    ## ::utils::tooltip::Set .button.exthardware [::tr ExtHWNoBoard]

    if { [winfo exists ::inputengine::.inputengineconsole]} { 
       destroy ::inputengine::.inputengineconsole
    }
  }

  #----------------------------------------------------------------------
  # logEngine
  #    Simple log routine, ie. writing to stdout
  #----------------------------------------------------------------------
  proc logEngine {msg} {
      updateConsole "$msg"
  }

  #----------------------------------------------------------------------
  # sendToEngine()
  #    Send a string to the engine and log it by means of logEngine
  #----------------------------------------------------------------------
  proc sendToEngine {msg} {
    global ::inputengine::InputEngine
    set pipe $::inputengine::InputEngine(pipe)

    ::inputengine::logEngine "> $msg"
    puts $pipe $msg
    flush $pipe
  }

  #----------------------------------------------------------------------
  # init()
  #    Initialises the engine and internal data
  #----------------------------------------------------------------------
  proc Init {} {
    global ::inputengine::InputEngine
    set pipe $::inputengine::InputEngine(pipe)

    # Configure the pipe and intitiate the engine
    set pipe $::inputengine::InputEngine(pipe)
    fconfigure $pipe -buffering full -blocking 0
    # register the eventhandler
    fileevent  $pipe readable "::inputengine::readFromEngine"

    ::inputengine::newgame
  }

  #----------------------------------------------------------------------
  # resetEngine()
  #    Resets the engines global variables
  #----------------------------------------------------------------------
  proc resetEngine {} {
    global ::inputengine::InputEngine

    ::ExtHardware::HWbuttonImg tb_eng_disconnected
    ##::utils::tooltip::Set .button.exthardware [::tr ExtHWNoBoard]
    destroy .inputengineconsole
    set ::inputengine::InputEngine(pipe)     ""
    set ::inputengine::InputEngine(log)      ""
    set ::inputengine::InputEngine(logCount) 0
    set ::inputengine::InputEngine(init)     0
  }


  #----------------------------------------------------------------------
  # sysinfo()
  #    Initialises the engine and internal data
  #----------------------------------------------------------------------
  proc sysinfo {} {
    global ::inputengine::InputEngine
    set pipe $::inputengine::InputEngine(pipe)

    # call system information
    ::inputengine::sendToEngine "sysinfo"
  }

  #----------------------------------------------------------------------
  # rotateboard()
  #    Rotates the board, ie. exchanges a1 and h8
  #----------------------------------------------------------------------
  proc rotateboard {} {
    global ::inputengine::InputEngine
    set pipe $::inputengine::InputEngine(pipe)

    # rotate the graphical boards
    ::board::flip .board
    ::board::flip .inputengineconsole.bd

    ::inputengine::newgame
    # rotate the board for the input engine
    ::inputengine::sendToEngine "rotateboard"
    ::inputengine::synchronise
  }

  #----------------------------------------------------------------------
  # newgame()
  #    Handle NewGame event from board
  #----------------------------------------------------------------------
  proc newgame {} {

    # Ask the user to save the current game
    ::game::Clear
    sc_game tags set -event "InputEngine Input"
    sc_game tags set -date [::utils::date::today]
  }

  #----------------------------------------------------------------------
  # endgame()
  #    Handle game ending (end game event + result)
  #----------------------------------------------------------------------
  proc endgame {result} {

    set filternum [sc_filter first]

    logEngine "  info End Game $filternum: $result"

    sc_game tags set -result $result
    gameAdd
  }

  #----------------------------------------------------------------------
  # synchronise()
  #    read board position and set scid's representation accordingly
  #----------------------------------------------------------------------
  proc synchronise {} {
    global ::inputengine::InputEngine

    logEngine "  info Sync called"
    set InputEngine(init) 0

    ::inputengine::sendToEngine "getposition"
  }

  #----------------------------------------------------------------------
  # readFromEngine()
  #     Event Handler for commands and moves sent from the input
  #     engine, implements input engine protocol
  #----------------------------------------------------------------------
  proc readFromEngine {} {
    global ::inputengine::InputEngine ::inputengine::connectimg
    set pipe $::inputengine::InputEngine(pipe)

    set line [string trim [gets $pipe] ]

    # Close the pipe in case the engine was stoped
    if [eof $pipe] {
      catch {close $pipe}
      ::inputengine::resetEngine
      return
    }

    switch -regexp -- $line \
        "^move *" {
          set m [string range $line 5 end]

          set s1 [string range $m 0 1]
          set s2 [string range $m 2 end]
          set m "$s1-$s2"

          logEngine "$line"

          if {[catch {sc_move addSan $m}]} {
             ::utils::sound::PlaySound "sound_alert"
             logEngine "< info Illegal move detected!"
             logEngine "< info Ignoring: $m"
             .inputengineconsole.bPiece configure -background red
             .inputengineconsole.bMove  configure -background red -text $m
          } else {

            .inputengineconsole.bPiece configure -background green
            .inputengineconsole.bMove  configure -background green -text $m

             updateBoard -animate
             updateBoard -pgn
          }
        } \
        "info *" {
          logEngine "< $line"
          set event [string range $line 5 end]
          switch -regexp -- $event \
          "string ERROR *" {
            set err [string range $event 7 end]
            tk_messageBox -title "Scid: Input Engine" \
            -icon warning -type ok -message "Engine $err"
            catch {close $pipe}
            ::ExtHardware::HWbuttonImg tb_eng_error
            return
          } \
          "string Chessboard found and initialised*" {
            # switch to xboard mode and disable move
            # announcments by the driver engine
            ::inputengine::sendToEngine "xboard"
            ::inputengine::sendToEngine "announce"
          } \
          "Engine mode    : xboard*" {
            ::inputengine::sendToEngine "getposition"
            ::ExtHardware::HWbuttonImg $inputengine::connectimg
          } \
          "string FEN *" {
            set InputEngine(init) 0
            # The first FEN string is always sent as
            # info string FEN ...
            # as this is compatible with both UCI and xboard.
            # At this stage the engine is not set to xboard mode
            # yet, so this signals a new program startup
            # accordingly.
          } \
          "FEN *" {
            set fenstr [string range $event 4 end]
            set fenstr [string trim $fenstr]
            if { $::inputengine::InputEngine(init) == 0 }  {
              # Initialise scids representation with the FEN
              # delivered by the external board.
              catch {sc_game startBoard $fenstr}
              updateBoard -pgn
              set InputEngine(init) 1
            } else {
              # Compare the internal representation to the
              # board each time a FEN string arrives from the
              # driver.
              #
              # Do not check the whole FEN, as the external
              # board can not know anything about e.p. or O-O
              # capabilities. Strip them off and compare just
              # the piece settings.
              set space [string first " " $fenstr]
              set fen [string range $fenstr 0 $space]

              set space [string first " " [sc_pos fen]]
              set int [string range [sc_pos fen] 0 $space]

              if {$fen != $int} {
                ::utils::sound::PlaySound "sound_alert"
                logEngine "  info Wrong Position! $int (scid) != $fen (external)"
              } else {
                logEngine "  info Board and internal position match."
              }
            }
          } \
          {moving piece: [A-Z] *} {
            .inputengineconsole.bPiece configure -image $::board::letterToPiece([string range $event 14 end])80
          }\
          {moving piece: [a-z] *} {
            .inputengineconsole.bPiece configure -image $::board::letterToPiece([string range $event 14 end])80
          }\
          "move *" {
            ::inputengine::sendToEngine "getposition"
          }\
          "!new game!" {
            ::inputengine::newgame
            .inputengineconsole.bPiece configure -background blue
            .inputengineconsole.bMove  configure -background blue -text "OK"
            .inputengineconsole.bPiece configure -image $::board::letterToPiece(K)80
          } \
          "!move now!" {
            logEngine "< info $event"
          } \
          "!end game 1-0!" {
            logEngine "< info $event"
            ::inputengine::endgame "1-0"
            .inputengineconsole.bPiece configure -background white
            .inputengineconsole.bMove  configure -background white -text "1-0"
            .inputengineconsole.bPiece configure -image $::board::letterToPiece(K)80
          } \
          "!end game 0-1!" {
            logEngine "< info $event"
            ::inputengine::endgame "0-1"
            .inputengineconsole.bPiece configure -background gray
            .inputengineconsole.bMove  configure -background gray -text "0-1"
            .inputengineconsole.bPiece configure -image $::board::letterToPiece(k)80
          } \
          "!end game 1/2-1/2!" {
            logEngine "< info $event"
            ::inputengine::endgame "1/2-1/2"
            .inputengineconsole.bPiece configure -background black
            .inputengineconsole.bMove  configure -background white -text "1/2-1/2"
            .inputengineconsole.bPiece configure -image $::board::letterToPiece(.)80
          } \
          "!enter setup mode!" {
            .inputengineconsole.bPiece configure -background yellow
            .inputengineconsole.bMove  configure -background yellow -text "Setup"
            .inputengineconsole.bPiece configure -image $::board::letterToPiece(K)80
            logEngine "< info $event"
          } \
          "!end setup mode!" {
            logEngine "< info $event"
            ::inputengine::synchronise
            .inputengineconsole.bPiece configure -background yellow
            .inputengineconsole.bMove  configure -background yellow -text "OK"
            .inputengineconsole.bPiece configure -image $::board::letterToPiece(q)80
          } \
          "!white to move!" {
            logEngine "< info $event"
            ::inputengine::toMove "White"
          } \
          "!black to move!" {
            logEngine "< info $event"
            ::inputengine::toMove "Black"
          } \
          "No Clock detected" {
             set ::inputengine::WhiteClock $::inputengine::NoClockTime
             set ::inputengine::BlackClock $::inputengine::NoClockTime
             .inputengineconsole.wClock configure -text $::inputengine::WhiteClock
             .inputengineconsole.bClock configure -text $::inputengine::BlackClock
          } \
          "Time White:" {
            # Get the time in seconds
            regsub -all {[A-Za-z:# ]} $event "" ::inputengine::WhiteClock

            # calculate a sensible format
            set wHrs [expr $::inputengine::WhiteClock / 60 / 60]
            set wMin [expr ($::inputengine::WhiteClock - $wHrs*60*60) / 60 ]
            set wSec [expr ($::inputengine::WhiteClock - $wHrs*60*60 - $wMin * 60) ]

            if {$wHrs > 0} {
               .inputengineconsole.wClock configure -text "$wHrs:$wMin:$wSec (EXT)"
            } else {
               .inputengineconsole.wClock configure -text "$wMin:$wSec (EXT)"
            }

            ##--## ::gameclock::setSec 1 [expr -1*$::inputengine::WhiteClock]
            ##--## set ::sergame::wtime $::inputengine::WhiteClock
          } \
          "Time Black:" {
            regsub -all {[A-Za-z:# ]} $event "" ::inputengine::BlackClock

            set bHrs [expr $::inputengine::BlackClock / 60 / 60]
            set bMin [expr ($::inputengine::BlackClock - $bHrs*60*60) / 60 ]
            set bSec [expr ($::inputengine::BlackClock - $bHrs*60*60 - $bMin * 60) ]

            if {$bHrs > 0} {
               .inputengineconsole.bClock configure -text "$bHrs:$bMin:$bSec (EXT)"
            } else {
               .inputengineconsole.bClock configure -text "$bMin:$bSec (EXT)"
            }

            ##--## ::gameclock::setSec 2 [expr -1*$::inputengine::BlackClock]
            ##--## set ::sergame::btime $::inputengine::BlackClock
          } \
          "Wrong move performed:" {
            ::utils::sound::PlaySound "sound_alert"
            logEngine "< info $event"
          } \
          "DGT Projects - This DGT board" {
            set ::inputengine::connectimg tb_eng_dgt
            set txt [string range $event 7 end]
            ## ::utils::tooltip::Set .button.exthardware "$::inputengine::port:\n$txt"
          } \
        } \
        default  {
          logEngine "< $line"
        }
        # Should better show current wooden board position? Return value of 
        # sc_pos board is
        # RNBQKBNRPPPP.PPP............P................n..pppppppprnbqkb.r w
        ::board::update .inputengineconsole.bd [sc_pos board]
  }



}


###
### End of file: inputengine.tcl
###
