extends MovementAI
class_name WaypointMovement

var current_waypoint_index: int = 0
var global_points: Array[Vector2] = []

var _path: Path2D = null
var path: Path2D:
	get:
		return _path
	set(value):
		_path = value
		# Wait until the node is ready to ensure transforms are correct
		if is_inside_tree():
			_update_global_points()
		else:
			# If the node is not ready, defer the update
			call_deferred("_update_global_points")

func _ready():
	# This ensures points are updated if the path was set before the node was ready
	if _path and global_points.is_empty():
		_update_global_points()

func _update_global_points():
	if not _path or not _path.is_inside_tree():
		global_points.clear()
		return

	var baked_points = _path.curve.get_baked_points()
	global_points.resize(baked_points.size())
	for i in baked_points.size():
		# Convert each local point in the path to its absolute global position
		global_points[i] = _path.to_global(baked_points[i])

func move(actor: CharacterBody2D, _delta: float) -> Vector2:
	if global_points.is_empty():
		return Vector2.ZERO
		
	var target_position = global_points[current_waypoint_index]
	
	if actor.global_position.distance_to(target_position) < 10.0:
		current_waypoint_index += 1
		
		if current_waypoint_index >= global_points.size():
			current_waypoint_index = 0
		
		# Update to the next static global point
		target_position = global_points[current_waypoint_index]
			
	var direction = (target_position - actor.global_position).normalized()
	
	return direction * actor.speed
