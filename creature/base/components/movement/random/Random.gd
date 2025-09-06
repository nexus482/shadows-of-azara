extends MovementAI
class_name RandomMovement

var wander_radius: float = 100.0 # No longer exported
@export var pause_duration_min: float = 2.0
@export var pause_duration_max: float = 3.0

var start_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var pause_timer: float = 0.0
var pause_duration: float = 0.0

enum State { MOVING, PAUSED }
var state: State = State.PAUSED


func _ready() -> void:
	var actor = get_parent().get_parent() as CharacterBody2D
	if actor:
		start_position = actor.global_position
		target_position = start_position
	else:
		push_error("RandomMovement's grandparent must be a CharacterBody2D.")
	
	# Start in a paused state for more predictable behavior
	state = State.PAUSED
	pause_duration = randf_range(pause_duration_min, pause_duration_max)
	pause_timer = 0.0


func move(actor: CharacterBody2D, delta: float) -> Vector2:
	if state == State.PAUSED:
		pause_timer += delta
		if pause_timer >= pause_duration:
			state = State.MOVING
			pause_timer = 0.0
			var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			var random_distance = randf_range(0, wander_radius)
			target_position = start_position + random_direction * random_distance
		return Vector2.ZERO
	
	if state == State.MOVING:
		if actor.global_position.distance_to(target_position) < 5:
			state = State.PAUSED
			pause_duration = randf_range(pause_duration_min, pause_duration_max)
			pause_timer = 0.0
			return Vector2.ZERO
		
		var direction = (target_position - actor.global_position).normalized()
		return direction * actor.speed
	
	return Vector2.ZERO
