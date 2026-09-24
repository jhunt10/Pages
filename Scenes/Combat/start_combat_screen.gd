class_name StartCombatScreen
extends Control

@warning_ignore("unused_signal")
signal screen_blacked_out
@warning_ignore("unused_signal")
signal screen_clear

@export var animation_player:AnimationPlayer

func start_combat_animation():
	animation_player.play("flash_screen")
