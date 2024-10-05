class_name PageEditControl
extends Control

static var Instance:PageEditControl 

@onready var texts_input_control:PageTextsInputControl = $HBoxContainer/TextsInputContainer
@onready var damage_data_control:DamageEditControl = $HBoxContainer/SubActionsContainer/DamageEditControl
@onready var range_edit_control:RangeMakerControl = $HBoxContainer/RangeMaker
@onready var subaction_edit_control:SubActionsEditControl = $HBoxContainer/SubActionsContainer/SubActionsEditControl

@onready var action_option_button:OptionButton = $HBoxContainer/TextsInputContainer/ActionOptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Instance:
		printerr("Page Edit Control already exists")
		self.queue_free()
		return
	Instance = self
	load_action_options()
	action_option_button.item_selected.connect(action_selected)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_damage_datas()->Dictionary:
	return damage_data_control.damage_datas
	
func get_target_params()->Dictionary:
	return range_edit_control.target_datas

func load_page(action_key:String):
	var action:BaseAction = MainRootNode.action_libary.get_action(action_key)
	if not action_key:
		printerr("PageEditControl.load_action: No action with key: " + action_key)
		return
	var data = action.ActionData
	damage_data_control.load_page_data(data)
	range_edit_control.load_page_data(data)
	texts_input_control.load_page_data(data)
	subaction_edit_control.load_page_data(data)

func load_action_options():
	var keys = MainRootNode.action_libary._action_list.keys()
	for key in keys:
		action_option_button.add_item(key)
	if action_option_button.item_count > 0:
		action_option_button.select(0)
		
func action_selected(index):
	load_page(action_option_button.get_item_text(index))
