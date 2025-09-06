extends MovementAI
class_name IdleMovement

@export_enum("Left", "Right", "Up", "Down") var start_direction: String = "Down"

func _ready() -> void:
	if not start_direction in ["Left", "Right", "Up", "Down"]:
		push_warning("Invalid start_direction '%s' in IdleMovement. Defaulting to 'Down'." % start_direction)
		start_direction = "Down"

func move(actor: CharacterBody2D, _delta: float) -> Vector2:
	match start_direction:
		"Left":
			actor.last_direction = Vector2.LEFT
		"Right":
			actor.last_direction = Vector2.RIGHT
		"Up":
			actor.last_direction = Vector2.UP
		"Down":
			actor.last_direction = Vector2.DOWN
	return Vector2.ZERO
