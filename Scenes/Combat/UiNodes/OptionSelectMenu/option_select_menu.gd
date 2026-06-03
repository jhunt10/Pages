class_name OptionSelectMenu
extends Control

signal menu_closed()

@export var titile_label:Label
@export var options_container:VBoxContainer
@export var premade_option_button:OptionSelectButton
@export var premade_option_divider:OptionSelectDivider
@export var close_button:TextureButton
@export var cancel_button:Button
@export var confrim_button:Button

var _selecting_key:String
var _options_to_show:Array
var _current_option_data:OnQueOptionsData
var _selected_options:Dictionary

var _on_all_options_selected:Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cancel_button.pressed.connect(self.clear_and_hide)
	close_button.pressed.connect(self.clear_and_hide)
	premade_option_button.hide()
	premade_option_divider.hide()

## Set a list of OnQueOptionsData to be selected one at a time
func set_options(selecting_key:String, options:Array, on_finish_func:Callable):
	_selecting_key = selecting_key
	_options_to_show = options
	_on_all_options_selected = on_finish_func
	if _options_to_show.size() > 0:
		_current_option_data = _options_to_show[0]
		_options_to_show.remove_at(0)
		_build_option_buttons(_current_option_data)
	self.show()

func _build_option_buttons(option_data):
	for child in options_container.get_children():
		if child != premade_option_button:
			child.queue_free()
			
	_current_option_data = option_data
	titile_label.text = option_data.title_text
	
	for index in range(_current_option_data.options_datas.size()):
		var data = _current_option_data.options_datas[index]
		if data.has("DividerText"):
			var divider:OptionSelectDivider = premade_option_divider.duplicate()
			divider.label.text = data['DividerText']
			options_container.add_child(divider)
			divider.show()
		else:
			var button:OptionSelectButton = premade_option_button.duplicate()
			var option_text = data['Text']
			button.label.text = option_text
			if data.has("Icon"):
				button.icon.texture = data['Icon']
			else:
				button.icon.hide()
			button.button.pressed.connect(on_option_selected.bind(index))
			if data['Disabled']:
				button.disable()
			options_container.add_child(button)
			button.show()
		

func on_option_selected(index):
	var option_data = _current_option_data.options_datas[index]
	_selected_options[_current_option_data.option_key] = option_data['Value']
	if option_data.has("Icon"):
		_selected_options['OverrideQueIcon'] = option_data['Icon']
	
	# More options to be selected
	if _options_to_show.size() > 0:
		_current_option_data = _options_to_show[0]
		_options_to_show.remove_at(0)
		_build_option_buttons(_current_option_data)
	# We're done
	else:
		_on_all_options_selected.call(_selecting_key, _selected_options.duplicate())
		clear_and_hide()

func clear_and_hide():
	_current_option_data = null
	_selecting_key = ''
	_options_to_show.clear()
	_selected_options.clear()
	for child in options_container.get_children():
		child.queue_free()
	self.visible = false
	menu_closed.emit()
