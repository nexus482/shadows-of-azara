extends Node2D

func _ready():
	var ui = $CanvasLayer/TargetPreviewUI
	TargetingManager.register_ui(ui)
