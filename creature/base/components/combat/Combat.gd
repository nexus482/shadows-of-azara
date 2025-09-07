class_name CombatAI
extends Node

const MELEE_RANGE: float = 30.0

var combat_target = null
var time_in_combat = 0.0

func _enter_combat(target):
	combat_target = target
	time_in_combat = 0.0

func _exit_combat():
	combat_target = null
	time_in_combat = 0.0

func process_combat(actor: CharacterBody2D, delta: float) -> Vector2:
	if not combat_target:
		return Vector2.ZERO

	time_in_combat += delta
	
	var vector_to_target = combat_target.global_position - actor.global_position
	var distance_to_target = vector_to_target.length()

	# Only move if we are outside of melee range
	if distance_to_target > MELEE_RANGE:
		return vector_to_target.normalized() * actor.speed
	else:
		# Stop moving when in range
		return Vector2.ZERO

func can_engage(_actor: CharacterBody2D, _player: CharacterBody2D) -> bool:
	return false
