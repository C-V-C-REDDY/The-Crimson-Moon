extends Node2D
@onready var start_bmg: AudioStreamPlayer = $Start_BMG
@onready var in_game_bgm: AudioStreamPlayer = $In_game_bgm
@onready var boss_laugh: AudioStreamPlayer = $Boss_laugh
@onready var enemy_hurt: AudioStreamPlayer = $enemy_hurt
@onready var clover: AudioStreamPlayer = $Clover
@onready var enemy_kill: AudioStreamPlayer = $enemy_kill
@onready var stealth: AudioStreamPlayer = $stealth
@onready var luna_hurt: AudioStreamPlayer = $luna_hurt
@onready var luna_throw: AudioStreamPlayer = $luna_throw
@onready var teleport: AudioStreamPlayer = $teleport
@onready var dash: AudioStreamPlayer = $dash
@onready var click: AudioStreamPlayer = $click







func play_start_bgm():
	get_node("Start_BMG").play()
	get_node("In_game_bgm").stop()

func play_ingame_bgm():
	in_game_bgm.play()
	start_bmg.stop()

func play_stealth():
	stealth.play()

func play_boss_laugh():
	boss_laugh.play()


func play_enemy_hurt():
	enemy_hurt.play()


func play_enemy_die():
	enemy_kill.play()

func play_clover():
	clover.play()

func play_luna_hurt():
	luna_hurt.play()


func play_luna_throw():
	luna_throw.play()

func play_teleport():
	teleport.play()

func play_dash():
	dash.play()

func play_click():
	click.play()
