class_name OnQueOptionsMenu
extends BackPatchContainer

@export var options_container:VBoxContainer
@export var title_lable:Label
@export var parent_que_input:QueInputControl

var _action_key:String
var _options_to_show:Array
var _current_option_data:OnQueOptionsData
var _selected_options:Dictionary

var _on_all_options_selected:Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if !_current_option_data:
		return
	
	var mouse_pos = options_container.get_local_mouse_position()
	var options_rect = Rect2(Vector2.ZERO, options_container.size)
	# Mouse Exited Area
	if not options_rect.grow(32).has_point(mouse_pos):
		clear_and_hide()
	pass

func load_options(action_key:String, options:Array, on_finish_func:Callable):
	_action_key = action_key
	_options_to_show = options
	_on_all_options_selected = on_finish_func
	if _options_to_show.size() > 0:
		_current_option_data = _options_to_show[0]
		_options_to_show.remove_at(0)
		_build_option_buttons(_current_option_data)

func clear_and_hide():
	_current_option_data = null
	_action_key = ''
	_options_to_show.clear()
	_selected_options.clear()
	for child in options_container.get_children():
		child.queue_free()
	self.visible = false

func on_option_selectec(key, value):
	_selected_options[key] = value
	if _options_to_show.size() > 0:
		_current_option_data = _options_to_show[0]
		_options_to_show.remove_at(0)
		_build_option_buttons(_current_option_data)
	else:
		_on_all_options_selected.call(_action_key, _selected_options.duplicate())
		clear_and_hide()

func _build_option_buttons(option_data:OnQueOptionsData):
	var button_count = 0
	for child in options_container.get_children():
		child.queue_free()
	_current_option_data = option_data
	title_lable.text = option_data.title_text
	for option in _current_option_data.options_arr:
		var button:Button = Button.new()
		button.custom_minimum_size = Vector2i(0,32)
		button.text = option
		options_container.add_child(button)
		button.pressed.connect(on_option_selectec.bind(_current_option_data.option_key, option))
		button_count += 1
	self.size = Vector2i(self.size.x, (button_count * 32) + 24)
	self.position.y -= self.size.y
