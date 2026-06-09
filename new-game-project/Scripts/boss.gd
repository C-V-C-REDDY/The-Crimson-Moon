extends CharacterBody2D

var health = 300.0
var max_health = 150.0
var slash_count = 5
var slash_delay = 0.3
var is_summoned = true
var slash_scene = preload("res://scenes/slash.tscn")

func _ready() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05),1.0 )
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 1.0)
	%wait_timer.timeout.connect(launch_slash_storm)

func launch_slash_storm() -> void:
	Audio.play_boss_laugh()
	for i in slash_count:
		await get_tree().create_timer(slash_delay).timeout
		launch_slash()

func launch_slash() -> void:
	%Boss_sprite.play("slash")
	var luna = get_tree().get_first_node_in_group("luna")
	if not luna:
		return
	var slash = slash_scene.instantiate()
	slash.global_position = global_position
	var base_dir = (luna.global_position - global_position).normalized()
	var spread = randf_range(-0.3, 0.3)
	slash.direction = base_dir.rotated(spread)
	get_tree().current_scene.add_child(slash)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(2.0, 0.3, 0.3), 0.1)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.2)



func take_damage(amount) -> void:
	health -= amount
	Audio.play_enemy_hurt()
	%HealthBar.value = health
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(2.0, 2.0, 2.0), 1.0)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 1.0)
	if health <= 0:
		die()


func die() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.3)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.3)
	await get_tree().create_timer(0.7). timeout
	GameManager.boss_defeated()
	queue_free()
