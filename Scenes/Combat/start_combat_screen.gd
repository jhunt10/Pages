class_name StartCombatScreen
extends Control

signal screen_blacked_out
signal screen_clear

@export var animation_player:AnimationPlayer

func start_combat_animation():
	animation_player.play("flash_screen")
