extends CharacterBody2D

@export var speed: float = 50.0
@onready var animated_sprite: AnimatedSprite2D = $Sprite
@onready var movement_ai = $MovementAI.get_child(0) if $MovementAI.get_child_count() > 0 else null
var last_direction: Vector2 = Vector2.DOWN

var target_indicator: Node2D
var is_hovered = false
var is_selected = false

func _ready() -> void:
	add_to_group("creatures")
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	last_direction = directions[randi() % directions.size()]
	if not movement_ai:
		push_warning("Creature is missing a movement AI component under the 'MovementAI' node.")
	animated_sprite.play("idle_" + get_direction_string(last_direction))

	target_indicator = preload("res://ui/target/TargetIndicator.tscn").instantiate()
	add_child(target_indicator)
	move_child(target_indicator, 0) # Draw indicator behind sprite
	target_indicator.hide()

func _physics_process(delta: float) -> void:
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
	# If selected, the circle is the main indicator, so we use normal color.
	# Otherwise, apply the hover effect if needed.
	if is_selected:
		animated_sprite.modulate = Color(1, 1, 1)
	elif is_hovered:
		animated_sprite.modulate = Color(1.2, 1.2, 1.2) # Slightly bright for hovered
	else:
		animated_sprite.modulate = Color(1, 1, 1) # Normal color

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
