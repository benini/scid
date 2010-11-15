###
###    inputengine.tcl
###
###    This file adds input eninge protocol support to scid chess
###    database. It adds menue with subitems to the tools-menue and
###    additionally a button to enable the engine from within the GUI.
###    This module is selfcontained and can just be linked into the Scid
###    database upon built.
###
###    $Id: inputengine.tcl,v 1.14 2010/11/15 12:02:53 arwagner Exp $
###    Last change: <Mon, 2010/11/15 13:00:39 arwagner agamemnon>
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

if {$png_image_support} {
	image create photo tb_eng_connecting -data {
		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
	}

	# Engine is disconnected (default)
	image create photo tb_eng_disconnected -data {
		iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
		WXMAAAsPAAALDwGS+QOlAAAAB3RJTUUH0gsHDCIDToTw0gAABNpJREFUeJx9lU+IE1ccx79vXibz
		MklwsokY7MpGE3RRpOgihFasl8C2HkrRhfawB1kPikeP0t4KlkXwIN72UgMtLLT2UGsptGK3MFYT
		ui3ubkU3qZKIu83f2WT+vTfTQ8y4W7b9Xebxe/w+v7/zewT/IZIkjQA4BWBKUZTDIyMjVFEUYts2
		b7VaS5ZlfUEI+VoI0dvOnmyjC6uqejmXy50rFAo79u7dG85ms/Lwcn193V9bWxNPnz617t2716lU
		KnP9fv9TAM7/gXczxuYvXLjwZj6fj9i2TQ4ePEheAQEAL1++BAAIIeD7vqfrulUsFn+zLGsKQH07
		8O5kMrkwOzv7RjqdlmOxGFFVFdFoFL3eINt6vY5erwdFUQIHsiz7lUqFX79+vdbpdI4DqAEAHabP
		GPv22rVr46Ojo+GxsTHCGIOiKACAfr+PZrMJSiksy4IQApZlAQA8zyOxWIzu2bMnuri4+DbnvAhA
		UABQVfWT8+fPf3DkyJFILpdD9vJlpO7exerRowFg+GWMBWfOOXzfB6UUisKoLMvJ58+fh1zXvStR
		SqPZbHbmxIkTkUwmg3g8HtTm2NWrw4ah3W5D0zRMTk5C0zQwxsAYAyEEQggoShgTExMsnU6fo5TG
		JM/z3i8UCjsIIZKqqlhaWsLPFy9ugcuyDE3T0G63ASCADzNxHAee5yMcVqRDhw7tiEQiZyTG2IfZ
		bJbJsgzP84J0H1y6FMALc3PQNA2apqFarQbwdDoNxhgAwHVd+AD279+vJBKJj6REInE4lUrRXbt2
		odFogHOOfD6PfD4POj+/JfJ8Po9MJhPoJicngzMfjB+i0WhIluUDIcYYJYQQxlgAvnPnzushnJlB
		YW5uMLtTU/hhZgabRdM0rKysgDEGl4th1lSyLItwztHpdBCPx4OOb5bNsKGTf0vPtMA5D8oZajab
		nHPuv3jxgqRSKSiKgkajgdOnT28xdE+ehDw9HcDdmzeDuytXroASwHZc+AOwkGzb/qNWq4l+vx90
		mHOOYrEYGLbbbei6vmVa5Olp6LoOXdcBDBouBEe70+au6/5JCSFk3759742OjoZlWYbjOHAcB6Zp
		4tmzZxgfH4emadB1HbVaHT8lk3irPlgJYw8e4PN+f9A8zuFyF+Vy2axWKrOSJEnfLCwstDnnnmW9
		rhMhBLVaDbdu3Qqi9H0Ppmnhs6MTge7jR4+w3uyga2yg2+n4f1WrHdM056nv+26v10uoqnoslUrJ
		hJCBd5fDsm0AwJMnT4Kfg3MXhAA/jozgnVcb73YshlCIolwqWZVK5YbjON9TAHBd95fHjx+/m8lk
		0oqiUEIIuBAQQqDRaCAsy0Gth1kBwFehMG5H46BUwobR5eVy+fdut3vW8zwx3G6Cc/7d8vLymZ07
		d8YikQiVqATfBwghMAwDjUYDjCkwbRd9y4ZlOZAIIMsUG0aX/3r/fr3b7Z4yDKMBvF6bAGDYtj2/
		vLx8XJKkZCKRCBEC4gOQaAiMRcCFgOO68IRASCIwNrp+uVQyy6XSomEYp9bW1qpD2GYwABic85v1
		ej28urqaM02TqlFVClEqceGCuy6E4Oh0WrxcLpkPHz78u1qt3jAM4+ww0qFs9+YNPFIajUQiU4lE
		4qNwOHxgUxCe4zgrrVbrS9M054UQG9vZ/wPVtIPfqdKpLwAAAABJRU5ErkJggg==
	}

	# Engine reported an error
	image create photo tb_eng_error -data {
		iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
		WXMAAAsRAAALEQF/ZF+RAAAAB3RJTUUH0gkCEjYIrF7TJwAABRBJREFUeJxllV+InNUZxn/v933z
		f4bZxNAdk7hJ3aFa0SRWEISFbJFIghBFKjF3DQrtVZHehl62WsE2Qu1dW1uFpl1IGilU8KIpRqgx
		F0mbYAsWdy/MzmZmZ2d25vt3vnPO24sJaWMeOJxz8fDwvD8O58ix958hsymZyzDecO3ENRwQQsPB
		88CJGjx2P4Q1kBRsD64n8IcQzi++uxgrCoDqbBcEOXrhGTKXcvGFj2gBEyi34PSBWu3lkwsL7W/W
		65X7vY/yNMWrCnmuvTh219M0O5+m4xuqv5rAj7u/229u56MocvTCET547kPqQAK767Dy04cfPnh0
		585a7JxMrJW8ViPqdglqNVyvB599RnU4pJym/i9xnP3E+6sJvLj42303uS0B6JTL9IzZ3SmXL72/
		tLRnvtUqRYcPy7jZ5K9vv819jz46K6MK3rP56ad868EHqa+v49bWdG06td9T/bIPS4vv7PsSIKoD
		PWPKdVi58NRTe+abzXLz+HGCQ4fY6vXY+cgjnHjvPf5fZ7pdpNEgaDSQdlv25nnpLWP2vAJ//M93
		1769+M4+E7ze7dKC0693uwc7jUa5efw49SefBMBOJki5zFfVaLcpWwtxjDqHlMsshGHpB3CoBadR
		CH74+eeNA9Xqy8/u2FGrPf009SeeQLzHDQa4wYD1K1fuCu1dvUoEBGkK0yk+SXDeI0HAEZHqN+CV
		tVNrzcDBcy91Om0HQTQ/D9Zi+31cr4e9dYt0MLgrOBuNEO+RLJuFZjmuKChUESQ4Cu0GfCeqw0sH
		yuVq0GqBc9jBADsYYG7epOj3iVqte1A0Wy00SfDG4KzFqZKL4EU4gFQ6qiejDjz2NZGw+vjjSKmE
		7fUoNjYo1texW1uza/MVBUGANwa1FqeeQsEAXqCpRGV4KKhD6EGCVgsXx5iNDUyvR9Hvo6MRYi2r
		Fy/exZiimLVVxQKFgBHBILiZLYwSEE1TzOoqIoIfj7H9Pn44JIhjQu/vYeySBJdlWOcoEHIgk9ls
		EQIo0TpYkkTjTz4RvEeAYnMTHY+p5Dk76/V7UNRUMXGMdZ5chAxIEQKgNLO4KIV/fpFlex8YDKJi
		YwOJItzWFm57G4whtJYPXn2V6twcAKPVVfZXKmS5oVAlBVIJMCJUVBmi1sC/A+DsjSzL1RjceIwd
		DrFbWxTjMdlohLeWoFZj//Iy+5eXcZUKBmZNRUhEiEVQoOotV1TzHpyNQrjwJ2vfOJJlteLWrUBK
		JYrJBJMkJM6x6RzPv/Ya+5eX76BY+/1ZpBSR5QFTr2QiNNQTq+rfYRzDSvAjkfgG/ObPxmTZ+jpm
		OMTmOdZaHGCdu4dxDmRRmWkYMQlCPELVOT5Szdbg1w/8YmEaXgZi+PgyHFtyrtM0JlTvKbxiEVyz
		wXaa0jl4kGw04tKbbyLWk25vkxiDeKWintRbex7+sQmnWsfaTgB2AQPYvQsuvQF7vx4EJR+EmDBk
		0mwwmZtjYi1BpUp1xw6K/gAdDJA8o14UjNXbc6o3v4DD4VsLqwChVIXEQh0mY1j5EJbaqvctqEaB
		9+I8hM7SqtaoBSE63iYYj2ikMdYW+jfv03NwbQDPhmdmoQAhFqQqFBZaMInh3etQvgrdQDWc8y5o
		FEUQJgnhdEIYT5imqf3Y2vSc6uAy/HIIp9o/X9gEQGfrzlMgVWH++7sYnOnTmHFvNODFDpysiDwE
		hLet3sC/1lXPxrCy92cL0//9ddw5/BdemMfxn02t7QAAAABJRU5ErkJggg==
	}

	# Engine is connected, communication established
	image create photo tb_eng_ok -data {
		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
	}

	image create photo tb_eng_query -data {
		iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
		WXMAAAsRAAALEQF/ZF+RAAAAB3RJTUUH0gkCEjU51q2A3gAABShJREFUeJxtld9rFOsZxz/vzM7u
		7Kw/ssliEjdBY6JplMPpZUIPnEMhSjlIbxrw3Hng3ORvEHpXKHjjhfSi0OOFgQqCpYIgvRCUVDwh
		CVVRqxizRRJLOLuT2dnsvDPz/ujFbtJj6wMvz1w8fJ7vPN+H9xX0owBowO1n4TiDwNfAQqlU+mxw
		cNAtlUoiTVMVhuFLKeWfhRB/0Vrv8YkQAIeB+L+5GATBlampqe/m5+ePTkxMFGu1WsEYg7VWaK3t
		zs6O3tjYkI8ePYo2Nzf/1O12fwdkH4EDoAv083Hf928vLi5+Pjs7W07TVOR5LpRSeJ6H67pYawHQ
		WmOtNU+ePJFLS0v/kFIuANsfKR4pFvl3lh0fGhpavnr1an1kZMQ7dOiQePbsGfV6nZmZGcbHxwF4
		//49L1++ZHt7m4GBAaSUdnNzU12/fn0riqIvgC0ANwBCrYu+79+7du3az8bGxoonTpwQvu8jhODi
		xYvUajU8z8PzPGq1GjMzMxhjePv2LaVSSZTLZXd8fLzy9OnTXyillgDt/H5qiiAIriwuLn5er9eL
		k5OTHDt2DGstjUbjU74AMDs7C0CapriuS70+5p0/f/7nQRBcAXD/FkWV6enp7y9fvlw9ffq0GB0d
		JcsywjAkDENWV1e5f/8+Dx48oNlscvbs2QP4ysoKxhgAHEcwODjobmxsnGm32390jDG/np+fPyqE
		cIIgQGvN3t4eUkqq1SpBEDA8PMzhw4eRUn6k2hiDEAJjLMZYisWSc+7cuaPlcvk3ju/7lyYnJ33P
		81BKsbu7S6vVIkmS3n4XChhjiOOYCxcuHEBfv35Np9PpbQqWPM+xwJkzZ0rVavWbQrVa/axWq7nD
		w8NYa2k2m4RhSJIkKKVI05Rms8mlS5eo1WoAdLtd7ty5w8DAANb2Vk/11o9KpVLwPG+64Pu+K4QQ
		vu+T5zmdTockSciy7AA8PDzM9PT0gdobN24QBAEASivyLEcphbXsz9x1pJRCKUUURXS7XbIsI897
		hfv5p9DHjx+TJAnFYhFrQame2qxfe2Bmq9VSSin74cMH2u32AWy/SGvN0NDQAbjdblMoeBhj0brX
		PMt6J89ztDYAupCm6fOtra2xer1ekFJ+UvHdu3cRQiCEQEpJqeSDEH1gRpql5Cqn4Di025HK8/x1
		Abi1ubn5y9HR0UKaph+B0zQliiLm5+eZm5uj2+1y8+YSUbRLllnSLEOmGVKm/f+xvHjxIg3D8Jbj
		OM5fl5eXd5VSRkp5MIIsy5BSUqlUmJubAyAIAr766kuSRPYbZyRSkmY5WEM7iuy/Go0oSZLbzm+N
		2Ws0GjcePnwoW60WaZqitUZrQ953+n/DWkOW56RpSpJIrDUg4Pnz57LZbH6vte64K0A3z//+5s2b
		X508eXKkVCq5QgiU1mitieMYrGViYoJut8u9e/fYjSL2kgSZSLDgug6duK3W19eftdvtb40xWgDU
		gB/h+JEjR5YXFhbGTp065ZV8H617I9FKIaXEcR0QLjJNMdpgjcZxBFG0q1Z++GF7Z2fny52dnQb0
		r80ICCDupOntV69efeE4zlC1Wi0IgbCA4xbw/TKu65LlOUZrCo4g7rTt+tpasr629jSO46/3oQBu
		Tu9J2uvluKvUze3t7eK7d++mkiRxg0rgFFzXUTpH5TlaK6IoVOvra8nq6uqPjUbjD3EcfxvHcfOn
		Poj9jwJQ6TeoAB3XrZTL5YVqtfpNsVicpvfOApgsy/4ZhuGtJElua607/28v/Ae4rikd88m8ZgAA
		AABJRU5ErkJggg==
	}

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
     if { [winfo exists .main.fbutton.button.exthardware]} { 
        return 
     } else {
        if { $::ExtHardware::showbutton == 1 } {

           frame .main.fbutton.button.space4 -width 15
           button .main.fbutton.button.exthardware -image tb_eng_disconnected
           .main.fbutton.button.exthardware configure -relief flat -border 1 -highlightthickness 0 \
               -anchor n -takefocus 0
           bind .main.fbutton.button.exthardware <Any-Enter> "+.main.fbutton.button.exthardware configure -relief groove"
           bind .main.fbutton.button.exthardware <Any-Leave> "+.main.fbutton.button.exthardware configure -relief flat; statusBarRestore %W; break"
           pack .main.fbutton.button.space4 .main.fbutton.button.exthardware -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
           pack .main.fbutton.button.exthardware -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0

           .main.fbutton.button.exthardware configure -command $::ExtHardware::bindbutton
        }
     }

  }

  #----------------------------------------------------------------------
  # Set the hardware connect button image
  #----------------------------------------------------------------------
  proc HWbuttonImg {img} {

    if { $::ExtHardware::showbutton == 1 } {
      .main.fbutton.button.exthardware configure -image $img -relief flat
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

        frame .main.fbutton.button.space4 -width 15
        button .main.fbutton.button.exthardware -image tb_eng_disconnected
        .main.fbutton.button.exthardware configure -relief flat -border 1 -highlightthickness 0 \
            -anchor n -takefocus 0
        bind .main.fbutton.button.exthardware <Any-Enter> "+.main.fbutton.button.exthardware configure -relief groove"
        bind .main.fbutton.button.exthardware <Any-Leave> "+.main.fbutton.button.exthardware configure -relief flat; statusBarRestore %W; break"
        pack .main.fbutton.button.space4 .main.fbutton.button.exthardware -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
        pack .main.fbutton.button.exthardware -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0

        .main.fbutton.button.exthardware configure -command $::ExtHardware::bindbutton
     }

    ::splash::add "External hardware configuration was found and loaded."
  }



