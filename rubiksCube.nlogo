breed [kernelsx kernelx]   ; turtles in the center of the cube used to save orientation
breed [kernelsy kernely]

globals
[mx ;saved mouse x-cor
 my ;saved mouse y-cor
 displacex ;difference between the saved mouse-xcor and current mouse-xcor
 displacey ;difference between the saved mouse-ycor and current mouse-ycor
 v;difference between ovtheta and vtheta
 t ;difference between otheta and theta
 scrambled ;checks if the cube has been scrambled
   reddone ;checks if red face is done
  bluedone ;checks if blue face is done
  whitedone ;checks if white face isdone
  yellowdone ;checks if yellow face is done
  greendone ;checks if green face is done
  orangedone ;checks if orange face is done
 ]

turtles-own [
  x-pos  ;; x-pos, y-pos, and z-pos are the cartesian coordinates
  y-pos  ;; don't confuse them with xcor and ycor, which are predefined
  z-pos  ;;   NetLogo variables for turtles
  p     ;distance of turtle from origin
  rtheta   ;angle of turtle projection in the z-y plane from x-axis (spherical)
  theta ; angle of the turtle’s projection on the x-y plane.
  phi ; turtles angle of incidence to the z axis.
  vtheta ;angle of the turtle’s projection on the x-z plane
  q ;distance from y-axis
  r ;distance from x-axis
  s ;distance from z-axis
  rsign ;side of the y-axis on which the turtles are located
  sign ; which side of x-axis (spherical)
  otheta; original theta value (changes upon rotation to reflect the rotation that took place)
  ovtheta ;original vtheta value (changes upon rotation)
  ortheta ;original rtheta value
  oq  ;original q value
  orr  ;original r value
  os ;original s value
  ]

to mouse ;this procedure allows user to view the cube by dragging it using his mouse
  set mx mouse-xcor   ;sets mx and my  to current mouse coordinates
  set my mouse-ycor
   if mouse-down?
   [if mouse-xcor != mx     ;if mouse-xcor changes
   [ifelse mouse-xcor < mx   ;direction of change
   [set displacex mx - mouse-xcor   ;amount of change
      ask turtles
      [set theta (theta - abs velocity * displacex) mod 360  ;rotate cube to reflect the change
        render-turtle
    cartesian x-pos y-pos z-pos
    scale]  tick]
    [set displacex mouse-xcor - mx
     ask turtles
     [set theta (theta + abs velocity * displacex) mod 360       ;; same for all the others
       render-turtle
    cartesian x-pos y-pos z-pos
    scale] tick] ]

if mouse-ycor != my

  [ifelse mouse-ycor < my

  [set displacex my - mouse-ycor
      ask turtles
      [set vtheta (vtheta + (abs velocity * displacey)) mod 360
        vrender-turtle
    cartesian x-pos y-pos z-pos
    scale]  tick]
    [set displacey mouse-ycor - my
     ask turtles
     [set vtheta (vtheta - (abs velocity * displacey)) mod 360
       vrender-turtle
    cartesian x-pos y-pos z-pos
    scale] tick] ]]
end

to vgo ;vertical rotation of cube
    ask turtles
  [
  set vtheta (velocity + vtheta) mod 360 ; increment vtheta to simulate vertical rotation
    vrender-turtle;renders turtle new position in cube
   cartesian x-pos y-pos z-pos];updates distances and angles
  tick
end


to go ; horizontal rotation of cube
  ask turtles
  [
    set theta (theta + velocity) mod 360 ; increment theta to simulate rotation
    render-turtle
    cartesian x-pos y-pos z-pos
  ]

  tick
end


