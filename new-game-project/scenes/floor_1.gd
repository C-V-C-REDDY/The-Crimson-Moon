extends Node

func _ready() -> void:
	%AnimatedSprite2D2.play("fire2")
	%AnimatedSprite2D3.play("fire2")
	%AnimatedSprite2D4.play("light")
	%AnimationPlayer.play("new_animation")
	%DoorAnimation.play("Door")
	
	#var floor_num = GameManager.current_floor
	#%Moon.texture = GameManager.moon_textures[floor_num - 1]
