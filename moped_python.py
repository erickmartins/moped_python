class turtle(object):

    def __init__(self):
        self.neighborhood=[]
        self.speed=0.0
        self.draft_coefficient=0.0
        self.energy_left=0.0
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

t1=turtle()
print t1.get_x_acc()
print t1.get_neighborhood()
t2=turtle()
t1.set_neighbor(t2)
print t1.get_neighborhood()[0]
