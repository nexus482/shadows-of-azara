extends Control

@onready var preview_sprite: AnimatedSprite2D = %PreviewSprite
@onready var name_label: Label = %Label

func _ready():
	hide()

func update_preview(target: CharacterBody2D):
	if target:
		var target_sprite = target.get_node_or_null("Sprite") as AnimatedSprite2D
		if target_sprite and target_sprite.sprite_frames.has_animation("idle_down"):
			preview_sprite.sprite_frames = target_sprite.sprite_frames
			preview_sprite.play("idle_down")

		name_label.text = target.name
		show()
	else:
		hide()