#======================================================================

namespace eval inputengine {
  global ::ExtHardware::port ::ExtHardware::engine ::ExtHardware::param ::ExtHardware::hardware

  set engine     $::ExtHardware::engine
  set port       $::ExtHardware::port
  set param      $::ExtHardware::param

  set InputEngine(pipe)     ""
  set InputEngine(log)      ""
  set InputEngine(logCount) 0
  set InputEngine(init)     0
  set connectimg            tb_eng_ok
  set MovingPieceImg        $::board::letterToPiece(.)80
  set MoveText              "     "

  set NoClockTime           "--:--"
  set StoreClock            0

  set WhiteClock            $::inputengine::NoClockTime
  set BlackClock            $::inputengine::NoClockTime
  set oldWhiteClock         $::inputengine::NoClockTime
  set oldBlackClock         $::inputengine::NoClockTime
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
    if {$::tcl_version >= 8.5} {
       ::createToplevel $w
      ::setTitle $w [::tr IEConsole]
    } else {
       toplevel $w
       wm title $w [::tr IEConsole]
    }

    recordWinSize $w

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
    button $w.bRotate        -text [::tr IERotate]      -command { ::inputengine::rotateboard }

    button $w.bSync          -text [::tr IESynchronise] -command { ::inputengine::synchronise }
    button $w.bClose         -text [::tr Close]         -command { ::inputengine::connectdisconnect }

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


