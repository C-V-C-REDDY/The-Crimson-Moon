extends Node

func _ready() -> void:
	%HpFAnim.play("idle")
	%CloverAnim.play("clover")

func _process(_delta: float) -> void:
	%Mana_bar.value = GameManager.mana
	%HpBar.value = GameManager.current_health
