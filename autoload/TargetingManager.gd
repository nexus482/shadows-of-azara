extends Node

var current_target: Node2D = null

func set_target(target: Node2D):
	if current_target:
		current_target.deselect()
	current_target = target
	if current_target:
		current_target.select()