to setup ;Rubik’s cube spawns
  clear-all
  set-default-shape turtles "circle"
  create-turtles num-turtles
  [set size 1

   ifelse y-pos > 0 [set sign 1]          ;set signs
    [set sign -1]
    ifelse x-pos > 0 [set rsign 1]
    [set rsign -1]
    let temp-alpha 35 * (1 - 2 * (random 2))   ; +-35
    ; random distribution bounded by +-35
    let temp-beta 35 - 2 * (random-float 35)
    let temp-gamma (random 3)                          ; front/back or left/right?
    ifelse temp-gamma = 0
    [ ifelse temp-alpha > 0
      [set color orange];front is orange
      [set color red  ] ;back is red                               ; generate front & back surrotate
      cartesian (temp-alpha)
                (temp-beta)
                (35 - (2 * (random-float 35)))
    ]
    [  ifelse temp-alpha > 0
      [set color blue];right is blue
      [set color green  ];left is green
      ifelse random 2 = 1
      [cartesian (temp-beta)                             ; generating the side surrotate
                (temp-alpha)
                (35 - (2 * (random-float 35)))
      ]
    [  ifelse temp-alpha > 0
      [set color yellow];above is yellow
      [set color white  ] ;bottom is white                                  ;generate top and bottom surrotate
      cartesian (35 - (2 * (random-float 35)))
                 (temp-beta)
                (temp-alpha)

    ]]
    ]
    create-kernelsx 1 [set x-pos 10        ;orients one of the kernels to the x axis
       set y-pos 0.01
      set z-pos 0.01
      set hidden? true
      cartesian x-pos y-pos z-pos
      ]
    create-kernelsy 1 [set y-pos 10      ;the other is orineted to the y axis
       set x-pos 0.01
      set z-pos 0.0
      set hidden? true
      cartesian x-pos y-pos z-pos
      ]

    ask turtles [
    render-turtle
    set ortheta rtheta            ;;save all the original values
    set otheta theta
    set ovtheta vtheta
    set oq q
    set orr r
    set os s
  ]
    set scrambled 0
  set reddone 0
  set bluedone 0
  set whitedone 0
  set yellowdone 0      ;it hasn't been scrambled yet and none of the sides have been solved yet
  set greendone 0
  set orangedone 0
  reset-ticks
end

to cartesian [x y z]                            ;;updates angles and distances
  set r sqrt((y ^ 2) + (z ^ 2))
  set p sqrt((x ^ 2) + (y ^ 2) + (z ^ 2))
  set q sqrt((x ^ 2) + (z ^ 2))
  set s sqrt((y ^ 2) + (x ^ 2))
  set phi (atan sqrt((x ^ 2) + (y ^ 2)) z)
  set theta (atan y x)
  set vtheta (atan x z)
  set rtheta (atan y z)
end

to render-turtle                         ;wrapper function
  calculate-turtle-position
  scale
  set-turtle-position
end

to vrender-turtle                      ;similar wrapper function to be used in vertical rotation
  vcalculate-turtle-position
  scale
  set-turtle-position
end

to rrender-turtle                       ;to be used in rotation around the x-axis
  rcalculate-turtle-position
  scale
  set-turtle-position
end

;; convert from spherical to cartesian coordinates after horizontal rotation
to calculate-turtle-position
  set y-pos p * (sin phi) * (sin theta)
  set x-pos p * (sin phi) * (cos theta)
  set z-pos p * (cos phi)
end

;; convert from spherical to cartesian coordinates after vertical rotation
to vcalculate-turtle-position
  ifelse y-pos > 0 [set sign 1]
    [set sign -1]
  set y-pos (sqrt ((p ^ 2) - (q ^ 2))) * sign
  set x-pos q * (sin vtheta)
  set z-pos q * (cos vtheta)
end

;; convert from spherical to cartesian coordinates rotation around the x-axis
to rcalculate-turtle-position
  ifelse x-pos > 0 [set rsign 1]
    [set rsign -1]
  set x-pos sqrt (p ^ 2 - r ^ 2) * rsign
  set y-pos r * (sin rtheta)
   set z-pos r * (cos rtheta)
end

;; set the turtle's position using netlogo coordinates
to set-turtle-position
    setxy y-pos z-pos
end

to resetx
  ifelse ovtheta > vtheta
  [set v (ovtheta - vtheta)]
  [set v (vtheta - ovtheta)]   ;to set v
end

to resety
  ifelse otheta > theta
  [set t (otheta - theta)]
  [set t (theta - otheta)]          ;to set t

end

;;;FACE ROTATION;;;;
to rotate
 ask kernelsx [resetx]  ;uses the kernels to set t and c
 ask kernelsy [resety]

 ask turtles [
  rthis ;wrappers that return the cube to previous orientation
  this
  that
]

 tick

if rotate-color = "blue"  ;chooses which side to rotate based on the chooser
 [rotate-blue]                 ;and calls in the appropriate helper
