extends Area2D

var speed = 400.0
var direction = Vector2.ZERO
var damage = 10.0

func _ready() -> void:
	add_to_group("enemy_hitbox")
	await get_tree().create_timer(3.0).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("luna_hurtbox"):
		get_tree().get_first_node_in_group("luna").play_hit()
		GameManager.current_health -= damage
		queue_free()
