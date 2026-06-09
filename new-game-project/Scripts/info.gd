extends Node

func _ready() -> void:
	%AnimationPlayer.play("idle")
	%TextureRect5.play("default")
	%TextureRect6.play("default")




func _on_texture_button_pressed() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
