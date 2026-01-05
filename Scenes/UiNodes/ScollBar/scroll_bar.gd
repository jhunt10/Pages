class_name CustScrollBar
extends NinePatchRect

@export var scroll_bounds:Control
@export var bar:NinePatchRect
@export var bar_button:Button
@export var scroll_container:ScrollContainer
@export var debug_name:String
@export var opposite_spacer:Node

var dragging = false
var drag_offset = 0

var _delay_size_calc = false
var _last_child_pos = 0
var _last_child_perc = 0
var _last_bar_perc = 0

var container_hight

var _inner_container # Bad hacky refactor to not add @export to every scroll bar
var inner_scroll_container:Node:
	get:
		if !_inner_container:
			_inner_container = scroll_container.get_child(0)
		return _inner_container

func get_container_scroll_precent()->float:
	var child_container = inner_scroll_container
	if !child_container:
		return 0
	
	var max_scroll = child_container.size.y - scroll_container.size.y
	var current_scroll = -child_container.position.y / max_scroll 
	return current_scroll
	
func set_container_scroll_precent(val:float):
	_last_child_perc = min(1, max(0, val))
	var child_container = inner_scroll_container
	if !child_container:
		printerr("No Child Container Found for Scroll Container")
		return
	
	var max_pos = child_container.size.y - scroll_container.size.y
	var current_pos = _last_child_perc * max_pos 
	child_container.position.y = -current_pos
	#printerr("ScrollBar %s Set Inner Container Position Percent: %s " % [debug_name, _last_child_perc])
	if _last_child_perc != _last_bar_perc:
		set_scroll_bar_position_from_percent(_last_child_perc)


func get_bar_scroll_percent():
	var real_min = 0
	var real_max = scroll_bounds.size.y -bar.size.y
	var real_pos = bar.position.y 
	var percent = real_pos / (real_max - real_min)
	return percent

func set_scroll_bar_position_from_percent(val):
	_last_bar_perc = min(1, max(0, val))
	#printerr("ScrollBar %s Set Bar Position Percent: %s " % [debug_name, _last_bar_perc])
	var max_pos = scroll_bounds.size.y - bar.size.y
	var cur_pos = max_pos * _last_bar_perc
	bar.position.y =  max(0, min(scroll_bounds.size.y - bar.size.y,  cur_pos)) 
	if _last_child_perc != _last_bar_perc:
		set_container_scroll_precent(_last_bar_perc)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bar_button.button_down.connect(button_pressed)
	bar_button.button_up.connect(button_relase)
	if scroll_container:
		#scroll_container.item_rect_changed.connect(calc_bar_size)
		_delay_size_calc = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _delay_size_calc or inner_scroll_container.get_minimum_size().y != container_hight:
		calc_bar_size()
		_delay_size_calc = false
	if dragging:
		var mouse_pos = scroll_bounds.get_local_mouse_position()
		bar.position.y = max(0, min(scroll_bounds.size.y - bar.size.y,  mouse_pos.y - drag_offset))
		var scroll_prec = get_bar_scroll_percent()
		set_scroll_bar_position_from_percent(scroll_prec)
	elif scroll_container:
		# Scroll Container was scrolled on it's own
		var child_pos = inner_scroll_container.position.y
		if child_pos != _last_child_pos:
			_last_child_pos = child_pos
			var scroll_percent = get_container_scroll_precent()
			_last_child_perc = scroll_percent
			set_scroll_bar_position_from_percent(_last_child_perc)
	pass

func button_pressed():
	dragging = true
	var mouse_pos = scroll_bounds.get_local_mouse_position()
	var bar_pos = bar.position
	drag_offset = mouse_pos.y - bar_pos.y

func button_relase():
	dragging = false

func calc_bar_size():
	container_hight = inner_scroll_container.get_minimum_size().y
	var visible_hight = scroll_container.size.y
	var percent_vis = min(1, visible_hight / container_hight)
	#printerr("ScrollBar: %s container: %s | Vis: %s" % [debug_name, container_hight, visible_hight])
	if percent_vis == 1:
		self.hide()
		if opposite_spacer:
			opposite_spacer.show()
	else:
		self.show()
		if opposite_spacer:
			opposite_spacer.hide()
		var cur_percent = get_bar_scroll_percent()
		
		var bounds_hight = scroll_bounds.size.y
		var bar_hight = bounds_hight * percent_vis
		bar.size.y = bar_hight
		set_scroll_bar_position_from_percent(cur_percent)
