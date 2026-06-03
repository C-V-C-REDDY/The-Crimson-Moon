extends Node2D

signal damage
var current_floor = 1.0
var moon_textures = [
	preload("res://assets/sprites/Moon1.png"),
	preload("res://assets/sprites/Moon2.png"),
	preload("res://assets/sprites/Moon3.png"),
	preload("res://assets/sprites/Moon4.png"),
	preload("res://assets/sprites/Moon5.png"),
	preload("res://assets/sprites/Moon6.png"),
	preload("res://assets/sprites/Moon7.png")
]
var current_health = 100.0
var max_health = 100.0
var mana = 10.0
var enemy_kill = 0
