extends Node

var current_target: Node2D = null
var target_preview_ui = null

func register_ui(ui_node):
	target_preview_ui = ui_node

func set_target(target: Node2D):
	if current_target == target:
		return

	if current_target:
		current_target.deselect()
	current_target = target
	if current_target:
		current_target.select()

	if target_preview_ui:
		target_preview_ui.update_preview(current_target)