    # Store the time as comment
    checkbutton $w.bStoreClock -text "Store Clock" -variable ::inputengine::StoreClock

    grid $w.console    -stick ns    -column 0  -row 0 -columnspan 12
    grid $w.ysc        -stick ns    -column 12 -row 0

    grid $w.engine     -stick ewns   -column 0  -row 1 -columnspan 9

    grid $w.lmode      -stick ew    -column 0  -row 2
    grid $w.sendboth   -stick e     -column 2  -row 2 
    grid $w.sendwhite               -column 4  -row 2 
    grid $w.sendblack  -stick w     -column 6  -row 2 

    grid $w.bInfo      -stick ew    -column 0  -row 3
    ###---### grid $w.bRotate   -stick ew    -column 0  -row 4
    grid $w.bSync      -stick ew    -column 0  -row 5
    grid $w.bStoreClock -stick ew   -column 0  -row 6
    grid $w.bClose     -stick ew    -column 0  -row 11

    grid $w.bPiece     -stick nwes  -column 2  -row 3 -rowspan 9 -columnspan 3
    grid $w.bMove      -stick nwes  -column 5  -row 3 -rowspan 9 -columnspan 3

    grid $w.wClock     -stick nwes  -column 9 -row 11 -columnspan 7
    grid $w.bClock     -stick nwes  -column 9 -row 1  -columnspan 7

