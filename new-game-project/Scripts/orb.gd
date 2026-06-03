extends Area2D


var speed = 1000.0
var damage = 5.0

func _physics_process(_delta: float) -> void:
	var luna = get_tree().get_nodes_in_group("luna")
	var direction = (luna.global_position - global_position).normalized()