if rotate-color = "green"
 [rotate-green]
 if rotate-color = "white"
 [rotate-white]
 if rotate-color = "yellow"
 [rotate-yellow]
 if rotate-color = "red"
 [rotate-red]
 if rotate-color = "orange"
 [rotate-orange]

 if (count turtles with [shade-of? white color and z-pos < -34.9] > (8.3 / 54) * count turtles)
 [set whitedone 1]
 if (count turtles with [shade-of? yellow color and z-pos > 34.9] > (8.3 / 54) * count turtles)
 [set yellowdone 1]
 if (count turtles with [shade-of? orange color and x-pos > 33.9] > (8.3 / 54) * count turtles)
 [set orangedone 1]
 if (count turtles with [shade-of? red color and x-pos < -34.9] > (8.3 / 54) * count turtles)
 [set reddone 1]
 if (count turtles with [shade-of? green color and y-pos < -33.9] > (8.3 / 54) * count turtles)
 [set greendone 1]
 if (count turtles with [shade-of? blue color and y-pos > 34.9] > (8.3 / 54) * count turtles)
 [set bluedone 1]
;sets the “done” function to 1 when the side is completed

 if scrambled = 1 and whitedone = 1 and yellowdone = 1 and orangedone = 1 and reddone = 1
 and greendone = 1 and bluedone = 1 [ask patches [set pcolor white]]
;sets the background to white if the cube is completed after being scrambled

ask turtles with [breed != kernelsx and breed != kernelsy]
    ;resets the original values to reflect the rotation
  [set oq q
  set orr r
  set os s
  set ortheta rtheta
set otheta theta
set ovtheta vtheta]

ask turtles [set theta (theta + t) mod 360;
  calculate-turtle-position
  cartesian x-pos y-pos z-pos]
 tick                                          ;returns the cube to its previous orientation

 ask turtles [set vtheta (vtheta + v) mod 360
  vrender-turtle
  cartesian x-pos y-pos z-pos
  scale]
 tick
end


to rotate-blue
ask turtles [
  if y-pos > 11.83 [set vtheta vtheta + 90
    ;rotates each side by determining the coordinates that
    ;are required for the turtle to be part of the chosen side
      ;and then rotating the required angle 90 degrees
  vcalculate-turtle-position
  cartesian x-pos y-pos z-pos]]
 tick
end

to rotate-green
ask turtles [
  if y-pos < -11.83 [set vtheta vtheta + 90
  ]
  vcalculate-turtle-position
  cartesian x-pos y-pos z-pos]
 tick
end

to rotate-white
ask turtles [
  if z-pos < -11.83 [set theta theta + 90
  ]
  calculate-turtle-position
  cartesian x-pos y-pos z-pos]
 tick
end

to rotate-yellow
ask turtles [
  if z-pos > 11.83 [set theta theta + 90
  ]
  calculate-turtle-position
  cartesian x-pos y-pos z-pos]
 tick
end

to rotate-red
ask turtles [
  if x-pos < -11.83 [set rtheta rtheta + 90
  ]
  rcalculate-turtle-position
  cartesian x-pos y-pos z-pos]
 tick
end

to rotate-orange
ask turtles [
  if x-pos > 11.83 [set rtheta rtheta + 90
  ]
  rcalculate-turtle-position
  cartesian x-pos y-pos z-pos]
 tick
end


to that ;this, that, and rthis turns the cube to an easy to maneuver position
;sets center pieces to setup orientation and everything else relatively
  set q oq
  set vtheta ovtheta
  vcalculate-turtle-position
  cartesian x-pos y-pos z-pos
end

to this
  set theta otheta
  calculate-turtle-position
  cartesian x-pos y-pos z-pos
end

to rthis
   set r orr
  set rtheta ortheta
  rcalculate-turtle-position
  cartesian x-pos y-pos z-pos
end

to scale
  set color scale-color color x-pos -35 85
  ;creates illusion of depth; the further back a turtle,
end ;the darker it is

