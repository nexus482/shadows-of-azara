extends MovementAI
class_name IdleMovement

# A proper enum for directions
enum Direction { DOWN, UP, LEFT, RIGHT }

# This will be set by the Creature script
var direction: Direction = Direction.DOWN

func move(actor: CharacterBody2D, _delta: float) -> Vector2:
	match direction:
		Direction.LEFT:
			actor.last_direction = Vector2.LEFT
		Direction.RIGHT:
			actor.last_direction = Vector2.RIGHT
		Direction.UP:
			actor.last_direction = Vector2.UP
		Direction.DOWN:
			actor.last_direction = Vector2.DOWN
	return Vector2.ZERO
