MOPED - Netlogo program

Author: Erick Martins Ratamero - Erasmus Mundus Masters in Complex Systems Science - École Polytechnique, France


WHAT IS IT?

MOPED is a proposed model for peloton dynamics in competitive cycling. Using an agent-based approach, it aims to generate the very complex behaviour observed in real-life competitive cycling from a collective of agents with very simple rules themselves.




HOW TO USE IT

Choose the number of ACTIVE CYCLISTS. These special agents will be in white and they will tend to move forwards, making them more prone to going to the front of the peloton and spending energy.

Click on SETUP. This will generate 100 turtles by default, with at most 20 being active ones (as chosen before).

Click GO and the peloton will start working. PELOTON SPEED (in m/s) and GRADIENT (in %) of the terrain can be adjusted in real time.

CLick RELAY to make the front runner rotate back and leave someone else take the front.

The plots in place at the moment show:
1) energy left from the front runner / average energy left
2) average draft coefficient from active cyclists / average draft coefficient from non-active cyclists




THINGS TO NOTICE

White agents will tend to dominate the head of the peloton, no matter how many they are. 

At zero gradient and 45 km/h (12 m/s), the average time to complete exhaustion is around 4h (14400 seconds or 'ticks'). 

As total energy and recovery are normal-distributed parameters, some cyclists will get tired before others. When they do, they start drifting backwards and tend to hang at the back of the peloton or even lose contact. When completely spent, they are positioned at the lowest possible coordinate, as if they are not part of the peloton anymore.

Downhills (negative gradients) tend to make riders recover energy quite fast. Tired or spent riders can come back to the peloton if they recover sufficient energy.

After a long climb, the peloton tends to reduce and only the strongest riders are there. (but if the climb is too long, even the strongest will break down)
