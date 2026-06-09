extends CharacterBody2D

var speed = 40.0
var damage = 5.0
var summon_cooldown = 8.0
var summon_timer = 5.0
var summon_limit = 3
var summoned_count = 0
var is_visible_hit = false
var enemy_scenes = [
	preload("res://scenes/mage.tscn"),
	preload("res://scenes/Melle.tscn"),
	preload("res://scenes/ninja.tscn")
]
var health = 30.0
var is_freeze = false


func _ready() -> void:
	modulate.a = 0.5
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.48, 0.48), 0.9)
	tween.tween_property(self, "scale", Vector2(0.40, 0.40), 0.9)


func _physics_process(delta: float) -> void:
	var luna = get_tree().get_first_node_in_group("luna")
	if not luna:
		return
	if is_freeze:
		return
	
	var dist = global_position.distance_to(luna.global_position)
	var direction = (luna.global_position - global_position).normalized()
	if luna.is_stealthed:
		%Label.visible = true
		return
	else:
		%Label.visible = false
	if GameManager.teleport_active:
		return
	if dist < 250.0:
		velocity = -direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	if direction.x < 0:
		%Sprite2D.flip_h = true
	else:
		%Sprite2D.flip_h = false
	
	#Summon Timer ----
	if summoned_count < summon_limit:
		summon_timer -= delta
		if summon_timer <= 0.0:
			summon_enemy()
			summon_timer = summon_cooldown


func summon_enemy() -> void:
	if enemy_scenes.is_empty():
		return
	var random_scene = enemy_scenes[randi() % enemy_scenes.size()]
	GameManager.spawn_summoned_enemy(random_scene)
	var enemy = random_scene.instantiate()
	enemy.global_position = global_position + Vector2(randf_range(-80, 80), randf_range(-80 , 80))
	enemy.modulate.a = 0.5
	enemy.is_summoned = true
	get_tree().current_scene.add_child(enemy)
	summoned_count += 1
	enemy.tree_exited.connect(func(): summoned_count -= 1)



func take_damage(amount: float) -> void:
	Audio.play_enemy_hurt()
	health -= amount
	%ProgressBar.value = health
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.16, 0.0, 0.0, 1.0), 0.1)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.1)
	if health <= 0:
		Audio.play_enemy_die()
		GameManager.kill_count += 1
		%AnimationPlayer.play("die")
		await get_tree().create_timer(0.3).timeout
		queue_free()
		GameManager.enemy_killed()


func freeze() -> void:
	is_freeze = true
	modulate = Color(0.0, 0.0, 2.0, 1.0)
	await get_tree().create_timer(3.0).timeout
	modulate = Color(1.0, 1.0, 1.0)
	is_freeze = false
