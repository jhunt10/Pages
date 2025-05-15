class_name ItemSelectionInputDisplay
extends Control

@export var titile_label:Label
@export var options_container:VBoxContainer
@export var premade_item_button:ItemSelection_Button
@export var cancel_button:Button
@export var menu_container:BackPatchContainer

var _action_key:String
var _options_to_show:Array
var _current_option_data:OnQueOptionsData
var _selected_options:Dictionary

var _on_all_options_selected:Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cancel_button.pressed.connect(self.clear_and_hide)
	premade_item_button.hide()
	pass # Replace with function body.

## Set a list of OnQueOptionsData to be selected one at a time
func load_options(action_key:String, options:Array, on_finish_func:Callable):
	_action_key = action_key
	_options_to_show = options
	_on_all_options_selected = on_finish_func
	if _options_to_show.size() > 0:
		_current_option_data = _options_to_show[0]
		_options_to_show.remove_at(0)
		_build_option_buttons(_current_option_data)
	


func _build_option_buttons(option_data):
	#var button_count = 0
	for child in options_container.get_children():
		if child != premade_item_button:
			child.queue_free()
	_current_option_data = option_data
	titile_label.text = option_data.title_text
	for index in range(_current_option_data.options_vals.size()):
		var button:ItemSelection_Button = premade_item_button.duplicate()
		button.label.text = _current_option_data.option_texts[index]
		if _current_option_data.option_icons.size() > index:
			button.icon.texture = _current_option_data.option_icons[index]
		else:
			button.icon.hide()
		button.button.pressed.connect(on_option_selectec.bind(_current_option_data.option_key, _current_option_data.options_vals[index]))
		if _current_option_data.disable_options.size() > 0 and _current_option_data.disable_options[index]:
			button.disable()
		options_container.add_child(button)
		#button_count += 1
		button.show()

func on_option_selectec(key, value):
	var selected_index = _current_option_data.options_vals.find(value)
	_selected_options[key] = value
	if _current_option_data.option_icons.size() > selected_index:
		_selected_options['OverrideQueIcon'] = _current_option_data.option_icons[selected_index]
	if _options_to_show.size() > 0:
		_current_option_data = _options_to_show[0]
		_options_to_show.remove_at(0)
		_build_option_buttons(_current_option_data)
	else:
		_on_all_options_selected.call(_action_key, _selected_options.duplicate())
		clear_and_hide()

func clear_and_hide():
	_current_option_data = null
	_action_key = ''
	_options_to_show.clear()
	_selected_options.clear()
	for child in options_container.get_children():
		child.queue_free()
	self.visible = false
