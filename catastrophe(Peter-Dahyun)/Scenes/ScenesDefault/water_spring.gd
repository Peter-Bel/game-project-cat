extends Node2D

# the spring's current velocity
var velocity = 0

# the force being applied to the spring
var force = 0

#the current height of the spring
var height = position.y

# the natural position of the sping
var target_height = position.y + 80

# the spring stiffness constant
var k = 0.015

# the spring dampening value
# how fast the spirng will stop
var damp = 0.03

func water_update(spring_constant, dampening):
	## this function applies the hooke's law force to the spring
	## this function will be called in each frame
	
	# update the height value based on our current position
	height = position.y
	
	# the spring current extension
	var x = height - target_height
	
	var loss = -dampening * velocity
	
	# hooke's law:
	force = - spring_constant * x + loss
	
	# apply the force to the velocity
	# equivalent to velocity = velocity + force
	velocity += force
	
	# make the spring move
	position.y += velocity
	pass

func _physics_process(delta):
	water_update(k, damp)
