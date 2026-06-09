extends CharacterBody2D


var speed = 75.0
var damage = 5.0
var shoot_cooldown = 2.0
var shoot_timer = 0.0
var shoot_range = 300.0
var health = 30.0
var is_summoned = false
var orb_scene = preload("res://scenes/orb.tscn")
var is_freeze = false


func _ready() -> void:
	# Breathe
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(0.38, 0.38), 0.9)
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.9)


func _physics_process(_delta: float) -> void:
	if is_freeze:
		return
	var luna = get_tree().get_first_node_in_group("luna")
	if not luna:
		return
	var direction = (luna.global_position - global_position).normalized()
	var dist = global_position.distance_to(luna.global_position)
	if luna.is_stealthed:
		%Label.visible = true
		return
	else:
		%Label.visible = false
	if GameManager.teleport_active:
		return
	# chase luna till shooting range
	if dist > shoot_range:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		shoot_timer -= _delta
		if shoot_timer <= 0.0:
			shoot(direction)
			shoot_timer = shoot_cooldown
	move_and_slide()
	
	if direction.x <= 0:
		%Mage.flip_h = true
	else:
		%Mage.flip_h = false


func shoot(direction: Vector2) -> void:
	var orb = orb_scene.instantiate()
	orb.direction = direction
	orb.global_position = global_position
	get_tree().current_scene.add_child(orb)


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("luna"):
		GameManager.current_health -= damage
		get_tree().get_first_node_in_group("luna").play_hit()


func take_damage(amount: float) -> void:
	health -= amount
	Audio.play_enemy_hurt()
	%ProgressBar.value = health
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.16, 0.0, 0.0, 1.0), 0.1)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.1)
	if health <= 0:
		Audio.play_enemy_die()
		GameManager.kill_count += 1
		%AnimationPlayer.play("die")
		await get_tree().create_timer(0.3).timeout
		if not is_summoned:
			GameManager.enemy_killed()
		queue_free()


func freeze() -> void:
	is_freeze = true
	modulate = Color(0.0, 0.0, 2.0, 1.0)
	await get_tree().create_timer(3.0).timeout
	modulate = Color(1.0, 1.0, 1.0)
	is_freeze = false
