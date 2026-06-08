extends Node

func _ready() -> void:
	%AnimationPlayer.play("idle")


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
