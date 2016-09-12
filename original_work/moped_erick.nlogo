;; MOPED - Model of Peloton Dynamics
;;
;; Author: Erick Martins Ratamero
;; Erasmus Mundus Master in Complex Systems Science
;; Agent-Based Modeling - Prof. René Doursat



;; This model intends to replicate peloton dynamics at competitive 
;; cycling. Using common ideas from flocking models, as cohesive
;; and separating forces, and integrating variables and concepts
;; from real-life cycling, we manage to get satisfactory results.
;; 
;;
;; Parameters that can be set:
;; cyclists-relay: defines how many cyclists will have "active" behaviour,
;; trying to come to the front of the peloton. Default number of total cyclists
;; is 100.
;; peloton-speed: defines the average speed of the peloton, in m/s.
;; gradient: defines the inclination of the road, in % (rise/run).
;; each iteration of the program tries to model 1 second in real life.





turtles-own [    
  neighborhood    ;agentset with neighboring turtles
  speed
  draft-coefficient    
  energy-left
  recovery
  energy-spent
  active     ; boolean indicating if agent is willing to work or not 
  x-acc  ;acceleration in direction x
  y-acc ;acceleration in direction x
  relay   ;boolean, set when an agent in front of the peloton is supposed to rotate back
  exhausted    ;boolean, set when energy-left < 100
  assumed-front  ;boolean, used for making an agent step front when the guy in front rotates back
]
;globals[elevation]
to setup
  
  clear-all
  set-patch-size 12
  resize-world -30 30 -15 15
 
  ask patches with [abs pycor > 14] [set pcolor green]  ;define a road
  ask patches with [abs pycor < 14][ set pcolor random-float 1 ]
  
  ask n-of 100 patches with [abs pycor < 6 and abs pxcor < 10 ] [ sprout 1 ] ;spawn 100 cyclists in the center, one per patch
  ask turtles [
    set size 0.5
    
    set energy-left random-normal 760 50  ;calculated for typical time to exhaustion at 12m/s for max10 450W (typical for 7.1W/kg and a rider of 63kg)
    set recovery random-normal 225 15  ; calculated based on lactate threshold of 70% S, where S is the speed at max10 power

    set heading 90
    set speed peloton-speed
    set active false
    set draft-coefficient 0
    set x-acc 0
    set y-acc 0
    set relay false
    set exhausted false
    set assumed-front false
    ] 
  
  ask turtles with [who < cyclists-relay]   ;the agents with lowest "who" become the active cyclists, indicated in white
  [
    set color white
    set active true
  ]

end



  

to go
  
  ask turtles [calculate-position]
  ask turtles [look-for-draft]
  
  ask turtles [set-speeds]
  ask turtles [calculate-energy]
  ask turtles [move]
  plotting
  follow max-one-of turtles [xcor] ;center view on the foremost agent
  tick
end



to look-for-draft    ;;function to consider moving right/left looking for a lowest draft coefficient - non-implemented
  
  set draft-coefficient calculate-draft
;  set ycor ycor + 0.2
;  let draft-above calculate-draft
 ; set ycor ycor - 0.4
 ; let draft-below calculate-draft
  ;set ycor ycor + 0.2
  ;if draft-above < draft-below and draft-above < draft-coefficient
  ;[
   ; set ycor ycor + 0.2
    ;set draft-coefficient draft-above
  ;]
  
  
  ;if draft-below < draft-above and draft-below < draft-coefficient
  ;[
   ; set ycor ycor - 0.2
    ;set draft-coefficient draft-below
  ;]
  
end



to plotting    ;;general plotting routine - changed a lot to generate different graphics to the report
  ;set elevation elevation + peloton-speed * gradient / 100
  set-current-plot "energy"
  plot ([energy-left] of max-one-of turtles [xcor]) / mean [energy-left] of turtles
  ;set-current-plot-pen "forward"
  ;if count turtles with [x-acc > 0] > 0 [plot mean [draft-coefficient] of turtles with [x-acc > 0]]
  ;set-current-plot-pen "backward"
  ;if count turtles with [x-acc < 0] > 0 [plot mean [draft-coefficient] of turtles with [x-acc < 0]]
  ;plot (mean [energy-left] of turtles with [active = true] / mean [energy-left] of turtles with [active = false]) * 100
  ;plot 100
  set-current-plot "DC"
 
  ;plot ([energy-left] of max-one-of turtles [xcor])
  ;plot count turtles with [exhausted = true]
  if count turtles with [active = true] > 0
  [plot (mean [draft-coefficient] of turtles with [active = true] / mean [draft-coefficient] of turtles with [active = false]) * 100
  plot 100]
 
