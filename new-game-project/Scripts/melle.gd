extends CharacterBody2D

var speed = 100.0
var damage = 1


func _ready():
	add_to_group("enemies")
	%HitBox.add_to_group("enemy_hit")
	# Breathe
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(0.48, 0.48), 0.9)
	tween.tween_property(self, "scale", Vector2(0.4, 0.4), 0.9)
	
	# Glow pulse
	var tween2 = create_tween().set_loops()
	tween2.tween_property(self, "modulate", Color(1.2, 1.2, 1.4), 1.0)
	tween2.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 1.0)

#func _physics_process(_delta: float) -> void:
	#var luna = get_tree().get_first_node_in_group("luna")
	#var direction = (luna.global_position - global_position).normalized()
	#velocity = direction * speed
	#move_and_slide()
	#
	


func _on_hit_box_body_entered(body: Node2D) -> void:
	var luna = get_tree().get_first_node_in_group("luna")
	if body == luna:
		GameManager.current_health -= 5
		GameManager.emit_signal("damage")
