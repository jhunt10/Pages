@tool
class_name StatBarControl
extends Control

const LOGGING = false

@export var BAR_SPEED:float = 100
var _preview_mode:bool = false
@export var preview_mode:bool:
	get: return _preview_mode
	set(val):
		if val != _preview_mode:
			if LOGGING: print("Premview Mode Set")
			if LOGGING and _actor: print("For actor: " + _actor.Id)
			_preview_mode = val
			_sync()

var _max_value:int = 1
@export var max_value:int:
	get:
		if _actor: 
			_max_value = _actor.stats.get_bar_stat_max(_stat_name)
		return _max_value
	set(val):
		if val != max_value:
			_max_value = val
			if LOGGING: print("Max Value Set")
			if LOGGING and _actor: print("For actor: " + _actor.Id)
			_sync()

# Technically, this is the value it wants to be displaying
var _current_value:int = 1
@export var current_value:int:
	get:
		if _actor:
			_current_value = _actor.stats.get_bar_stat(_stat_name)
		return _current_value
	set(val):
		if val != _current_value:
			_current_value = val
			if LOGGING: print("Current Value Set")
			if LOGGING and _actor: print("For actor: " + _actor.Id)
			_sync()

var _predicted_value:int = 1
@export var predicted_value:int:
	get:
		if _actor: 
			_predicted_value = _current_value - _actor.Que.get_total_preview_costs().get(_stat_name, 0)
		return _predicted_value
	set(val):
		if val != _predicted_value:
			if LOGGING: print("Predict Value Set")
			if LOGGING and _actor: print("For actor: " + _actor.Id)
			_predicted_value = val
			_sync()

var _preview_cost:int = 0
var _delay_preview:bool = false
@export var preview_cost:int:
	get: return _preview_cost
	set(val):
		if val != _preview_cost:
			if LOGGING: print("Preivew Cost Set")
			if LOGGING and _actor: print("For actor: " + _actor.Id)
			_preview_cost = val
			_sync()

@export var full_bar:NinePatchRect
	#get: return $FullBarRect
@export var bar_holder:Control
	#get: return $BarHolder
@export var dark_value_bar:NinePatchRect
	#get: return $BarHolder/BackValueRect
@export var colored_value_bar:NinePatchRect
	#get: return $BarHolder/ColorValueRect
@export var blink_value_bar:NinePatchRect
	#get: return $BarHolder/BlinkValueRect
@export var animation:AnimationPlayer
	#get: return $AnimationPlayer
@export var left_label:Label
@export var mid_label:Label
@export var right_label:Label
	#get: return $Label

@export var change_delay:float = 1
var _change_timer:float = 0

var _last_synced_value = 0
var is_changing:bool = false
var _last_display_bar_value:int = 0
var _target_display_bar_width:float
var _last_display_bar_width:float=-1
var was_changing:bool = false

var min_bar_size:int:
	get: return colored_value_bar.patch_margin_left + colored_value_bar.patch_margin_right
		
var _actor:BaseActor
var _stat_name:String

#var _cached_stat_value:int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !full_bar:
		return
	blink_value_bar.visible = false
	_sync()
	pass # Replace with function body.
	
func set_actor(actor:BaseActor, stat_name:String):
	if !actor:
		return
	if _actor:
		if _actor.Que.action_que_changed.is_connected(_sync):
			_actor.Que.action_que_changed.disconnect(_sync)
		if _actor.stats.bar_stat_changed.is_connected(_sync):
			_actor.stats.bar_stat_changed.disconnect(_sync)
	_actor = actor
	_stat_name = stat_name
	if full_bar:
		_sync()
	_actor.Que.action_que_changed.connect(_sync)
	_actor.stats.bar_stat_changed.connect(_sync)
	
func _process(delta: float) -> void:
	if !full_bar:
		return
	
	if _preview_mode:
		_change_timer = 0
		return
		
	var speed = BAR_SPEED * delta
	if _change_timer > 0:
		_change_timer -= delta
		if _change_timer > 0:
			return
		_change_timer = 0
		var net_change = _last_synced_value - _last_display_bar_value
		if net_change == 0:
			right_label.text = ""
		elif net_change > 0:
			right_label.text = "+%s" % [net_change]
		else:
			right_label.text = "%s" % [net_change]
	
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
	was_changing = changeing
	if !changeing and _delay_preview:
		if LOGGING:print("Delayed Preive")
		set_previewing_mode(true)
		_delay_preview = false

func set_previewing_mode(val:bool, wait_for_change:bool=false):
	if LOGGING: print("Set Preview: Current:%s | New:%s | Delaying:%s" % [_preview_mode, val, _delay_preview])
	if val and not _preview_mode and wait_for_change:
		_delay_preview = true
		return
	var was_preview = _preview_mode
	_preview_mode = val
	_sync()
	if was_preview:
		_last_display_bar_value = current_value
		_target_display_bar_width = _vals_to_bar_size(_last_display_bar_value, _max_value)
		colored_value_bar.size.x = _target_display_bar_width
		dark_value_bar.size.x = _target_display_bar_width

func _sync():
	if !full_bar:
		return
	if _actor and LOGGING:
		print("Syncing: %s for '%s' | PreviewMod: %s" % [_stat_name, _actor.Id, _preview_mode])
		print("MaxVal: %s | Current Val: %s" % [max_value, current_value])
	var max_2 = max_value
	var new_val = current_value
	if not preview_mode:
		if animation.is_playing():
			animation.stop()
		if blink_value_bar.visible:
			blink_value_bar.visible = false
		_change_timer = change_delay
		_target_display_bar_width = _vals_to_bar_size(new_val, max_2)
		if _last_display_bar_width < 0:
			_last_display_bar_width = colored_value_bar.size.x
		was_changing = true
		mid_label.text = str(new_val) + " / " + str(max_2)
		left_label.text = ''
		
		var net_change = _last_synced_value - _last_display_bar_value
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
	if preview_mode:
		if !animation.is_playing():
			animation.play('blink_preview')
		if !blink_value_bar.visible:
			blink_value_bar.visible = true
		var predicted_val = predicted_value
		if LOGGING: print("Set Preive Mode stuff: Real: %s | Pred: %s | Cost: %s " % [new_val, predicted_val, preview_cost])
		dark_value_bar.size.x = _vals_to_bar_size(new_val, max_2)
		blink_value_bar.size.x = _vals_to_bar_size(predicted_val, max_2)
		colored_value_bar.size.x = _vals_to_bar_size(predicted_val - preview_cost, max_2)
		
		mid_label.text = str(predicted_val) + " / " + str(max)
		#left_label.text = "(%s)" % [(predicted_val)]
		if preview_cost > 0:
			right_label.text = "-%s" % [preview_cost]
		else:
			right_label.text = ''
		
	_last_synced_value = new_val

func set_color(color:Color):
	if bar_holder == null:
		bar_holder = $BarHolder
	bar_holder.modulate = color

func stop_preview_animation():
	if _preview_cost > 0:
		_preview_cost = 0
		animation.stop()
		_sync()
		
func play_preview_blink(cost:int):
	if _preview_mode:
		_preview_cost = cost
		_sync()

func _set_bar_size(bar:NinePatchRect, val:int, max_val:int):
	bar.size.x = full_bar.size.x * val / max_val
	bar.visible = val > 0
	
func _vals_to_bar_size(val:int, max_val:int):
	return max(min_bar_size, full_bar.size.x * val / max_val)
