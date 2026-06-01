extends CharacterBody2D

var speed = 300

func _physics_process(delta: float) -> void:
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
	
	if direction == Vector2.ZERO :
		%AnimationPlayer.play("idle")
	elif direction != Vector2.ZERO :
		%AnimationPlayer.play("walk")
	
	if direction == Vector2.ZERO:
		%Sprite2D.texture = load("res://assets/sprites/Luna.png")
	else:
		%Sprite2D.texture = load("res://assets/sprites/Luna2.png")
	
	position.x = clamp(position.x, 50, 1230)
	position.y = clamp(position.y, 50, 670)

	if direction.x < 0:
		%Sprite2D.flip_h = true
	elif direction.x > 0:
		%Sprite2D.flip_h = false
