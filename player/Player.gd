extends CharacterBody2D

@export var speed = 200.0
@export var tab_target_range: float = 250.0
@onready var anim = $Sprite
@onready var camera = $Camera

var hovered_creature = null
var last_direction = Vector2.DOWN

func _physics_process(delta):
	handle_movement(delta)
	handle_hover()
	handle_actions()

func handle_movement(_delta):
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")

	if input_dir != Vector2.ZERO:
		last_direction = input_dir.normalized()

	velocity = input_dir.normalized() * speed
	move_and_slide()

	# Animation Logic
	if velocity.length() > 0:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				anim.play("walk_right")
			else:
				anim.play("walk_left")
		else:
			if velocity.y > 0:
				anim.play("walk_down")
			else:
				anim.play("walk_up")
	else:
		if anim.animation.begins_with("walk"):
			anim.play(anim.animation.replace("walk", "idle"))

func handle_hover():
	var mouse_pos = get_global_mouse_position()
	var creatures = get_tree().get_nodes_in_group("creatures")
	creatures.reverse()

	var creature_under_mouse = null
	for creature in creatures:
		if creature.is_pixel_opaque(mouse_pos):
			creature_under_mouse = creature
			break

	if creature_under_mouse != hovered_creature:
		if hovered_creature:
			hovered_creature.on_hover_exit()
		if creature_under_mouse:
			creature_under_mouse.on_hover_enter()

		hovered_creature = creature_under_mouse

		if hovered_creature:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func handle_actions():
	if Input.is_action_just_pressed("tab_target"):
		find_and_set_tab_target()
	if Input.is_action_just_pressed("clear_target"):
		TargetingManager.set_target(null)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		TargetingManager.set_target(hovered_creature)

func find_and_set_tab_target():
	var all_creatures = get_tree().get_nodes_in_group("creatures")
	var valid_targets = []
	var range_squared = tab_target_range * tab_target_range

	for creature in all_creatures:
		# Check if the creature is within range
		if global_position.distance_squared_to(creature.global_position) > range_squared:
			continue

		valid_targets.append(creature)

	if valid_targets.is_empty():
		TargetingManager.set_target(null)
		return

	# Sort valid targets by distance to the player
	valid_targets.sort_custom(func(a, b):
		return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
	)
	
	var current_target = TargetingManager.current_target
	var current_target_index = -1
	if current_target in valid_targets:
		current_target_index = valid_targets.find(current_target)
	
	var next_target_index = 0
	if current_target_index != -1:
		next_target_index = (current_target_index + 1) % valid_targets.size()

	TargetingManager.set_target(valid_targets[next_target_index])
