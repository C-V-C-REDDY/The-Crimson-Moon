extends CharacterBody2D

var speed = 200
var damage = 5

#func _physics_process(_delta: float) -> void:
	##var luna = get_tree().get_first_node_in_group("luna")
	##var direction = (luna.global_position - global_position).normalized()
	##velocity = direction * speed
	##move_and_slide()
	##%NinjaAnim.play("Run")
	#
	##if direction.x <= 0:
		##%NinjaAnim.flip_h = true
	##else:
		##%NinjaAnim.flip_h = false


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("luna"):
		GameManager.current_health -= damage
