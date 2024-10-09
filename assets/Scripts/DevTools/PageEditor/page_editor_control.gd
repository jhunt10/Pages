class_name PageEditControl
extends Control

static var Instance:PageEditControl 

@onready var file_edit_control:PageFileEditControl = $VBoxContainer/TopBarContainer/PageFileEditControl
@onready var sprite_edit_control:PageSpriteEditControl = $VBoxContainer/HBoxContainer/RightBoxContainer/PageSpriteEditControl
@onready var texts_input_control:PageTextsInputControl = $VBoxContainer/HBoxContainer/LeftVBoxContainer/PageTextsInputsControl
@onready var damage_data_control:DamageEditControl = $VBoxContainer/HBoxContainer/RightBoxContainer/TabContainer/Damage
@onready var missile_data_control:MissileEditControl = $VBoxContainer/HBoxContainer/RightBoxContainer/TabContainer/Missiles
@onready var range_edit_control:RangeMakerControl = $VBoxContainer/HBoxContainer/RightBoxContainer/TabContainer/Targeting
@onready var subaction_edit_control:SubActionsEditControl = $VBoxContainer/HBoxContainer/MiddleVBoxContainer/SubActionsEditControl
@onready var cost_edit_control:CostEditControl = $VBoxContainer/HBoxContainer/MiddleVBoxContainer/CostEditControl

@onready var popup_message_box:PopUpWarningControl = $PopupWarningControl
@onready var file_option_button:LoadedOptionButton = $VBoxContainer/TopBarContainer/PageEditSelectionControl/VBoxContainer/HBoxContainer/FileOptionButton
@onready var page_option_button:LoadedOptionButton = $VBoxContainer/TopBarContainer/PageEditSelectionControl/VBoxContainer/HBoxContainer2/PageOptionButton

var known_files:Array = []
var selected_file:String = ''
var action_datas:Dictionary = {}
var selected_full_action_key:String = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Instance:
		printerr("Page Edit Control already exists")
		self.queue_free()
		return
	Instance = self
	file_edit_control.parent_edit_control = self
	file_option_button.get_options_func = get_file_options
	page_option_button.get_options_func = get_page_options
	file_option_button.item_selected.connect(on_file_option_selected)
	page_option_button.item_selected.connect(on_page_option_selected)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ENTER:
		file_edit_control.lose_focus_if_has()
		subaction_edit_control.lose_focus_if_has()
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE:
		exit_menu()
		
func exit_menu():
		Instance = null
		self.queue_free()
		MainRootNode.action_libary.reload_pages()
	
func get_missile_datas()->Dictionary:
	return missile_data_control.missile_datas

func get_damage_datas()->Dictionary:
	return damage_data_control.damage_datas
	
func get_target_params()->Dictionary:
	return range_edit_control.target_datas

func load_page(action_data:Dictionary):
	file_edit_control.set_load_path(file_option_button.get_current_option_text())
	damage_data_control.load_page_data(action_data)
	missile_data_control.load_page_data(action_data)
	range_edit_control.load_page_data(action_data)
	texts_input_control.load_page_data(action_data)
	subaction_edit_control.load_page_data(action_data)
	sprite_edit_control.load_page_data(action_data)
	cost_edit_control.load_page_data(action_data)

func load_action_options_from_file(file_path):
	if selected_file == file_path:
		return
	selected_file = file_path
	action_datas = ActionLibary.parse_action_datas_from_file(file_path)
	page_option_button.load_options()

func on_file_option_selected(index:int):
	var file = known_files[index]
	if selected_file == file:
		return
	selected_full_action_key = ''
	load_action_options_from_file(file)
	load_page({})
	
func on_page_option_selected(index:int):
	var page_key = page_option_button.get_item_text(index)
	var full_page_key = selected_file + ":" + page_key
	if selected_full_action_key == full_page_key:
		return
	selected_full_action_key = full_page_key
	var page_data = action_datas[page_key]
	load_page(page_data)

func get_file_options()->Array:
	var files = ActionLibary.search_for_action_files()
	known_files = files
	return files
func get_page_options()->Array:
	return action_datas.keys()
	
func save_page_data(force_overide:bool=false):
	var file_name = file_edit_control.get_full_fill_path()
	
	var new_page_data:Dictionary = texts_input_control.save_page_data()
	new_page_data['LargeSprite'] = sprite_edit_control.large_sprite_option.get_current_option_text()
	new_page_data['SmallSprite'] = sprite_edit_control.small_sprite_option.get_current_option_text()
	new_page_data['DamageDatas'] = damage_data_control.save_page_data()
	new_page_data['MissileDatas'] = missile_data_control.save_page_data()
	new_page_data['TargetParams'] = range_edit_control.save_page_data()
	new_page_data['SubActions'] = subaction_edit_control.save_page_data()
	new_page_data['CostData'] = cost_edit_control.save_page_data()
	
	var existing_data = {}
	var file_exists = false
	if FileAccess.file_exists(file_name):
		file_exists = true
		existing_data = ActionLibary.parse_action_datas_from_file(file_name)
	var page_exists = existing_data.keys().has(new_page_data['ActionKey'])
	if not force_overide and file_exists:
		popup_message_box.show_pop_up("File exists. Override?", save_page_data.bind(true))
		return
	existing_data[new_page_data['ActionKey']] = new_page_data
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	file.store_string(JSON.stringify(existing_data.values()))
	file.close()
	load_action_options_from_file(file_name)
