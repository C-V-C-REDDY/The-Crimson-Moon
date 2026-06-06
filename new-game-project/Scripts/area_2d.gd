extends Area2D

var speed = 300.0
var direction = Vector2.ZERO
var is_medusa = true

func _ready() -> void:
	await get_tree().create_timer(4.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		var enemy = area.get_parent()
		if enemy.name == "Boss":
			return
		if enemy.has_method("freeze"):
			enemy.freeze()
		queue_free()
