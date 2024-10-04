class_name StatBarControl
extends Control

const BAR_SPEED:float = 100

@onready var full_bar:NinePatchRect = $FullBarRect
@onready var bar_holder:Control = $BarHolder
@onready var dark_value_bar:NinePatchRect = $BarHolder/BackValueRect
@onready var colored_value_bar:NinePatchRect = $BarHolder/ColorValueRect
@onready var blink_value_bar:NinePatchRect = $BarHolder/BlinkValueRect
@onready var animation:AnimationPlayer = $AnimationPlayer
@onready var label:Label = $Label

var _max_value:int:
	get: 
		if _actor: return _actor.stats.get_max_stat(_stat_name)
		else: return 1
		
var _stat_value:int:
	get:
		if _actor: return _actor.stats.get_stat(_stat_name)
		else: return 1
		
func _get_predicted_value()->int:
	if _actor: 
		var cost = 0
		for turn:TurnExecutionData in _actor.Que.QueExecData.TurnDataList:
			cost += turn.costs.get(_stat_name, 0)
		return max(0, _stat_value - cost)
	else: return 1
		
var min_bar_size:int:
	get: return colored_value_bar.patch_margin_left + colored_value_bar.patch_margin_right
		
var _actor:BaseActor
var _stat_name:String
var _preview_cost:int = 0
var _preview_mode:bool = true

var _cached_stat_value:int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blink_value_bar.visible = false
	_sync(true)
	pass # Replace with function body.
	
func set_actor(actor:BaseActor, stat_name:String):
	_actor = actor
	_stat_name = stat_name
	if full_bar:
		_sync(true)
	
func _process(delta: float) -> void:
	var target_display_width = maxi(min_bar_size, full_bar.size.x * _cached_stat_value / _max_value)
	var current_size = colored_value_bar.size.x
	var diff = target_display_width - current_size
	var speed = BAR_SPEED * delta
	
	#if _stat_name == "Stamina":
		#print("Targ: %s | Curt: %s | Sped: %s | Diff: %s" % [target_display_width, current_size, speed, diff])
	
	# Will reach target this frame
	if abs(diff) < speed:
		colored_value_bar.size.x = target_display_width
		colored_value_bar.visible = _cached_stat_value > 0
	else:
		colored_value_bar.visible = true
		if target_display_width < current_size:
			colored_value_bar.size.x -= speed
		else:
			colored_value_bar.size.x += speed

func set_previewing_mode(preview_mode:bool):
	_preview_mode = preview_mode
	_sync(true)

func _sync(snap_sync:bool = false):
	var max = _max_value
	var stat_val = _stat_value
	if _preview_mode:
		var predicted_value = _get_predicted_value()
		_set_bar_size(dark_value_bar, stat_val, max)
		if snap_sync:
			_set_bar_size(colored_value_bar, predicted_value-_preview_cost, max)
		else:
			_cached_stat_value = predicted_value-_preview_cost
		_set_bar_size(blink_value_bar, predicted_value, max)
		label.text = str(predicted_value) + " / " + str(max)
	else:
		_set_bar_size(dark_value_bar, stat_val, max)
		if snap_sync:
			_set_bar_size(colored_value_bar, stat_val, max)
		else:
			_cached_stat_value = stat_val
		_set_bar_size(blink_value_bar, 0, max)
		label.text = str(stat_val) + " / " + str(max)
	# No preview
	#dark_value_bar.size.x = full_bar.size.x * _background_value / _max_value
	#colored_value_bar.size.x = full_bar.size.x * _display_value / _max_value
	#colored_value_bar.visible = _display_value > 0
	#dark_value_bar.visible = _background_value > 0
	
		
	# Has preview
	##if _blink_value > 0:
		##blink_value_bar.size.x = full_bar.size.x * _blink_value / _max_value
		#blink_value_bar.visible = true
		#animation.play('blink_preview')
	#else:
		#animation.stop(false)
		#blink_value_bar.visible = false

func set_color(color:Color):
	bar_holder.modulate = color

func stop_preview_animation():
	if _preview_cost > 0:
		_preview_cost = 0
		animation.stop()
		_sync()
		
func play_preview_blink(cost:int):
	if _preview_mode:
		_preview_cost = cost
		animation.play('blink_preview')
		_sync()

func _set_bar_size(bar:NinePatchRect, val:int, max_val:int):
	bar.size.x = full_bar.size.x * val / max_val
	bar.visible = val > 0
	
