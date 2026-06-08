extends Node2D

var moon_textures = [
	preload("res://assets/sprites/Moon2.png"),
	preload("res://assets/sprites/Moon3.png"),
	preload("res://assets/sprites/Moon4.png"),
	preload("res://assets/sprites/Moon5.png"),
	preload("res://assets/sprites/Moon6.png"),
	preload("res://assets/sprites/Moon7.png")
]
var time = 0.0



var current_health = 100.0
var max_health = 100.0
var mana = 10.0
var max_mana = 10.0
var clover_count = 0
var teleport_active = false
#Spawning Logic ---

var enemies_killed = 0
var enemies_alive = 0
var total_enemies_in_wave = 0
var clover_spawned = false
var clover_claimed = false
var current_floor = 1
var current_wave = 0
var melle_scene = preload("res://scenes/Melle.tscn")
var ninja_scene = preload("res://scenes/ninja.tscn")
var mage_scene = preload("res://scenes/mage.tscn")
var summoner_scene = preload("res://scenes/summoner.tscn")
var clover_scene = preload("res://scenes/clover.tscn")
var boss_scene = preload("res://scenes/boss.tscn")
var clover_pos = Vector2(640,500)
var floor_trasitioning = false
var boss_killed = false
var kill_count = 0

# Floor Data

var floor_data = {
	1: [
		{0: 5},
		{0: 5}
	],
	2: [
		{1: 3, 0: 2},
		{1: 3, 0: 2}
	],
	3: [
		{2: 2, 1: 2 , 0: 2},
		{2: 2, 1: 2, 0: 2}
	],
	4: [
		{3: 1},
		{3: 2}
	],
	5: [
		{3: 2, 2: 1},
		{3: 1, 2: 1},
		{3: 1, 2: 1},
		{3: 2, 2: 1, 1: 2}
	],
	6: [
		{0: 5},
		{1: 2, 0: 3},
		{2: 3, 1:3, 0: 3},
		{3: 2}
	]
}

var spawn_bounds = {
	"x_min": 200, "x_max": 1100,
	"y_min": 100, "y_max": 600
}


func _process(delta: float) -> void:
	if boss_killed:
		return
	time += delta



func start_floor(floor_num: int) -> void:
	current_floor = floor_num
	current_wave = 0
	clover_spawned = false
	enemies_killed = 0
	if floor_num == 7:
		setup_boss_floor()
	spawn_next_wave()


func spawn_next_wave() -> void:
	if floor_trasitioning:
		return
	print("spawn_next_wave called -- wave: ", current_wave, "floor: ", current_floor)
	if not floor_data.has(current_floor):
		return
	var waves = floor_data[current_floor]
	if current_wave >= waves.size():
		print("floor complete triggered")
		floor_complete()
		return
	enemies_alive = 0
	enemies_killed = 0
	clover_spawned = false
	
	var wave = waves[current_wave]
	for enemy_index in wave:
		var count = wave[enemy_index]
		var scene = get_enemy_scene(enemy_index)
		for i in count:
			spawn_enemy(scene)
	
	total_enemies_in_wave = enemies_alive
	current_wave += 1


func spawn_enemy(scene) -> void:
	var enemy = scene.instantiate()
	enemy.global_position = get_random_spawn_pos()
	get_tree().current_scene.add_child(enemy)
	enemies_alive += 1


func spawn_summoned_enemy(scene) -> void:
	var enemy = scene.instantiate()
	enemy.global_position = get_random_spawn_pos()
	enemy.modulate.a = 0.7
	enemy.is_summoned = true
	get_tree().current_scene.add_child(enemy)

func get_random_spawn_pos() -> Vector2:
	var attempts = 0
	var pos = Vector2.ZERO
	var luna = get_tree().get_first_node_in_group("luna")
	while attempts < 10:
		pos = Vector2(
			randf_range(spawn_bounds.x_min, spawn_bounds.x_max),
			randf_range(spawn_bounds.y_min, spawn_bounds.y_max)
		)
		if luna and pos.distance_to(luna.global_position) > 200:
			break
		attempts += 1
	return pos


