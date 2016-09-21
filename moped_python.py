from mesa import Agent, Model
from mesa.space import ContinuousSpace
from mesa.time import RandomActivation
import random
import matplotlib.pyplot as plt
import numpy as np

mean_energy=760
var_energy=50
mean_recovery=225
var_recovery=15
active_cyclists=10
timesteps=10000


def look_for_draft(cyclists):
    count=0
    for cy in cyclists:
        rem_cyclist=cyclists[:count]+cyclists[count+1:]
        currdraft=calculate_draft(rem_cyclist,cy.xpos,cy.ypos)
        abovedraft=calculate_draft(rem_cyclist,cy.xpos,cy.ypos + 0.2)
        belowdraft=calculate_draft(rem_cyclist,cy.xpos,cy.ypos - 0.2)
        if abovedraft>currdraft:
            if belowdraft<currdraft:
                cy.yacc=belowdraft-currdraft
        else:
            if belowdraft>currdraft:
                cy.yacc=abovedraft-currdraft
            else:
                cy.yacc=abovedraft-belowdraft


        count=count+1


def calculate_draft(cyclists,xpos,ypos):
    


class Cyclist(Agent):

    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)
        self.neighborhood=[]
        self.speed=0.0
        self.draft_coefficient=0.0
        self.energy_left=random.gauss(mean_energy,var_energy)
        self.recovery=random.gauss(mean_recovery,var_recovery)
        self.active=False
        self.x_acc=0.0
        self.y_acc=0.0
        self.relay=False
        self.exhausted=False
        self.assumed_front=False

    def get_x_acc(self):
        return self.x_acc
    def set_neighbor(self,neighbor):
        self.neighborhood.append(neighbor)
    def get_neighborhood(self):
        return self.neighborhood


class Race(Model):
    """A model with some number of agents."""
    def __init__(self, N, width, height):
        self.num_agents = N
        self.space = ContinuousSpace(width, height, False)
        self.schedule = RandomActivation(self)


        # Create agents
        for i in range(self.num_agents):
            a = Cyclist(i, self)
            self.schedule.add(a)
            # Add the agent to a random grid cell
            x = random.uniform(0,self.space.width)
            y = random.uniform(0.3*self.space.height,0.7*self.space.height)
            self.space.place_agent(a, (x, y))



    def step(self):

        calculate_position()
        look_for_draft()
        set_speeds()
        calculate_energy()
        move()
        update_plot()
        self.schedule.step()



number_cyclists=100

model=Race(number_cyclists,10,10)

positions=[]
peloton_speed=2.0
for cy in model.schedule.agents:
    positions.append(cy.pos)
    cy.speed=peloton_speed
x,y = zip(*positions)
t = np.zeros(number_cyclists)
# print(model.schedule.agents[0].speed)
for i in range(active_cyclists):
    cy=model.schedule.agents[i]
    cy.active=True
    t[i]=1

# print (t)
plt.axhspan(3.,7.,facecolor='0.2',alpha=.1)

plt.scatter(x,y,c=t,marker=">",s=80,cmap=plt.cm.cool)
plt.axis([0,10,0,10])
# plt.colorbar()
plt.show()

for i in range(timesteps):
    model.step()
