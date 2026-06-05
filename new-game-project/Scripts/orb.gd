extends Area2D


var speed = 300.0
var direction = Vector2.ZERO
var damage = 5.0

func _physics_process(delta: float) -> void:
	position += direction * speed * delta




func _ready() -> void:
	add_to_group("enemy_hit")
	await get_tree().create_timer(3.0).timeout
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("luna_hurtbox"):
		GameManager.current_health -= damage
		get_tree().get_first_node_in_group("luna").play_hit()
		queue_free()
