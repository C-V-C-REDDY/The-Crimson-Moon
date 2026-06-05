extends CharacterBody2D

var speed = 200
var damage = 5
var health = 20.0

func _physics_process(_delta: float) -> void:
	var luna = get_tree().get_first_node_in_group("luna")
	var direction = (luna.global_position - global_position).normalized()
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
		GameManager.current_health -= damage

func take_damage(amount: float) -> void:
	health -= amount
	%ProgressBar.value = health
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.16, 0.0, 0.0, 1.0), 0.1)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.1)
	if health <= 0:
		%AnimationPlayer.play("die")
		await get_tree().create_timer(0.3).timeout
		queue_free()
		GameManager.enemy_kill
