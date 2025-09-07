extends CombatAI
class_name AggressiveCombatAI

const AGGRESSION_RADIUS: float = 150.0

# process_combat is now inherited from CombatAI

func can_engage(actor: CharacterBody2D, player: CharacterBody2D) -> bool:
	return actor.global_position.distance_to(player.global_position) < AGGRESSION_RADIUS
