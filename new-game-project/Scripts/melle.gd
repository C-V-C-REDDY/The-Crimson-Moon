extends CharacterBody2D

var speed = 100.0
var damage = 1
var health = 20.0
var is_summoned = false
var is_freeze = false
func _ready():
	# Breathe
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(0.48, 0.48), 0.9)
	tween.tween_property(self, "scale", Vector2(0.4, 0.4), 0.9)
	
	# Glow pulse
	var tween2 = create_tween().set_loops()
	tween2.tween_property(self, "modulate", Color(1.2, 1.2, 1.4), 1.0)
	tween2.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 1.0)

func _physics_process(_delta: float) -> void:
	if is_freeze:
		return
	var luna = get_tree().get_first_node_in_group("luna")
	var direction = (luna.global_position - global_position).normalized()
	if luna.is_stealthed:
		%ST1.visible = true
		return
	else:
		%ST1.visible = false
	if GameManager.teleport_active:
		return
	velocity = direction * speed
	move_and_slide()
	
	


func _on_hit_box_body_entered(body: Node2D) -> void:
	var luna = get_tree().get_first_node_in_group("luna")
	if body == luna:
		GameManager.current_health -= 5
		get_tree().get_first_node_in_group("luna").play_hit()
		%MelleAnim.play("Attack")



func take_damage(amount: float) -> void:
	health -= amount
	%ProgressBar.value = health
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.16, 0.0, 0.0, 1.0), 0.1)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.1)
	if health <= 0:
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