func get_enemy_scene(index: int) -> PackedScene:
	match index:
		0: return melle_scene
		1: return ninja_scene
		2: return mage_scene
		3: return summoner_scene
	return melle_scene

func enemy_killed() -> void:
	if floor_trasitioning:
		return
	enemies_alive -= 1
	enemies_killed += 1
	print("enemy killed - alive", enemies_killed, "killed:",enemies_killed, "total: ", total_enemies_in_wave)
	#spawning clover at 50% kills
	if not clover_spawned and  enemies_alive == 0:
		spawn_clover()
		clover_spawned = true
	
	if enemies_alive <= 0:
		await get_tree().create_timer(1.5).timeout
		spawn_next_wave()


func update_mana(value: float) -> void:
	mana = value

func spawn_clover() -> void:
	var clover = clover_scene.instantiate()
	clover.global_position = clover_pos
	get_tree().current_scene.add_child(clover)

func floor_complete() -> void:
	var moon = get_tree().get_first_node_in_group("moon")
	moon.texture = moon_textures[current_floor - 1]
	floor_trasitioning = true
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	var luna = get_tree().get_first_node_in_group("luna")
	var tween = get_tree().create_tween()
	tween.tween_property(luna, "modulate", Color(0.0, 0.0, 0.0),0.5)
	tween.tween_property(luna, "modulate", Color(1.0, 1.0, 1.0), 0.5)
	await get_tree().create_timer(2.0).timeout
	current_floor += 1
	if current_floor > 7:
		print("Game Completed!!")
		return
	switch_floor()
	print("Floor", current_floor, "complete!")


func switch_floor() -> void:
	current_wave = 0
	enemies_killed = 0
	clover_claimed = false
	enemies_alive = 0
	#update_moon()
	var luna = get_tree().get_first_node_in_group("luna")
	luna.global_position = Vector2(640, 666)
	floor_trasitioning = false
	#for enemy in get_tree().get_nodes_in_group("enemies"):
		#enemy.queue_free()
	
	start_floor(current_floor)

#func upadate_moon() -> void:
	#if current_floor <= moon_textures.size():
		#
func show_teleport_cursor():
	teleport_active = true

func boss_defeated() -> void:
	var best = load_high_score()
	if best == 0.0 or time < best:
		save_high_score(time)
	floor_trasitioning = true
	boss_killed = true
	get_tree().paused = true


func setup_boss_floor() -> void:
	var luna = get_tree().get_first_node_in_group("luna")
	luna.medusa_unlocked = true
	current_health = max_health
	var boss = boss_scene.instantiate()
	boss.global_position = Vector2(640, 200)
	get_tree().current_scene.add_child(boss)
	spawn_floor7_summoners()


func spawn_floor7_summoners() -> void:
	if boss_killed:
		queue_free()
		return
	var s1 = summoner_scene.instantiate()
	var s2 = summoner_scene.instantiate()
	s1.global_position = get_random_spawn_pos()
	s2.global_position = get_random_spawn_pos()
	get_tree().current_scene.add_child(s1)
	get_tree().current_scene.add_child(s2)
	await get_tree().create_timer(30.0).timeout
	spawn_floor7_summoners()


func save_high_score(time: float) -> void:
	var file = FileAccess.open("user://high_score.txt", FileAccess.WRITE)
	file.store_float(time)
	file.close()


func load_high_score() -> float:
	if not FileAccess.file_exists("user://high_score.txt"):
		return 0.0
	var file = FileAccess.open("user://high_score.txt", FileAccess.READ)
	var score = file.get_float()
	file.close()
	return score


func reset():
	current_floor = 1
	current_wave = 0
	enemies_alive = 0
	enemies_killed = 0
	kill_count = 0
	current_health = max_health
	mana = 0.0
	time = 0.0
	clover_count = 0
	floor_trasitioning = false
	boss_killed = false
