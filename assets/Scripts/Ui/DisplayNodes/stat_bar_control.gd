class_name StatBarControl
extends Control

const BAR_SPEED:float = 10.0

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
	pass # Replace with function body.
	
func set_actor(actor:BaseActor, stat_name:String):
	_actor = actor
	_stat_name = stat_name
	
func _process(delta: float) -> void:
	var target_display_width = maxi(min_bar_size, full_bar.size.x * _cached_stat_value / _max_value)
	var current_size = floori(colored_value_bar.size.x)
	if current_size != target_display_width:
		colored_value_bar.visible = true
		var change = target_display_width - current_size 
		if abs(change) < BAR_SPEED:
			colored_value_bar.size.x = target_display_width
		else:
			colored_value_bar.size.x += ceili(float(change) * delta * BAR_SPEED)
	if current_size == target_display_width or (
		target_display_width < min_bar_size and colored_value_bar.size.x == min_bar_size):
		colored_value_bar.visible = _cached_stat_value > 0

#func set_values(max_val:int, display_val:int, preview_value:int=-1, preview_cost:int=-1, animate_change:bool=false):
	#print("Max: %s | Dis: %s | Pre: %s | Cost: %s" % [max_val, display_val, preview_value, preview_cost])
	#_max_value = max_val
	#_animate_change = animate_change
	#if preview_value >= 0:
		#_background_value = display_val
		#if preview_cost > 0:
			#_blink_value = preview_value
			#_display_value = preview_value - preview_cost
		#else:
			#_display_value = preview_value
	#else:
		#print("---------No Prev")
		#_display_value = display_val
		#_background_value = display_val
	#_sync()
	
func _sync():
	var max = _max_value
	var stat_val = _stat_value
	if _preview_mode:
		var predicted_value = _get_predicted_value()
		_set_bar_size(dark_value_bar, stat_val, max)
		#_set_bar_size(colored_value_bar, predicted_value-_preview_cost, max)
		_cached_stat_value = predicted_value-_preview_cost
		_set_bar_size(blink_value_bar, predicted_value, max)
		label.text = str(predicted_value) + " / " + str(max)
	else:
		_set_bar_size(dark_value_bar, stat_val, max)
		#_set_bar_size(colored_value_bar, stat_val, max)
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
	
