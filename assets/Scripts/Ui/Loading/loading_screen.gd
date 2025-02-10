class_name LoadingScreen
extends Control

signal loading_screen_has_full_coverage
signal loading_screen_fully_gone

@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var progress_bar:ProgressBar = $ColorRect/ProgressBar

var load_scale = 100

func _update_progress(new_val:float):
	print("Load Val: %s" % [new_val])
	progress_bar.set_value_no_signal(new_val * load_scale)
	
func _start_outro_animation():
	animation_player.play("outro_animation")
	await  Signal(animation_player, 'animation_finished')
	printerr("Test 3")
	loading_screen_fully_gone.emit()
	self.queue_free()
	LoadManager._load_screen = null

func _combad_actor_loaded(count, index):
	var val = (float(index) / float(count * 2)) * 100
	progress_bar.set_value_no_signal(val + load_scale)
	#await get_tree().process_frame
	print("Actor Loaded: %s / %s = %s" % [index, count, val])
