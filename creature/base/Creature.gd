extends CharacterBody2D

@export var speed: float = 50.0
@onready var animated_sprite: AnimatedSprite2D = $Sprite
@onready var movement_ai = $MovementAI.get_child(0) if $MovementAI.get_child_count() > 0 else null
var last_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	last_direction = directions[randi() % directions.size()]
	if not movement_ai:
		push_warning("Creature is missing a movement AI component under the 'MovementAI' node.")
	animated_sprite.play("idle_" + get_direction_string(last_direction))

func _physics_process(delta: float) -> void:
	if movement_ai:
		var movement_velocity = movement_ai.move(self, delta)
		velocity = movement_velocity
		move_and_slide()
	update_animation()

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
