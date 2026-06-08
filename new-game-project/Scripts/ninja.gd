extends CharacterBody2D

var speed = 200
var damage = 5
var health = 10.0
var is_summoned = false
var is_freeze = false
func _physics_process(_delta: float) -> void:
	if is_freeze:
		return
	var luna = get_tree().get_first_node_in_group("luna")
	var direction = (luna.global_position - global_position).normalized()
	if luna.is_stealthed:
		%Label.visible = true
		return
	else:
		%Label.visible = false
	if GameManager.teleport_active:
		return
	velocity = direction * speed
	move_and_slide()
	%NinjaAnim.play("Run")
	
	if direction.x <= 0:
		%NinjaAnim.flip_h = true
	else:
		%NinjaAnim.flip_h = false

func _ready() -> void:
	add_to_group("enemies")
	%HitBox.add_to_group("enemy_hit")

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("luna"):
		get_tree().get_first_node_in_group("luna").play_hit()
		GameManager.current_health -= damage

func take_damage(amount: float) -> void:
	health -= amount
	%ProgressBar.value = health
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.16, 0.0, 0.0, 1.0), 0.1)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.1)
	if health <= 0:
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
