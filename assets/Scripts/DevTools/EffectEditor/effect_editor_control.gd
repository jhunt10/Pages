#class_name EffectEditorControl
#extends Control
#
#static var Instance:EffectEditorControl 
#
#@onready var file_edit_control:PageFileEditControl = $MainContainer/TopBarContainer/EffectFileEditControl
#@onready var sprite_edit_control:EffectSpriteEditControl =$MainContainer/PanelsContainer/RightBoxContainer/SpriteEditControl
#@onready var texts_input_control:EffectTextsInputControl = $MainContainer/PanelsContainer/LeftVBoxContainer/EffectTextsInputsControl
#@onready var subeffect_edit_control:SubEffectEditControl = $MainContainer/PanelsContainer/MiddleVBoxContainer/SubEffectEditControl
#@onready var stat_mod_edit_control:StatModEditControl = $"MainContainer/PanelsContainer/RightBoxContainer/TabContainer/Stat Mods"
#@onready var damage_mod_edit_control:DamageModEditControl = $"MainContainer/PanelsContainer/RightBoxContainer/TabContainer/Damage Mods"
#
#@onready var popup_message_box:PopUpWarningControl = $PopupWarningControl
#@onready var file_option_button:LoadedOptionButton = $MainContainer/TopBarContainer/EditSelectionControl/VBoxContainer/HBoxContainer/FileOptionButton
#@onready var effect_option_button:LoadedOptionButton = $MainContainer/TopBarContainer/EditSelectionControl/VBoxContainer/HBoxContainer2/EffectOptionButton
#
#var known_files:Array = []
#var selected_file:String = ''
#var effect_datas:Dictionary = {}
#var selected_full_effect_key:String = ''
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#if Instance:
		#printerr("Effect Edit Control already exists")
		#self.queue_free()
		#return
	#Instance = self
	#file_edit_control.parent_edit_control = self
	#file_option_button.get_options_func = get_file_options
	#effect_option_button.get_options_func = get_effect_options
	#file_option_button.item_selected.connect(on_file_option_selected)
	#effect_option_button.item_selected.connect(on_effect_option_selected)
	#
	#pass # Replace with function body.
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#
#func _input(event: InputEvent) -> void:
	#if event is InputEventKey and (event as InputEventKey).keycode == KEY_ENTER:
		#lose_focus_if_has()
	#if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE:
		#exit_menu()
#
#func lose_focus_if_has():
	#file_edit_control.lose_focus_if_has()
	#stat_mod_edit_control.lose_focus_if_has()
	#damage_mod_edit_control.lose_focus_if_has()
	#subeffect_edit_control.lose_focus_if_has()
#
#func exit_menu():
	#Instance = null
	#MainRootNode.effect_libary.reload_effects()
	#self.queue_free()
		#
#func load_effect(effect_data:Dictionary):
	#file_edit_control.set_load_path(file_option_button.get_current_option_text())
	#sprite_edit_control.load_effect_data(effect_data)
	#stat_mod_edit_control.load_effect_data(effect_data)
	#damage_mod_edit_control.load_effect_data(effect_data)
	#texts_input_control.load_effect_data(effect_data)
	#subeffect_edit_control.load_effect_data(effect_data)
##
#func load_effect_options_from_file(file_path):
	#if selected_file == file_path:
		#return
	#selected_file = file_path
	#effect_datas = EffectLibary.parse_effect_datas_from_file(file_path)
	#effect_option_button.load_options()
##
#func on_file_option_selected(index:int):
	#var file = known_files[index]
	#if selected_file == file:
		#return
	#selected_full_effect_key = ''
	#load_effect_options_from_file(file)
	#load_effect({})
	##
#func on_effect_option_selected(index:int):
	#var effect_key = effect_option_button.get_item_text(index)
	#var full_effect_key = selected_file + ":" + effect_key
	#if selected_full_effect_key == full_effect_key:
		#return
	#selected_full_effect_key = full_effect_key
	#var effect_data = effect_datas[effect_key]
	#load_effect(effect_data)
##
#func get_file_options()->Array:
	#var files = EffectLibary.search_for_effect_files()
	#known_files = files
	#return files
#func get_effect_options()->Array:
	#return effect_datas.keys()
	#
#func get_stat_mods()->Array:
	#return stat_mod_edit_control.stat_mod_datas.keys()
	#
	#
#func save_data(force_overide:bool=false):
	#var file_name = file_edit_control.get_full_fill_path()
	#
	#var new_data:Dictionary = texts_input_control.save_effect_data()
	#new_data['LargeSprite'] = sprite_edit_control.large_sprite_option.get_current_option_text()
	#new_data['SmallSprite'] = sprite_edit_control.small_sprite_option.get_current_option_text()
	#new_data['StatMods'] = stat_mod_edit_control.save_effect_data()
	#new_data['DamageMods'] = damage_mod_edit_control.save_effect_data()
	#new_data['SubEffects'] = subeffect_edit_control.save_effect_data()
	#
	#var existing_data = {}
	#var file_exists = false
	#if FileAccess.file_exists(file_name):
		#file_exists = true
		#existing_data = EffectLibary.parse_effect_datas_from_file(file_name)
	#var effect_exists = existing_data.keys().has(new_data['EffectKey'])
	#if not force_overide and file_exists:
		#popup_message_box.show_pop_up("File exists. Override?", save_data.bind(true))
		#return
	#existing_data[new_data['EffectKey']] = new_data
	#var file = FileAccess.open(file_name, FileAccess.WRITE)
	#file.store_string(JSON.stringify(existing_data.values()))
	#file.close()
	#load_effect_options_from_file(file_name)
