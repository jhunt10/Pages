class_name HealthBarControl
extends Control

const LOGGING = false

@export var BAR_SPEED:float = 100
@export var change_delay:float = 1
@export var full_bar:NinePatchRect
@export var bar_holder:Control
@export var dark_value_bar:NinePatchRect
@export var colored_value_bar:NinePatchRect
@export var blink_value_bar:NinePatchRect
@export var left_label:Label
@export var mid_label:Label
@export var right_label:Label

var _change_timer:float = 0

var _last_synced_value = -1
var is_changing:bool = false
var _last_display_bar_value:int = 0
var _target_display_bar_width:float
var _last_display_bar_width:float=-1
var was_changing:bool = false
var been_synced = false

var _hold_for_change:bool = true

var min_bar_size:int:
	get: return colored_value_bar.patch_margin_left + colored_value_bar.patch_margin_right
		
var _actor:BaseActor

#var _cached_stat_value:int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !full_bar:
		return
	pass # Replace with function body.
	
func set_actor(actor:BaseActor):
	if !actor:
		return
	if _actor:
		if _actor.Que.turn_ended.is_connected(on_turn_end):
			_actor.Que.turn_ended.disconnect(_sync)
		if _actor.stats.health_changed.is_connected(on_turn_end):
			_actor.stats.health_changed.disconnect(_sync)
	_actor = actor
	if full_bar:
		_sync()
	_actor.stats.health_changed.connect(_sync)
	_actor.turn_ended.connect(on_turn_end)
	
func _process(delta: float) -> void:
	if !full_bar or !_actor:
		return
	
	if not _hold_for_change:
		animate_bars_changing(delta)

func on_turn_end():
	_hold_for_change = false

func animate_bars_changing(delta:float):
	var _current_value = _actor.stats.current_health
	var _max_value = _actor.stats.max_health
	var speed = BAR_SPEED * delta
	var changeing = false
	# Animate color bar:
	var diff = _target_display_bar_width - colored_value_bar.size.x
	if absf(diff) > 0.5:
		if LOGGING:print("Diff: " + str(diff))
		changeing = true
		# Will reach target this frame
		if abs(diff) < speed:
			colored_value_bar.size.x = _target_display_bar_width
			colored_value_bar.visible = _current_value > 0
		else:
			colored_value_bar.visible = true
			if _target_display_bar_width < colored_value_bar.size.x:
				colored_value_bar.size.x -= speed
			else:
				colored_value_bar.size.x += speed
	
	# Animate Dark bar:
	diff = _target_display_bar_width - dark_value_bar.size.x
	if absf(diff) > 0.5:
		changeing = true
		# Will reach target this frame
		if abs(diff) < speed:
			dark_value_bar.size.x = _target_display_bar_width
			dark_value_bar.visible = _current_value > 0
		else:
			dark_value_bar.visible = true
			if _target_display_bar_width < dark_value_bar.size.x:
				dark_value_bar.size.x -= speed
			else:
				dark_value_bar.size.x += speed
	if was_changing and !changeing:
		if LOGGING:printerr("Change done")
		right_label.text = ""
		_last_display_bar_width = _target_display_bar_width
		_last_display_bar_value = _last_synced_value
		_hold_for_change = true
	was_changing = changeing

# Instantly sets bars to current health values
func _sync():
	if !full_bar or !_actor:
		return
	var current_value = _actor.stats.current_health
	var max_value = _actor.stats.max_health
	
		
	if _actor and LOGGING:
		print("Syncing: %s for '%s'" % ["Health", _actor.Id])
		print("MaxVal: %s | Current Val: %s" % [max_value, current_value])
	var max_2 = max_value
	var new_val = current_value
	
	if not been_synced:
		mid_label.text = str(new_val) + " / " + str(max_2)
		right_label.text = ""
		_last_synced_value = new_val
		_last_display_bar_value = new_val
		_target_display_bar_width = _vals_to_bar_size(new_val, max_2)
		colored_value_bar.size.x = _target_display_bar_width
		dark_value_bar.size.x = _target_display_bar_width
		been_synced = true
		return
	
	_target_display_bar_width = _vals_to_bar_size(new_val, max_2)
	if _last_display_bar_width < 0:
		_last_display_bar_width = colored_value_bar.size.x
	was_changing = true
	mid_label.text = str(new_val) + " / " + str(max_2)
	left_label.text = ''
	
	# Set Left Text
	if _last_synced_value > -1:
		var net_change = new_val - _last_display_bar_value
		if net_change == 0:
			right_label.text = ""
		else:
			var text = str(net_change)
			if net_change > 0:
				right_label.text = "+%s" % [net_change]
			if abs(net_change) < 10: text = " " + text
			if abs(net_change) < 100: text = " " + text
			right_label.text = text
		
	# Color bar never animates going down, it jumps to lowest value
	if _last_display_bar_value > new_val:
		colored_value_bar.size.x = _target_display_bar_width
	# Dark bar never animates going up, it jumps to highest value
	if _last_display_bar_value < new_val:
		dark_value_bar.size.x = _target_display_bar_width
	
	_last_synced_value = new_val
	print("Last Sync Value: " + str(_last_synced_value))

func set_color(color:Color):
	if bar_holder == null:
		bar_holder = $BarHolder
	bar_holder.modulate = color

#func stop_preview_animation():
	#if _preview_cost > 0:
		#_preview_cost = 0
		#animation.stop()
		#_sync()
		#
#func play_preview_blink(cost:int):
	#if _preview_mode:
		#_preview_cost = cost
		#_sync()

func _set_bar_size(bar:NinePatchRect, val:int, max_val:int):
	bar.size.x = full_bar.size.x * val / max_val
	bar.visible = val > 0
	
func _vals_to_bar_size(val:int, max_val:int):
	var full_bar_size = full_bar.size.x
	if full_bar_size == 0:
		full_bar_size = 128
	return max(min_bar_size, full_bar_size * val / max_val)