    grid $w.bd         -stick nw    -column 9  -row 2 -rowspan 9 -columnspan 7

    bind $w <Destroy> { catch ::inputengine::connectdisconnect }
    bind $w <F1> { helpWindow InputEngine}

    ::createToplevelFinalize $w
  }

  proc updateConsole {line} {
    set t .inputengineconsole.console
    $t insert end "$line\n"
    $t yview moveto 1
  }

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

	 set ::inputengine::engine     $::ExtHardware::engine
	 set ::inputengine::port       $::ExtHardware::port
	 set ::inputengine::param      $::ExtHardware::param

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
  # disconneet()
  #    Disconnect and close the input engine
  #----------------------------------------------------------------------
  proc disconnect {} {
    global ::inputengine::InputEngine
    set pipe $::inputengine::InputEngine(pipe)

    set ::inputengine::connectimg tb_eng_connecting 

    ::inputengine::sendToEngine "stop"
    ::inputengine::sendToEngine "quit"
    set ::inputengine::connectimg tb_eng_disconnected

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
    ::board::flip .main.board
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
    ::inputengine::sendToEngine "getclock"
  }

  proc strreverse {str} {
     set res {}
     set i [string length $str]
     while {$i > 0} {append res [string index $str [incr i -1]]}
     set res
  }

  #----------------------------------------------------------------------
  # readFromEngine()
  #     Event Handler for commands and moves sent from the input
  #     engine, implements input engine protocol
  #----------------------------------------------------------------------
  proc readFromEngine {} {
    global ::inputengine::InputEngine ::inputengine::connectimg
    set pipe $::inputengine::InputEngine(pipe)

    set line     [string trim [gets $pipe] ]

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
          if {$s1 == "0-"} {
            # casteling must not be rewritten
            set m "$s1$s2"
          } else {
            set m "$s1-$s2"
          }

          logEngine "$line"

          if {[catch {sc_move addSan $m}]} {
             ::utils::sound::PlaySound "sound_alert"
             logEngine "  info Illegal move detected!"
             logEngine "  info Ignoring: $m"
             .inputengineconsole.bPiece configure -background red
             .inputengineconsole.bMove  configure -background red -text $m
          } else {

            .inputengineconsole.bPiece configure -background green
            .inputengineconsole.bMove  configure -background green -text $m

             updateBoard -animate
             updateBoard -pgn
             ::inputengine::sendToEngine "getposition"
             ::inputengine::sendToEngine "getclock"
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
              # Generate a board position out of the FEN
              # RNBQKBNRPPPP.PPP............P................n..pppppppprnbqkb.r w
              # Something is in reverse here:
              ###---### set extpos $fen
              ###---### regsub -all {8} $extpos "........" extpos
              ###---### regsub -all {7} $extpos "......." extpos
              ###---### regsub -all {6} $extpos "......" extpos
              ###---### regsub -all {5} $extpos "....." extpos
              ###---### regsub -all {4} $extpos "...." extpos
              ###---### regsub -all {3} $extpos "..." extpos
              ###---### regsub -all {2} $extpos ".." extpos
              ###---### regsub -all {1} $extpos "." extpos
              ###---### regsub -all {/} $extpos "" extpos
              ###---### puts stderr [sc_pos board]
              ###---### puts stderr [strreverse "$extpos"]
              ###---### set extpos "$extpos w"
              ###---### ::board::update .inputengineconsole.bd "$extpos w"
            }
          } \
          {moving piece: [A-Z] *} {
            .inputengineconsole.bPiece configure -image $::board::letterToPiece([string range $event 14 end])80
          }\
          {moving piece: [a-z] *} {
            .inputengineconsole.bPiece configure -image $::board::letterToPiece([string range $event 14 end])80
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
            set ::inputengine::toMove "White"
            .inputengineconsole.wClock configure -background white
            .inputengineconsole.bClock configure -background gray -foreground black

            if {$::inputengine::StoreClock == 1} {
               if { ($::inputengine::oldWhiteClock != $::inputengine::NoClockTime) && \
                    ($::inputengine::WhiteClock    != $::inputengine::NoClockTime) } {
                  set wHrs [expr $::inputengine::WhiteClock / 60 / 60]
                  set wMin [expr ($::inputengine::WhiteClock - $wHrs*60*60) / 60 ]
                  set wSec [expr ($::inputengine::WhiteClock - $wHrs*60*60 - $wMin * 60) ]
                  set timediff [expr $::inputengine::oldWhiteClock - $::inputengine::WhiteClock]
                  set ::inputengine::oldWhiteClock $::inputengine::WhiteClock
                  sc_pos setComment "\[%ct $wHrs:$wMin:$wSec\] \[%emt $timediff\]"
               }
            }
          } \
          "!black to move!" {
            set ::inputengine::toMove "Black"
            .inputengineconsole.wClock configure -background gray
            .inputengineconsole.bClock configure -background black -foreground white

            if {$::inputengine::StoreClock == 1} {
               if { ($::inputengine::oldBlackClock != $::inputengine::NoClockTime) && \
                    ($::inputengine::BlackClock    != $::inputengine::NoClockTime) } {
                  set bHrs [expr $::inputengine::BlackClock / 60 / 60]
                  set bMin [expr ($::inputengine::BlackClock - $bHrs*60*60) / 60 ]
                  set bSec [expr ($::inputengine::BlackClock - $bHrs*60*60 - $bMin * 60) ]
                  set timediff [expr $::inputengine::oldBlackClock - $::inputengine::BlackClock]
                  set ::inputengine::oldBlackClock $::inputengine::BlackClock
                  sc_pos setComment "\[%ct $bHrs:$bMin:$bSec\] \[%emt $timediff\]"
               }
            }
          } \
          "No Clock detected" {
             set ::inputengine::WhiteClock $::inputengine::NoClockTime
             set ::inputengine::BlackClock $::inputengine::NoClockTime
             .inputengineconsole.wClock configure -text $::inputengine::WhiteClock
             .inputengineconsole.bClock configure -text $::inputengine::BlackClock
          } \
          "Time White:" {
            if { ($::inputengine::oldWhiteClock == $::inputengine::NoClockTime) } {
               set ::inputengine::oldWhiteClock $::inputengine::WhiteClock
            }
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

            ###---### Is this enough to set game clocks for all possible occurences?
            catch { ::gameclock::setSec 1 [expr -1*$::inputengine::WhiteClock] }
          } \
          "Time Black:" {
            if { ($::inputengine::oldBlackClock == $::inputengine::NoClockTime) } {
               set ::inputengine::oldBlackClock $::inputengine::BlackClock
            }
            regsub -all {[A-Za-z:# ]} $event "" ::inputengine::BlackClock

            set bHrs [expr $::inputengine::BlackClock / 60 / 60]
            set bMin [expr ($::inputengine::BlackClock - $bHrs*60*60) / 60 ]
            set bSec [expr ($::inputengine::BlackClock - $bHrs*60*60 - $bMin * 60) ]

            if {$bHrs > 0} {
               .inputengineconsole.bClock configure -text "$bHrs:$bMin:$bSec (EXT)"
            } else {
               .inputengineconsole.bClock configure -text "$bMin:$bSec (EXT)"
            }

            ###---### Is this enough to set game clocks for all possible occurences?
            catch { ::gameclock::setSec 2 [expr -1*$::inputengine::BlackClock] }
          } \
          "Wrong move performed:" {
             # This event can only be used if there is a possiblity to
             # send the last move to the input engine for it ot cross
             # check. This however is not easy in Scid, therefore
             # compare FEN.
             #
             # ::utils::sound::PlaySound "sound_alert"
             # logEngine "< info $event"
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
