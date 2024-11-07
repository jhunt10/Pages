class_name EffectSpriteEditControl
extends Control
#
#@onready var large_sprite_rect:TextureRect = $HBoxContainer/HBoxContainer/LargeSpriteBackground/LargeSpriteDisplay
#@onready var small_sprite_rect:TextureRect = $HBoxContainer/HBoxContainer/VBoxContainer/SmallSpriteBackground/SmallSpriteDisplay
#
#@onready var large_sprite_option:LoadedOptionButton = $HBoxContainer/VBoxContainer/HBoxContainer/LoadedOptionButton
#@onready var small_sprite_option:LoadedOptionButton = $HBoxContainer/VBoxContainer/HBoxContainer2/LoadedOptionButton
#
#var connected = false
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#large_sprite_option.get_options_func = get_sprite_options
	#large_sprite_option.item_selected.connect(_on_sprite_selected)
	#small_sprite_option.get_options_func = get_sprite_options
	#small_sprite_option.item_selected.connect(_on_sprite_selected)
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#
#func lose_focus_if_has():
	#pass
#
#func load_effect_data(data:Dictionary):
	#if not connected:
		#connected = true
		#EffectEditorControl.Instance.file_edit_control.file_changed.connect(_on_file_path_change)
	#var small_sprite_file_name = data.get('SmallSprite', '')
	#var large_sprite_file_name = data.get('LargeSprite', '')
	#small_sprite_option.load_options(small_sprite_file_name)
	#large_sprite_option.load_options(large_sprite_file_name)
	#_sync_sprites()
#
#func _on_sprite_selected(option:int):
	#_sync_sprites()
#
#func _on_file_path_change():
	#if small_sprite_option.selected >= 0:
		#var sprite_file_name = small_sprite_option.get_item_text(small_sprite_option.selected)
		#small_sprite_option.load_options(sprite_file_name)
	#if large_sprite_option.selected >= 0:
		#var sprite_file_name = large_sprite_option.get_item_text(large_sprite_option.selected)
		#large_sprite_option.load_options(sprite_file_name)
	#_sync_sprites()
	#
#
#func _sync_sprites():
	#var load_path:String = EffectEditorControl.Instance.file_edit_control.get_load_path()
	#
	#small_sprite_rect.visible = false
	#if small_sprite_option.selected >= 0:
		#var sprite_file_name = small_sprite_option.get_item_text(small_sprite_option.selected)
		#var full_file = load_path.path_join(sprite_file_name)
		#if FileAccess.file_exists(full_file):
			#small_sprite_rect.texture = load(full_file)
			#small_sprite_rect.visible = true
			#
	#large_sprite_rect.visible = false
	#if large_sprite_option.selected >= 0:
		#var sprite_file_name = large_sprite_option.get_item_text(large_sprite_option.selected)
		#var full_file = load_path.path_join(sprite_file_name)
		#if FileAccess.file_exists(full_file):
			#large_sprite_rect.texture = load(full_file)
			#large_sprite_rect.visible = true
#
#
#func get_sprite_options()->Array:
	#if EffectEditorControl.Instance and EffectEditorControl.Instance.file_edit_control:
		#return _search_for_sprites(EffectEditorControl.Instance.file_edit_control.get_load_path())
	#return []
#
#func _search_for_sprites(path:String):
	#var list = []
	#var dir = DirAccess.open(path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name:String = dir.get_next()
		#while file_name != "":
			#var full_path = path.path_join(file_name)
			#if file_name.ends_with(".png"):
				#list.append(file_name)
			#file_name = dir.get_next()
	##else:
		##print("An error occurred when trying to access the path: " + path)
	#return list
