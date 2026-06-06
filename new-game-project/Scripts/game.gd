extends Node

func _ready() -> void:
	%HpFAnim.play("idle")
	%CloverAnim.play("clover")
	GameManager.start_floor(1)

func _process(_delta: float) -> void:
	if get_tree().paused and GameManager.teleport_active:
		var cursor = %TeleportCursor
		cursor.visible = true
		cursor.position = get_viewport().get_mouse_position() - Vector2(15, 15)
		
		if Input.is_action_just_pressed("shoot"):
			var world_pos = get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()
			GameManager.teleport_active = false
			cursor.visible = false
			get_tree().get_first_node_in_group("luna").teleport_to(world_pos)
	%Mana_bar.value = GameManager.mana
	%HpBar.value = GameManager.current_health
	if GameManager.clover_claimed:
		%Clover_Claim.play("Clover_claim")
		await get_tree().create_timer(1.0).timeout
		%Label.text = str(GameManager.clover_count) + " / 7"
		GameManager.clover_claimed = false
	
	
	%Dash.modulate.a = 1.0 if GameManager.mana >= 3 else 0.4
	%Stealth.modulate.a = 1.0 if GameManager.mana >= 3 else 0.4
	%Teleport.modulate.a = 1.0 if GameManager.mana >= 3 else 0.4
