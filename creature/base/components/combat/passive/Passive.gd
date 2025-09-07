extends CombatAI
class_name PassiveCombatAI

func process_combat(_actor: CharacterBody2D, _delta: float) -> Vector2:
	# Passive creatures do not fight.
	return Vector2.ZERO

func can_engage(_actor: CharacterBody2D, _player: CharacterBody2D) -> bool:
	return false
