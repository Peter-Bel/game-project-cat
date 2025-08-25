extends Node
class_name Health

# signal
signal health_zero

# variables
@export var max_health: int = 5 : set = set_max_health, get = get_max_health
@onready var health: int = max_health : set = set_health, get = get_health
@export var imortal: bool = false : set = set_imortal, get = get_imortal
var imortal_time: Timer = null


# max health funcitons
func set_max_health(val: int):
	max_health = val

func get_max_health() -> int: 
	return max_health


# imortal functions
func set_imortal(val: bool):
	imortal = val

func get_imortal() -> bool: 
	return imortal

func set_imortal_time(time: float):
	if imortal_time == null:
		imortal_time = Timer.new()
		imortal_time.one_shot = true
		add_child(imortal_time)
	if (imortal_time.timeout.is_connected(set_imortal)):
		imortal_time.timeout.disconnect(set_imortal)
	
	imortal_time.set_wait_time(time)
	imortal_time.timeout.connect(set_imortal.bind(false))
	imortal = true
	imortal_time.start()


# health functions
func set_health(val: int):
	val = clamp(val, 0, max_health)
	health = val
	if (health == 0):
		health_zero.emit()
	print(health)

func get_health() -> int: 
	return health