end



to calculate-position
  set x-acc 0
  set y-acc 0
  set neighborhood other turtles in-cone 20 140   ; neighborhood set for cohesive force - agents in front inside a fairly big distance
  if any? neighborhood
    [
      ;show neighborhood
      calculate-average-pos
      calculate-separation-factor
      
      
    ]
    
    
    
end

to put-middle-bias  ;tiny bias to the center, tends to affect more the forerunners, making them go to the middle of the road
  let delta 0.03
  if ycor > 0 [
    
    set y-acc (y-acc - delta)
    ]
  if ycor < 0 [set y-acc y-acc + delta]
end



to move
  if max-one-of turtles [xcor] = self and assumed-front = false[  ;check if the agent just became the frontrunner and sets a boolean accordingly
    set xcor xcor + 1
    set assumed-front true
    
  ]
    
    set xcor (xcor + x-acc) + random-float 0.02 - 0.01    ; sums the resulting forces to the coordinate, with a small random factor, for both x and y
    
    if xcor > 20 [set xcor 20]       ; creates borders, making it impossible for the agents to go out of the box
    if xcor < -20 [set xcor -20]
    
  set ycor ycor + y-acc + random-float 0.02 - 0.01
  if ycor > 10 [set ycor 10]
    if ycor < -10 [set ycor -10]
end
      
      
to calculate-average-pos    ; calculate cohesive force, factor 0.05 tries to reflect the fact that speed/direction ajustments in real life are relatively small
                                                                                        ;compared to the speed the cyclists are travelling
  let x-average mean [ xcor ] of neighborhood
   
      set x-acc x-acc + (x-average - xcor) * 0.05
    
  
  
  let y-average mean [ ycor ] of neighborhood
  set y-acc y-acc + (y-average - ycor) * 0.05
 
  
end

to calculate-separation-factor      ; calculate separating force, factor 0.05 tries to reflect the fact that speed/direction ajustments in real life are relatively small
                                                                                        ;compared to the speed the cyclists are travelling
  
  set neighborhood other turtles in-cone 2 140                          ;for separating force, we redefine the neighborhood, making each cyclist move away only from nearby
  let x-total sum [ xcor / distance myself ] of neighborhood                                        ;cyclists in front of him
  ;show x-total
  let y-total sum [ ycor / distance myself ] of neighborhood 
  ;show y-total
  let x-average sum [ [xcor] of myself / distance myself ] of neighborhood
  ;show x-average
  let y-average sum [ [ycor] of myself / distance myself ] of neighborhood
  ;show y-average
  set x-acc x-acc + ((x-average - x-total) * 0.05)
 
  ;show x-acc
  
  set y-acc y-acc + ((y-average - y-total) * 0.05)
  ;show y-acc

end
      
      
to-report calculate-draft            ; calculate the drafting coefficient: done in 3 parts. Draft is negligible over 3m of distance.
                                          ;1) check for neighbors in a 10 deg. angle, these will give him full benefit of drafting
  let draft 0                             ;2) check for neighbors in a 50 deg. angle, these will give him 0.3*the full benefit, because drafting diminishes in the diagonal
                                          ;3) check for neighbors in a 90 deg. angle, these will give him a very small 0.1*full benefit
  ifelse any? neighborhood
  [
    let neighborhood-draft  neighborhood in-cone 3 10
    
    let insiders []
    ifelse any? neighborhood-draft
    [
      set draft 1
      foreach sort-by [distance ?1 < distance ?2] neighborhood-draft
      [
     
        let dist distance ?
        
        set draft draft - 1 + (0.62 - 0.0104 * dist + 0.0452 * dist ^ 2)
        
        set insiders fput who insiders
      ]
    ]
    [
      set draft 1
    ]
    
    set neighborhood-draft neighborhood in-cone 3 50 
    
    ifelse any? neighborhood-draft
    [
      foreach sort-by [distance ?1 < distance ?2] neighborhood-draft
      [
        ifelse member? who insiders
        []
        [
          
          let dist distance ?
          set draft draft - 0.3 * (1 - (0.62 - 0.0104 * dist + 0.0452 * dist ^ 2))
          set insiders fput who insiders
        ]
      ]
    ]
    [
      set draft 1
    ]
    
    
    set neighborhood-draft neighborhood in-cone 3 90 
 
    
    ifelse any? neighborhood-draft
    [
      foreach sort-by [distance ?1 < distance ?2] neighborhood-draft
      [
        ifelse member? who insiders
        []
        [
          let dist distance ?
          set draft draft - 0.1 * (1 - (0.62 - 0.0104 * dist + 0.0452 * dist ^ 2))
          
        ]
      ]
    ]
    [
      set draft 1
    ]
    
  ]
  [
    set draft 1
  ]
  
  report draft
  
  
