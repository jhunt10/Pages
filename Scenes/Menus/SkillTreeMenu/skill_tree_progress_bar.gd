class_name SkillTreeProgressBar
extends NinePatchRect

@export var speed:float
@export var progress_bar_background:ColorRect
@export var progress_bar_color:ColorRect

var _target_size:float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var bar_size = progress_bar_color.size.x
	if abs(bar_size - _target_size) > 0.1:
		var change = delta * speed
		if bar_size > _target_size:
			progress_bar_color.size.x = max(_target_size, progress_bar_color.size.x - change)
		else:
			progress_bar_color.size.x = min(_target_size, progress_bar_color.size.x + change)
		

func set_progresss(value:int, total:int):
	var percent_full = minf(value, total) / (total as float)
	_target_size = progress_bar_background.size.x * percent_full
