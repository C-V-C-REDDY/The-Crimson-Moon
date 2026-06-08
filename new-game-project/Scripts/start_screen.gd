extends Node2D

func _ready() -> void:
	%AnimationPlayer.play("idle")


func _on_start_bt_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_codex_bt_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/codex.tscn")


func _on_info_bt_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/info.tscn")
