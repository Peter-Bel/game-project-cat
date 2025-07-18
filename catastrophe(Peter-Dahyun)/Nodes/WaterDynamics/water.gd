extends Node2D

# water size can be changed, if @export var get changed  
@export var water_width: float = 640.0
@export var water_height: float = 70.0
@export var base_y_position: float = 310.0
@export var point_count: int = 64

const RESTORE_FORCE: float = 50.0
const DAMPING: float = 0.98 
const SPREAD: float = 0.1

var line_node: Line2D
var polygon_node: Polygon2D

var water_points_y_position: Array = []
var water_points_velocity: Array = []

var bodies_in_water: Array = []
var splash_cooldown := {}

######################################################################################
func _ready() -> void:
	line_node = $Line2D
	polygon_node = $Polygon2D
	
	# set CollisionShape
	var shape = RectangleShape2D.new()
	shape.size = Vector2(water_width, water_height)
	$Area2D/CollisionShape2D.shape = shape
	$Area2D.position = Vector2(water_width / 2, base_y_position + water_height / 2)
	
	for i in range(point_count):
		water_points_y_position.append(base_y_position)
		water_points_velocity.append(0)
		
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	
###############################################################################
func _process(delta: float) -> void:
	apply_points_physics(delta)
	draw_water()
##################################################################################
func draw_water() -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var segment_width: float = water_width / (point_count - 1)
	
	for i in range(point_count):
		points.append(Vector2(i * segment_width, water_points_y_position[i]))
		
	line_node.points = points
	line_node.width = 2.0
	# water surface color
	line_node.default_color = Color(0, 0.5, 1, 1)
	
	var polygon_points = points.duplicate()
	for i in range(point_count - 1, -1, -1):
		polygon_points.append(Vector2(i * segment_width, base_y_position + water_height))
		
	polygon_node.polygon = polygon_points
	polygon_node.color = Color(0, 1, 1, 0.25)

################################################################################
func get_closest_point_index(x_position_value: float) -> int:
	var local_x = to_local(Vector2(x_position_value, 0)).x
	var segment_width: float = water_width / (point_count - 1)
	return clamp(round(local_x / segment_width), 0, point_count - 1)

func get_point_y_position(index_value: int) -> float:
	return water_points_y_position[index_value]

###############################################################################
func splash_point(index_value: int, force_value: float) -> void:
	# degree of water wave depends on force value
	force_value = min(force_value, 200)
	water_points_velocity[index_value] += force_value
	#print("Splash at index:", index_value, "with velocity:", force_value)
	
	if index_value > 2:
		water_points_velocity[index_value - 1] += force_value * 0.75
		water_points_velocity[index_value - 2] += force_value * 0.5
		water_points_velocity[index_value - 3] += force_value * 0.5
	if index_value < point_count - 3:
		water_points_velocity[index_value + 1] += force_value * 0.75
		water_points_velocity[index_value + 2] += force_value * 0.5
		water_points_velocity[index_value + 3] += force_value * 0.5
	
###################################################################################
func apply_points_physics(delta) -> void:
	for i in range(point_count):
		water_points_y_position[i] += water_points_velocity[i] * delta
		
		var force = (base_y_position - water_points_y_position[i]) * RESTORE_FORCE
		water_points_velocity[i] += force * delta
		water_points_velocity[i] *= DAMPING
	
	var new_positions: Array = water_points_y_position.duplicate()
	for i in range(1, point_count - 1):
		new_positions[i] += (water_points_y_position[i - 1] - water_points_y_position[i]) * SPREAD
		new_positions[i] += (water_points_y_position[i + 1] - water_points_y_position[i]) * SPREAD
		
	for i in range(1, point_count - 1):
		water_points_y_position[i] = new_positions[i]
		
		
###################################################################################################
#func _on_area_2d_body_entered(body: Node2D) -> void:
			
func _on_body_entered(body: Node) -> void:
	# print("Entered:", body.name)
	if body is CharacterBody2D or body is RigidBody2D:
		bodies_in_water.append(body)
		

func _on_body_exited(body: Node) -> void:
	bodies_in_water.erase(body)

###############################################################################
func _physics_process(delta: float) -> void:
	for body in bodies_in_water:
		var id = body.get_instance_id()
		if splash_cooldown.has(id):
			splash_cooldown[id] -= delta
			if splash_cooldown[id] > 0:
				continue

		var index = get_closest_point_index(body.global_position.x)
		var velocity_y = 0.0
		var velocity_x = 0.0
		
		if body is CharacterBody2D:
			velocity_y = body.velocity.y
			velocity_x = body.velocity.x
		elif body is RigidBody2D:
			velocity_y = body.linear_velocity.y
			velocity_x = body.linear_damp.x

		if abs(velocity_y) > 10.0 or abs(velocity_x) > 60.0 :
			splash_point(index, velocity_y * 0.7 + velocity_x * 0.3)
			# The more number of splash_cooldown, The less water wave frequency
			splash_cooldown[id] = 0.5 
		
