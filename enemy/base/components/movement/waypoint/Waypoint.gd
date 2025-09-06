extends MovementAI
class_name WaypointMovement

var current_waypoint_index: int = 0
@onready var path: Path2D = $Path

func move(actor: CharacterBody2D, delta: float) -> Vector2:
	if not path:
		push_warning("WaypointMovement component is missing its child Path2D node.")
		return Vector2.ZERO

	var points = path.curve.get_baked_points()
	
	if points.is_empty():
		return Vector2.ZERO
		
	var target_position = path.global_position + points[current_waypoint_index]
	
	if actor.global_position.distance_to(target_position) < 5:
		current_waypoint_index += 1
		
		if current_waypoint_index >= points.size():
			current_waypoint_index = 0
			
	var direction = (target_position - actor.global_position).normalized()
	
	return direction * actor.speed
