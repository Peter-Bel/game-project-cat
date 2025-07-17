extends Node2D

@export var screen_size: Vector2 = Vector2(640.0, 360.0)
@export var base_y_position: float = 290.0

const POINT_COUNT: int = 64
const RESTORE_FORCE: float = 50.0
const DAMPING: float = 0.98 
const SPREAD: float = 0.1

var line_node: Line2D
var polygon_node: Polygon2D

var water_points_y_position: Array = []
var water_points_velocity: Array = []

var bodies_in_water: Array = []

func _ready() -> void:
	line_node = $Line2D
	polygon_node = $Polygon2D
	
	# set CollisionShape
	var shape = RectangleShape2D.new()
	shape.size = Vector2(screen_size.x, screen_size.y - base_y_position)
	$Area2D/CollisionShape2D.shape = shape
	$Area2D.position = Vector2(screen_size.x / 2, base_y_position + (screen_size.y - base_y_position) / 2)
	
	for i in range(POINT_COUNT):
		water_points_y_position.append(base_y_position)
		water_points_velocity.append(0)
		
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	

func _process(delta: float) -> void:
	apply_points_physics(delta)
	draw_water()

func draw_water() -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var segment_width: float = screen_size.x / (POINT_COUNT - 1)
	
	for i in range(POINT_COUNT):
		points.append(Vector2(i * segment_width, water_points_y_position[i]))
		
	line_node.points = points
	line_node.width = 2.0
	line_node.default_color = Color(0, 0.5, 1, 1)
	
	var polygon_points = points.duplicate()
	for i in range(POINT_COUNT - 1, -1, -1):
		polygon_points.append(Vector2(i * segment_width, screen_size.y))
		
	polygon_node.polygon = polygon_points
	polygon_node.color = Color(0, 1, 1, 0.25)

################################################################################
func get_closest_point_index(x_position_value: float) -> int:
	var segment_width: float = screen_size.x / (POINT_COUNT - 1)
	return round(x_position_value / segment_width)

func get_point_y_position(index_value: int) -> float:
	return water_points_y_position[index_value]

func splash_point(index_value: int, force_value: float) -> void:
	# degree of water wave depends on force value
	force_value = min(force_value, 200)
	water_points_velocity[index_value] += force_value
	print("Splash at index:", index_value, "with velocity:", force_value)
	
	if index_value > 2:
		water_points_velocity[index_value - 1] += force_value * 0.75
		water_points_velocity[index_value - 2] += force_value * 0.5
		water_points_velocity[index_value - 3] += force_value * 0.5
	if index_value < POINT_COUNT - 3:
		water_points_velocity[index_value + 1] += force_value * 0.75
		water_points_velocity[index_value + 2] += force_value * 0.5
		water_points_velocity[index_value + 3] += force_value * 0.5
	
func apply_points_physics(delta) -> void:
	for i in range(POINT_COUNT):
		water_points_y_position[i] += water_points_velocity[i] * delta
		
		var force = (base_y_position - water_points_y_position[i]) * RESTORE_FORCE
		water_points_velocity[i] += force * delta
		water_points_velocity[i] *= DAMPING
	
	var new_positions: Array = water_points_y_position.duplicate()
	for i in range(1, POINT_COUNT - 1):
		new_positions[i] += (water_points_y_position[i - 1] - water_points_y_position[i]) * SPREAD
		new_positions[i] += (water_points_y_position[i + 1] - water_points_y_position[i]) * SPREAD
		
	for i in range(1, POINT_COUNT - 1):
		water_points_y_position[i] = new_positions[i]
		
		
###################################################################################################
#func _on_area_2d_body_entered(body: Node2D) -> void:
			
func _on_body_entered(body: Node) -> void:
	print("Entered:", body.name)
	if body is CharacterBody2D or body is RigidBody2D:
		bodies_in_water.append(body)


func _on_body_exited(body: Node) -> void:
	bodies_in_water.erase(body)

func _physics_process(delta: float) -> void:
	for body in bodies_in_water:
		var index = get_closest_point_index(body.global_position.x)
		var velocity_y = 0.0
		
		if body is CharacterBody2D:
			velocity_y = body.velocity.y
		elif body is RigidBody2D:
			velocity_y = body.linear_velocity.y
		
		if abs(velocity_y) > 10.0:
			splash_point(index, velocity_y)
