extends Area2D

func _ready() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position", position + Vector2(0, -8), 0.8)
	tween.tween_property(self, "position", position + Vector2(0, 0.8), 0.8)
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("luna"):
		GameManager.clover_claimed = true
		GameManager.mana += 5.0
		GameManager.clover_count += 1
		if GameManager.mana > GameManager.max_mana:
			GameManager.mana = GameManager.max_mana
		queue_free()
		
