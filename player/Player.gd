extends CharacterBody2D

@export var speed = 200.0
@onready var anim = $Sprite
@onready var camera = $Camera

func _physics_process(delta):
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")
	input_dir = input_dir.normalized()

	velocity = input_dir * speed
	move_and_slide()

	if velocity.length() > 0:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				anim.play("walk_right")
			else:
				anim.play("walk_left")
		else:
			if velocity.y > 0:
				anim.play("walk_down")
			else:
				anim.play("walk_up")
	else:
		if anim.animation.begins_with("walk"):
			anim.play(anim.animation.replace("walk", "idle"))
