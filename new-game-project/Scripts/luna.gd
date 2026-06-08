extends CharacterBody2D

#STATS----

var speed = 300
var max_mana = 10.0
var current_mana = 10.0
var hit = false
var ice_scene = preload("res://scenes/ice_shard.tscn")
var shoot_cooldown = 0.5
var shoot_timer = 0.0
var luna_idle = preload("res://assets/sprites/Luna.png")
var luna_walk = preload("res://assets/sprites/Luna2.png")
var medusa_unlocked = false
var medusa_timer = 0.0
var medusa_cooldown = 3.0
var medusa_scene = preload("res://scenes/Medusa.tscn")
var boss_luna = preload("res://assets/sprites/Luna_Boss.png")
#STEALTH-----

var is_stealthed = false
var stealth_duration = 4.0
var stealth_timer = 0.0

#DASH----

var is_dashing = false
var dash_speed = 1500
var dash_duration = 0.15
var dash_timer = 0.0
var dash_direction = Vector2.ZERO
var dash_no_enemy_distance = 150.0
var dash_detect_radius = 200.0

#TELEPORT----

var teleport_mode = false

#MANA COSTS-----

const DASH_COST = 3
const STEALTH_COST = 3
const TELEPORT_COST = 5

func _physics_process(delta: float) -> void:
	if not is_instance_valid(GameManager):
		return
	if get_tree().paused:
		return
	if medusa_unlocked:
		medusa_timer -= delta
		if medusa_timer <= 0.0:
			launch_medusa()
			medusa_timer = medusa_cooldown
	
	current_mana = GameManager.mana
	if not is_dashing:
		if Input.is_action_just_pressed("dash") and current_mana >= DASH_COST:
			use_dash()
		if Input.is_action_just_pressed("stealth") and current_mana >= STEALTH_COST:
			use_stealth()
		if Input.is_action_just_pressed("teleport") and current_mana >= TELEPORT_COST:
			use_teleport()
	
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * dash_speed
		move_and_slide()
		position.x = clamp(position.x , 150, 1230)
		position.y = clamp(position.y, 50, 680)
		if dash_timer <= 0.0:
			is_dashing = false
			velocity = Vector2.ZERO
		return
	if GameManager.teleport_active:
		return
	var direction = Vector2.ZERO
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1 
	shoot_timer -= delta
	if Input.is_action_just_pressed("shoot") and shoot_timer <= 0.0:
		shoot()
		shoot_timer = shoot_cooldown
	direction = direction.normalized()
	
	velocity = direction * speed
	move_and_slide()
	
	if is_stealthed:
		stealth_timer -= delta
		modulate.a = 0.3
		if stealth_timer <= 0.0:
			is_stealthed = false
			modulate.a = 1.0
	#Animation ----
	if direction == Vector2.ZERO :
		%AnimationPlayer.play("idle")
	elif direction != Vector2.ZERO :
		%AnimationPlayer.play("walk")
	
	#Sprite Swap ----
	if medusa_unlocked:
		%Sprite2D.texture = boss_luna
	elif  direction == Vector2.ZERO:
		%Sprite2D.texture = luna_idle
	else:
		%Sprite2D.texture = luna_walk
	
	position.x = clamp(position.x, 150, 1230)
	position.y = clamp(position.y, 50, 680)
# Flip Sprite ---
	if direction.x < 0:
		%Sprite2D.flip_h = true
	elif direction.x > 0:
		%Sprite2D.flip_h = false

#DASH---

func use_dash() -> void:
	var nearest = get_nearest_enemy()
	if nearest:
		dash_direction = (nearest.global_position - global_position).normalized()
		nearest.queue_free()
		GameManager.enemy_killed()
	else:
		var dir = Vector2.ZERO
		if Input.is_action_pressed("ui_right"): dir.x += 1
		if Input.is_action_pressed("ui_left"): dir.x -= 1
		if Input.is_action_pressed("ui_up"): dir.y -= 1
		if Input.is_action_pressed("ui_down"): dir.y += 1
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT if not %Sprite2D.flip_h else Vector2.LEFT
		dash_direction = dir.normalized()
	current_mana -= DASH_COST
	print(current_mana)
	is_dashing = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.5, 0.8, 2.0), 0.05)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), dash_duration)
	dash_timer = dash_duration
	GameManager.update_mana(current_mana)


func get_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest = null
	var nearest_dist = dash_detect_radius
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if enemy.name == "Boss":
			return
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest

#STEALTH---

func use_stealth() -> void:
	is_stealthed = true
	stealth_timer = stealth_duration
	current_mana -= STEALTH_COST
	GameManager.update_mana(current_mana)


func use_teleport() -> void:
	current_mana -= TELEPORT_COST
	GameManager.update_mana(current_mana)
	get_tree().paused = true
	GameManager.show_teleport_cursor()


func teleport_to(target_pos: Vector2) -> void:
	global_position = target_pos
	get_tree().paused = false






func play_hit():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.5, 0.2, 0.2), 0.1)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.2)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	print("area name:", area.name)
	if area.is_in_group("enemy_hit"):
		play_hit()


func shoot() -> void:
	var ice_shard = ice_scene.instantiate()
	ice_shard.direction = (get_global_mouse_position() - global_position ).normalized()
	ice_shard.global_position = global_position
	get_tree().current_scene.add_child(ice_shard)
	


func launch_medusa() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	var target = null
	var nearest_dist = 9999.0
	for enemy in enemies:
		if enemy.name == "Boss":
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			target = enemy
	if not target:
		return
	var proj = medusa_scene.instantiate()
	proj.global_position = global_position
	proj.direction = (target.global_position - global_position).normalized()
	proj.is_medusa = true
	%Sprite2D.texture = boss_luna
	get_tree().current_scene.add_child(proj)
	