end



to calculate-energy   ;based on draft coefficient and speed, calculate spent energy in that second
   
 
    set energy-spent 0
    
      set energy-spent (0.185 * draft-coefficient * (speed ^ 3) + (0.0053 + gradient / 100) * 9.81 * 70 * speed) 
      
      
    
    set energy-left energy-left - energy-spent / 1000   ;energy left is in kJ, energy-spent in W
    set energy-left energy-left + recovery / 1000
    
    if energy-left > 1000[set energy-left 1000] ;caps storage of energy at 1000kJ
    ifelse energy-left < 100 [   ;defines a cyclist as exhausted
      set exhausted true
      set speed speed - 0.3   ;he becomes slower and drift backwards
      set x-acc x-acc - 0.3
      
    ]
    [
     set exhausted false 
    ]
    if energy-left <= 0  ;cyclist completely spent - he moves to the leftmost coordinate and becomes much slower
    [
      set speed speed - 2
      set xcor -20
      set energy-left 0
    ]
 
end


to set-speeds
  let average-energy mean [energy-left] of turtles
  
    set speed peloton-speed + x-acc   ;define personal speed as a small deviation from the average speed
                                      ;a value of 1 in x-acc efectively means 1m/s more of speed, since we're using coordinate values in meters
 
    if energy-left < (average-energy * 0.98) and relay = false and not any? neighborhood ;if frontrunner is below 98% of average energy, he rotates back
    [                                                                                    ;rotating back means moving to his left and becoming slower
      set speed speed - 1
      set ycor ycor + 0.5
      set relay true
      set assumed-front false
      ;show who
        
  ]
  
    if relay = true[    ;when rotating back, as soom as he finds a draft coef. of less than 0.8, he stops his rotation and comes back to normal operation
      ifelse draft-coefficient < 0.8[
        set speed speed + 1
        set relay false]

        [set x-acc x-acc - 0.15    ;a cyclist rotating slowly goes back and receives 0.05 in y to offset the center bias
          set y-acc y-acc + 0.05]
    ]
    
    if active = true and self != max-one-of turtles [xcor]  ;active cyclists that are not in front receive a very small bonus in x-acc, enough to make them come to the front
    [
      set x-acc x-acc + 0.03
    ]
    
    put-middle-bias
    


  end

  


to relay-front   ; function called when "relay" button is pressed - makes the front runner rotate back, in the same way it would happen naturally 
  
    ask max-one-of turtles [xcor]
    [
      set speed speed - 1
      set ycor ycor + 0.5
      set relay true
    ]
  
  
end

  
@#$#@#$#@
GRAPHICS-WINDOW
250
10
992
413
30
15
12.0
1
10
1
1
1
0
1
1
1
-30
30
-15
15
1
1
1
ticks

BUTTON
36
16
113
49
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
125
14
206
47
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

PLOT
13
209
234
382
DC
NIL
NIL
0.0
10.0
0.7
1.0
true
false
PENS
"default" 1.0 0 -16777216 true
"forward" 1.0 0 -13345367 true
"backward" 1.0 0 -2674135 true

PLOT
12
382
233
554
energy
NIL
NIL
0.0
10.0
0.0
1.0
true
false
PENS
"default" 1.0 0 -16777216 true

SLIDER
34
92
206
125
cyclists-relay
cyclists-relay
0
20
10
1
1
NIL
HORIZONTAL

SLIDER
34
131
206
164
peloton-speed
peloton-speed
0
15
12
0.1
1
NIL
HORIZONTAL

SLIDER
33
171
205
204
gradient
gradient
-10
10
0.6
0.1
1
%
HORIZONTAL

BUTTON
93
53
156
86
relay
relay-front
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

@#$#@#$#@
WHAT IS IT?
-----------
This model is an attempt to mimic the flocking of birds.  (The resulting motion also resembles schools of fish.)  The flocks that appear in this model are not created or led in any way by special leader birds.  Rather, each bird is following exactly the same set of rules, from which flocks emerge.


