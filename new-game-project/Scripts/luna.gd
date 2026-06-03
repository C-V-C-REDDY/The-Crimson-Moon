extends CharacterBody2D

#STATS----

var speed = 300
var max_mana = 10.0
var current_mana = 0
var hit = false
#STEALTH-----

var is_stealthed = false
var stealth_duration = 4.0
var stealth_timer = 0.0

#DASH----

var is_dashing = false
var dash_speed = 1200
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
	
	if not is_dashing:
		if Input.is_action_just_pressed("dash") and current_mana >= DASH_COST:
			use_dash()
		if Input.is_action_just_pressed("stealth") and current_mana >= STEALTH_COST:
			use_stealth()
		if Input.is_action_just_pressed("teleport") and current_mana >= TELEPORT_COST:
			use_teleport()
	
	#Stealth -----
	if is_stealthed:
		stealth_timer -= delta
		modulate.a = 0.3
		if stealth_timer <= 0.0:
			is_stealthed = false
			modulate.a = 1.0
	
	#Dash ----
	
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * dash_speed
		move_and_slide()
		if dash_timer <= 0.0:
			is_dashing = false
			velocity = Vector2.ZERO
		return
	
	
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1 
	direction = direction.normalized()
	
	velocity = direction * speed
	move_and_slide()
	
	#Animation ----
	if direction == Vector2.ZERO :
		%AnimationPlayer.play("idle")
	elif direction != Vector2.ZERO :
		%AnimationPlayer.play("walk")
	
	#Sprite Swap ----
	if direction == Vector2.ZERO:
		%Sprite2D.texture = load("res://assets/sprites/Luna.png")
	else:
		%Sprite2D.texture = load("res://assets/sprites/Luna2.png")
	
	position.x = clamp(position.x, 150, 1230)
	position.y = clamp(position.y, 50, 680)
# Flip Sprite ---
	if direction.x < 0:
		%Sprite2D.flip_h = true
	elif direction.x > 0:
		%Sprite2D.flip_h = false



func use_dash():
	var nearest = get_nearest_enemy()
	if nearest:
		dash_direction = (nearest.global_position - global_position).normalized
		nearest.queue_free()
		GameManager.enemy_kill
	else:
		var dir = Vector2.ZERO
		if Input.is_action_pressed("ui_right"):
			dir.x += 1
		if Input.is_action_pressed("ui_left"):
			dir.x -= 1
		if Input.is_action_pressed("ui_up"):
			dir.y -= 1
		if Input.is_action_pressed("ui_down"):
			dir.y += 1
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT if not %Sprite2D.flip_h else Vector2.LEFT
		dash_direction = dir.normalized()
	
	current_mana -= DASH_COST
	is_dashing = true
	dash_timer = dash_duration
	GameManager.update_mana(current_mana)


func use_stealth():
	is_stealthed = true
	stealth_timer = stealth_duration
	current_mana -= STEALTH_COST
	GameManager.update_mana(current_mana)


func use_teleport():
	teleport_mode = true
	current_mana -= TELEPORT_COST
	get_tree().paused = true
	GameManager.show_teleport_cursor()
	GameManager.update_mana(current_mana)


func teleport_to(target_pos: Vector2):
	global_position = target_pos
	get_tree().paused = false
	teleport_mode = false


func get_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest = null
	var nearest_dist = dash_detect_radius
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest


func add_mana(amount: int):
	current_mana = min(current_mana + amount, max_mana)
	GameManager.update_mana(current_mana)


func play_hit():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.5, 0.2, 0.2), 0.1)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.2)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	print("area name:", area.name)
	if area.is_in_group("enemy_hit"):
		play_hit()
