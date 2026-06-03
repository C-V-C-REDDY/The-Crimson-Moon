extends CharacterBody2D


var speed = 75.0
var damage = 5.0

func _ready() -> void:
	# Breathe
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(0.78, 0.78), 0.9)
	tween.tween_property(self, "scale", Vector2(0.7, 0.7), 0.9)

func _physics_process(_delta: float) -> void:
	var luna = get_tree().get_first_node_in_group("luna")
	var direction = (luna.global_position - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()
	
	if direction.x <= 0:
		%Mage.flip_h = true
	else:
		%Mage.flip_h = false
