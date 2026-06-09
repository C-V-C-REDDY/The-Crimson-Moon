extends Node

func _ready() -> void:
	GameManager.reset()
	%HpFAnim.play("idle")
	%CloverAnim.play("clover")
	GameManager.start_floor(1)
	Audio.play_ingame_bgm()

func _process(_delta: float) -> void:
	if not is_instance_valid(GameManager):
		return
	if GameManager.boss_killed:
		win()
		return
	if GameManager.current_health <= 0:
		loose()
		return
		
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
		%Label.text = " X " + str(GameManager.clover_count)
		GameManager.clover_claimed = false
	%kill_lable.text = " X " + str(GameManager.kill_count)
	%floor_count.text = str(GameManager.current_floor) + " . " + str(GameManager.current_wave) 
	%Dash.modulate.a = 1.0 if GameManager.mana >= 3 else 0.4
	%Stealth.modulate.a = 1.0 if GameManager.mana >= 3 else 0.4
	%Teleport.modulate.a = 1.0 if GameManager.mana >= 3 else 0.4

#Win 

func win():
	get_tree().paused = true
	%Win.visible = true
	var minutes = int(GameManager.time / 60)
	var seconds = int(GameManager.time) % 60
	%timer.text = "%02d:%02d" % [minutes, seconds]
	%Clovercount.text = str(int(GameManager.clover_count))
	%Kills.text = str(int(GameManager.kill_count))
	var best = GameManager.load_high_score()
	var best_min = int(best / 60)
	var best_sec = int(best) % 60
	%High_score.text = "%02d:%02d" % [best_min, best_sec]
	%AnimationPlayer.play("win")


#Die 

func loose():
	get_tree().paused = true
	%Die.visible = true
	var minutes = int(GameManager.time / 60)
	var seconds = int(GameManager.time )% 60
	%Timer.text = "%02d:%02d" % [minutes, seconds]
	%Clover_count.text = str(int(GameManager.clover_count))
	%Kill_count.text = str(int(GameManager.kill_count))
	%Looseanim.play("loose")

#Pause ----

func _on_pause_pressed() -> void:
	Audio.play_click()
	get_tree().paused = true
	%pause_menu.visible = true

#Pause Menu -> Resume --

func _on_resumebt_pressed() -> void:
	Audio.play_click()
	get_tree().paused = false
	%pause_menu.visible = false

#Pause Menu -> Restart --

func _on_restartbt_pressed() -> void:
	Audio.play_click()
	get_tree().paused = false
	get_tree().reload_current_scene()
	GameManager.reset()
	%pause_menu.visible = false

#Die Screen -> Restart --

func _on_restartbtdie_pressed() -> void:
	Audio.play_click()
	get_tree().paused = false
	get_tree().reload_current_scene()
	GameManager.reset()


#Win Screen -> Restart --

func _on_restartwin_pressed() -> void:
	Audio.play_click()
	get_tree().paused = false
	get_tree().reload_current_scene()
	GameManager.reset()

#Win Screen -> Menu --

func _on_menuwin_pressed() -> void:
	Audio.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
	%Win.visible = false

#Die Screen -> Menu --

func _on_menu_pressed() -> void:
	#GameManager.reset()
	Audio.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

#Pause Menu -> Menu --

func _on_menubt_pressed() -> void:
	Audio.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
