@tool
extends CharacterBody2D

enum MovementType { NONE, IDLE, RANDOM, WAYPOINT }

@export var speed: float = 50.0

var movement_type: MovementType = MovementType.NONE:
	set(value):
		movement_type = value
		notify_property_list_changed()
		if is_inside_tree() and not Engine.is_editor_hint():
			_setup_movement_ai()

# These properties are now controlled by _get_property_list
var idle_direction: IdleMovement.Direction = IdleMovement.Direction.DOWN
var wander_radius: float = 100.0
var waypoint_path: NodePath

@onready var animated_sprite: AnimatedSprite2D = $Sprite
var movement_ai = null
var last_direction: Vector2 = Vector2.DOWN

var target_indicator: Node2D
var is_hovered = false
var is_selected = false


func _get_property_list():
	var properties = []
	properties.append({
		"name": "movement_type",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "None,Idle,Random,Waypoint"
	})
	
	match movement_type:
		MovementType.IDLE:
			properties.append({
				"name": "idle_direction",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Down,Up,Left,Right" # Matches IdleMovement.Direction enum
			})
		MovementType.RANDOM:
			properties.append({
				"name": "wander_radius",
				"type": TYPE_FLOAT,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "10,500,1" # Min, Max, Step
			})
		MovementType.WAYPOINT:
			properties.append({
				"name": "waypoint_path",
				"type": TYPE_NODE_PATH,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
				"hint_string": "Path2D" # Restricts node picker to Path2D
			})
			
	return properties


func _enter_tree():
	# This runs when the node enters the scene tree, both in the editor and in-game.
	# We only want to set up the AI when the game is running.
	if not Engine.is_editor_hint():
		_setup_movement_ai()


func _ready() -> void:
	add_to_group("creatures")
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	last_direction = directions[randi() % directions.size()]
	
	# The check ensures this doesn't try to instantiate nodes in the editor
	if not Engine.is_editor_hint():
		animated_sprite.play("idle_" + get_direction_string(last_direction))
		target_indicator = preload("res://ui/target/TargetIndicator.tscn").instantiate()
		add_child(target_indicator)
		move_child(target_indicator, 0) # Draw indicator behind sprite
		target_indicator.hide()


func _setup_movement_ai():
	# Clear existing AI
	if movement_ai:
		movement_ai.queue_free()
		movement_ai = null
	for child in $MovementAI.get_children():
		child.queue_free()

	var new_ai_scene = null
	match movement_type:
		MovementType.IDLE:
			new_ai_scene = preload("res://creature/base/components/movement/idle/Idle.tscn")
		MovementType.RANDOM:
			new_ai_scene = preload("res://creature/base/components/movement/random/Random.tscn")
		MovementType.WAYPOINT:
			new_ai_scene = preload("res://creature/base/components/movement/waypoint/Waypoint.tscn")

	if new_ai_scene:
		movement_ai = new_ai_scene.instantiate()
		$MovementAI.add_child(movement_ai)

		match movement_type:
			MovementType.IDLE:
				movement_ai.direction = idle_direction
			MovementType.RANDOM:
				movement_ai.wander_radius = wander_radius
			MovementType.WAYPOINT:
				var waypoint_node = get_node_or_null(waypoint_path)
				if waypoint_node is Path2D:
					movement_ai.path = waypoint_node
				else:
					push_warning("Waypoint path is not a Path2D node or is not set for this creature.")


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return # Don't run physics in the editor
		
	if movement_ai:
		var movement_velocity = movement_ai.move(self, delta)
		velocity = movement_velocity
		move_and_slide()
	update_animation()

func is_pixel_opaque(screen_position: Vector2) -> bool:
	var frame_texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	if not frame_texture:
		return false

	var image = frame_texture.get_image()
	var local_pos = animated_sprite.to_local(screen_position)
	local_pos += image.get_size() / 2.0

	var rect = Rect2(Vector2.ZERO, image.get_size())
	if not rect.has_point(local_pos):
		return false

	return image.get_pixelv(local_pos).a > 0.1

func on_hover_enter():
	is_hovered = true
	_update_highlight()

func on_hover_exit():
	is_hovered = false
	_update_highlight()

func select():
	is_selected = true
	target_indicator.show()
	_update_highlight()

func deselect():
	is_selected = false
	target_indicator.hide()
	_update_highlight()

func _update_highlight():
	if is_selected:
		animated_sprite.modulate = Color(1, 1, 1)
	elif is_hovered:
		animated_sprite.modulate = Color(1.2, 1.2, 1.2)
	else:
		animated_sprite.modulate = Color(1, 1, 1)

func update_animation() -> void:
	var current_animation: String
	var direction = last_direction

	if velocity.length() > 1.0:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				direction = Vector2.RIGHT
			else:
				direction = Vector2.LEFT
		else:
			if velocity.y > 0:
				direction = Vector2.DOWN
			else:
				direction = Vector2.UP
		current_animation = "walk_" + get_direction_string(direction)
	else:
		current_animation = "idle_" + get_direction_string(last_direction)

	last_direction = direction

	if animated_sprite.animation != current_animation:
		animated_sprite.play(current_animation)

func get_direction_string(direction: Vector2) -> String:
	if direction == Vector2.RIGHT:
		return "right"
	elif direction == Vector2.LEFT:
		return "left"
	elif direction == Vector2.UP:
		return "up"
	else:
		return "down"

func set_movement_ai(new_ai_instance: Node) -> void:
	if movement_ai:
		movement_ai.queue_free()
	movement_ai = new_ai_instance
	$MovementAI.add_child(movement_ai)