HOW IT WORKS
------------
The birds follow three rules: "alignment", "separation", and "cohesion".

"Alignment" means that a bird tends to turn so that it is moving in the same direction that nearby birds are moving.

"Separation" means that a bird will turn to avoid another bird which gets too close.

"Cohesion" means that a bird will move towards other nearby birds (unless another bird is too close).

When two birds are too close, the "separation" rule overrides the other two, which are deactivated until the minimum separation is achieved.

The three rules affect only the bird's heading.  Each bird always moves forward at the same constant speed.


HOW TO USE IT
-------------
First, determine the number of birds you want in the simulation and set the POPULATION slider to that value.  Press SETUP to create the birds, and press GO to have them start flying around.

The default settings for the sliders will produce reasonably good flocking behavior.  However, you can play with them to get variations:

Three TURN-ANGLE sliders control the maximum angle a bird can turn as a result of each rule.

VISION is the distance that each bird can see 360 degrees around it.


THINGS TO NOTICE
----------------
Central to the model is the observation that flocks form without a leader.

There are no random numbers used in this model, except to position the birds initially.  The fluid, lifelike behavior of the birds is produced entirely by deterministic rules.

Also, notice that each flock is dynamic.  A flock, once together, is not guaranteed to keep all of its members.  Why do you think this is?

After running the model for a while, all of the birds have approximately the same heading.  Why?

Sometimes a bird breaks away from its flock.  How does this happen?  You may need to slow down the model or run it step by step in order to observe this phenomenon.


THINGS TO TRY
-------------
Play with the sliders to see if you can get tighter flocks, looser flocks, fewer flocks, more flocks, more or less splitting and joining of flocks, more or less rearranging of birds within flocks, etc.

You can turn off a rule entirely by setting that rule's angle slider to zero.  Is one rule by itself enough to produce at least some flocking?  What about two rules?  What's missing from the resulting behavior when you leave out each rule?

Will running the model for a long time produce a static flock?  Or will the birds never settle down to an unchanging formation?  Remember, there are no random numbers used in this model.


EXTENDING THE MODEL
-------------------
Currently the birds can "see" all around them.  What happens if birds can only see in front of them?  The IN-CONE primitive can be used for this.

Is there some way to get V-shaped flocks, like migrating geese?

What happens if you put walls around the edges of the world that the birds can't fly into?

Can you get the birds to fly around obstacles in the middle of the world?

What would happen if you gave the birds different velocities?  For example, you could make birds that are not near other birds fly faster to catch up to the flock.  Or, you could simulate the diminished air resistance that birds experience when flying together by making them fly faster when in a group.

Are there other interesting ways you can make the birds different from each other?  There could be random variation in the population, or you could have distinct "species" of bird.


NETLOGO FEATURES
----------------
Notice the need for the SUBTRACT-HEADINGS primitive and special procedure for averaging groups of headings.  Just subtracting the numbers, or averaging the numbers, doesn't give you the results you'd expect, because of the discontinuity where headings wrap back to 0 once they reach 360.


RELATED MODELS
--------------
Moths
Flocking Vee Formation


CREDITS AND REFERENCES
----------------------
This model is inspired by the Boids simulation invented by Craig Reynolds.  The algorithm we use here is roughly similar to the original Boids algorithm, but it is not the same.  The exact details of the algorithm tend not to matter very much -- as long as you have alignment, separation, and cohesion, you will usually get flocking behavior resembling that produced by Reynolds' original model.  Information on Boids is available at http://www.red3d.com/cwr/boids/.


HOW TO CITE
-----------
If you mention this model in an academic publication, we ask that you include these citations for the model itself and for the NetLogo software:
- Wilensky, U. (1998).  NetLogo Flocking model.  http://ccl.northwestern.edu/netlogo/models/Flocking.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
- Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:
- Copyright 1998 Uri Wilensky. All rights reserved. See http://ccl.northwestern.edu/netlogo/models/Flocking for terms of use.


COPYRIGHT NOTICE
----------------
Copyright 1998 Uri Wilensky. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:
a) this copyright notice is included.
b) this model will not be redistributed for profit without permission from Uri Wilensky. Contact Uri Wilensky for appropriate licenses for redistribution for profit.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2002.

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
NetLogo 4.1.3
@#$#@#$#@
set population 200
setup
repeat 200 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
