@tool
class_name DetailsEditorContainer
extends BaseSubEditorContainer

@export var object_key_line_edit:LineEdit
@export var display_name_line_edit:LineEdit
@export var snippet_line_edit:LineEdit
@export var description_text_edit:TextEdit
@export var tags_edit_container:TagEditContainer

@export var small_icon_texture_rect:TextureRect
@export var large_icon_texture_rect:TextureRect
@export var small_icon_option_button:LoadedOptionButton
@export var large_icon_option_button:LoadedOptionButton

func get_key_to_input_mapping()->Dictionary:
	return {
		"DisplayName": display_name_line_edit,
		"SnippetDesc": snippet_line_edit,
		"Description": description_text_edit,
		"SmallIcon": small_icon_option_button,
		"LargeIcon": large_icon_option_button,
		"Tags": tags_edit_container
	}

static var _cached_sprite_options:Array = []
static var _cached_sprites:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	small_icon_option_button.get_options_func = get_sprite_options
	small_icon_option_button.get_icons_func = get_sprite_option_icons
	small_icon_option_button.item_selected.connect(on_small_icon_selected)
	large_icon_option_button.get_options_func = get_sprite_options
	large_icon_option_button.get_icons_func = get_sprite_option_icons
	large_icon_option_button.item_selected.connect(on_large_icon_selected)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return


func set_object_key(key:String):
	object_key_line_edit.text = key

func get_object_key()->String:
	return object_key_line_edit.text
	
##############################
### Editor Ui Node Methods
##############################
func lose_focus_if_has():
	super()

func has_change():
	if small_icon_option_button.get_current_option_text() != _loaded_data.get("SmallIcon", ""):
		return true
	if large_icon_option_button.get_current_option_text() != _loaded_data.get("LargeIcon", ""):
		return true
	return super()

func clear():
	super()
	_cached_sprites.clear()
	_cached_sprite_options.clear()
	object_key_line_edit.text = ""
	large_icon_texture_rect.texture = null
	small_icon_texture_rect.texture = null

func load_data(object_key:String, data:Dictionary):
	super(object_key, data)
	load_icon(small_icon_texture_rect, _loaded_data.get("SmallIcon", ""))
	load_icon(large_icon_texture_rect, _loaded_data.get("LargeIcon", ""))

func build_save_data()->Dictionary:
	return super()
##############################


func get_sprite_options()->Array:
	if _cached_sprite_options.size() == 0:
		var files = root_editor_control.search_current_directory(".png", false)
		for file in files:
			_cached_sprite_options.append(file.get_file())
	return _cached_sprite_options

func get_sprite_option_icons()->Dictionary:
	if _cached_sprites.size() == 0:
		var curent_dir = root_editor_control.get_current_directory()
		for option in get_sprite_options():
			var sprite_path = curent_dir.path_join(option)
			var texture = load(sprite_path)
			if !texture:
				printerr("Failed to load sprite: %s" % [sprite_path])
				texture = load(ActionLibrary.NO_ICON_SPRITE)
			_cached_sprites[option] = texture
	return _cached_sprites

func on_small_icon_selected(index:int):
	load_icon(small_icon_texture_rect, small_icon_option_button.get_current_option_text())
func on_large_icon_selected(index:int):
	load_icon(large_icon_texture_rect, large_icon_option_button.get_current_option_text())

func load_icon(rect:TextureRect, sprite_name):
	if sprite_name == "":
		rect.texture = null
		return
	var curent_dir = root_editor_control.get_current_directory()
	var sprite_path = curent_dir.path_join(sprite_name)
	var texture = load(sprite_path)
	if !texture:
		printerr("Failed to load sprite: %s" % [sprite_path])
		texture = load(ActionLibrary.NO_ICON_SPRITE)
	rect.texture = texture
	