to scramble [x] ;scrambles cube
  ask patches [set pcolor black]
  set reddone 0          ; sets all sides as not done
  set bluedone 0
  set whitedone 0
  set yellowdone 0
  set greendone 0
  set orangedone 0
  set scrambled 1
  repeat scramble_times [      ;rotates a random side scramble_times times
    set x random 6
  if x = 0
  [set rotate-color "red"]
  if x = 1
  [set rotate-color "orange"]
  if x = 2
  [set rotate-color "yellow"]
  if x = 3
  [set rotate-color "blue"]
  if x = 4
  [set rotate-color "white"]
  if x = 5
  [set rotate-color "green"]
  rotate
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
301
10
672
382
-1
-1
3.0
1
10
1
1
1
0
0
0
1
-60
60
-60
60
1
1
1
ticks
30.0

BUTTON
17
102
138
135
horizontal go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
149
72
279
105
num-turtles
num-turtles
0
10000
10000.0
1
1
NIL
HORIZONTAL

SLIDER
151
114
281
147
velocity
velocity
-10.0
10.0
4.0
1.0
1
NIL
HORIZONTAL

BUTTON
16
20
135
53
setup
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
16
58
136
91
vertical go
vgo \n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
18
143
138
176
NIL
mouse
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
20
227
142
260
NIL
rotate
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
148
18
286
63
rotate-color
rotate-color
"yellow" "white" "red" "orange" "blue" "green"
0

BUTTON
20
186
139
219
scramble
scramble 1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
152
158
283
191
scramble_times
scramble_times
1
15
10.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model creates a 3D Rubik’s cube out of turtles on an actually 2D plane by mapping turtles between cartesian and spherical coordinates. The user can solve the cube much like he can a real Rubik’s cube.

## HOW IT WORKS

To create the 3D shapes the program randomly generates turtles about the shell of the cube. To render the cube in the NetLogo view, it translates the turtles from spherical to cartesian coordinates using shades to simulate depth. The positions of the turtles are always stored as spherical coordinates because they are rotated on the all of the spherical axes.

Converting from cartesian to spherical coordinates.
However there are several ways of doing this. I used different angles to define them, depending on which angle I was changing.

After changing theta:
>x = r * cos(theta) = p * sin(phi) * cos(theta)
>y = r * sin(theta) = p * sin(phi) * sin(theta)
>z = p * cos(theta)

After changing vtheta:
>ifelse y-pos > 0 [set sign 1]
>   [set sign -1]
>  y-pos (sqrt ((p ^ 2) - (q ^ 2))) * sign
>  x-pos q * (sin vtheta)
  >  z-pos q * (cos vtheta)

After changing rtheta:
> ifelse x-pos > 0 [set rsign 1]
    [set rsign -1]
>  x-pos sqrt (p ^ 2 - r ^ 2) * rsign
>  y-pos r * (sin rtheta)
>  z-pos r * (cos rtheta)


theta:  angle of the turtle's projection on the x-y plane.
phi:  turtles angle of incidence to the z axis.
vtheta:  angle of the turtle's projection on the x-z plane.
rtheta:  angle of the turtle's projection on the z-y plane.
p: distance of the turtle from the origin.
q: distance of the turtle from the y axis.
r: distance of the turtle from the x axis.
s:distance of the turtle from the z axis
rsign: side of the x axis on which the turtles are located.
sign: side of the y axis on which the turtle is located.
otheta: original theta value. (subject to change when rotating faces)
ovtheta: original vtheta value. (subject to change when rotating faces)
ortheta: original rtheta vlaue. (subject to change when rotating faces)
oq: original q value. (subject to change when rotating faces)
orr: original r value. (subject to change when rotating faces)



## HOW TO USE IT

Click the setup button to spawn a Rubik’s cube.  The turtles are randomly distributed about the surface of the cube. Click SCRAMBLE button to scramble the cube.

Solve by rotating different faces. To do this, select the face you want to rotate by choosing the color of that face’s center piece in inputer rotate-color and using (counter)clockwise switch to control in which direction you would like to rotate that face.

GO (forever) starts rotating the model around the z axis.

VGO (forever) starts rotating the model around the y axis.

RGO (forever) starts rotating the model around the x axis.

COLOR determines the color that is used to simulate depth in generating the various shapes (uses predefined NetLogo color constants).

NUM-TURTLES determines the number of turtles that are used to generate the various shapes.

VELOCITY determines the speed at which the turtles are rotated.

SCRAMBLE_TIMES determines how many scrambles SCRAMBLE procedure will do

(Rotating turtles in the go procedure is implemented simply by increasing each turtle's theta variable by velocity!  *Rotating* turtles (around the z-axis) is easy in spherical coordinates.  However it's far easier to *transpose* turtles in cartesian coordinates.)
A similar thing is done for the other go’s only other angles are increased by velocity.

FACES rotates the face indicated by rotate-color 90 degrees.

SCRAMBLE scrambles the cube by taking the scramble_times value and rotating a random face that many times



## THINGS TO NOTICE

Notice that turtles closer (positive) on the x-axis appear lighter in shade and turtles further away (negative) appear darker in shade.

## THINGS TO TRY

Solve the cube.

## CREDITS AND REFERENCES

* Wilensky, U. (1998).  NetLogo 3D Solids model.  http://ccl.northwestern.edu/netlogo/models/3DSolids.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

I took the cube-surface-setup procedure and related spherical to cartesian conversion procedures from Uri Wilensky’s NetLogo 3D Solids.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
