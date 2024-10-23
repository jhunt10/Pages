@tool
class_name DetailsEditorContainer
extends BaseSubEditorContainer

@export var object_key_line_edit:LineEdit
@export var display_name_line_edit:LineEdit
@export var snippet_line_edit:LineEdit
@export var description_text_edit:TextEdit
@export var tags_edit_container:TagEditContainer

func get_key_to_input_mapping()->Dictionary:
	return {
		"DisplayName": display_name_line_edit,
		"SnippetDesc": snippet_line_edit,
		"Description": description_text_edit,
		"SmallIcon": small_icon_option_button,
		"LargeIcon": large_icon_option_button,
		"Tags": tags_edit_container
	}

@export var small_icon_texture_rect:TextureRect
@export var large_icon_texture_rect:TextureRect
@export var small_icon_option_button:LoadedOptionButton
@export var large_icon_option_button:LoadedOptionButton

var _cached_sprite_options:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	small_icon_option_button.get_options_func = get_sprite_options
	small_icon_option_button.item_selected.connect(on_small_icon_selected)
	large_icon_option_button.get_options_func = get_sprite_options
	large_icon_option_button.item_selected.connect(on_large_icon_selected)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if Engine.is_editor_hint(): return
	if has_change():
		printerr("Change!!")
	pass


##############################
### Editor Ui Node Methods
##############################
func lose_focus_if_has():
	super()

func has_change():
	return super()

func load_data(object_key:String, data:Dictionary):
	super(object_key, data)
	object_key_line_edit.text = object_key
	load_icon(small_icon_texture_rect, _loaded_data.get("SmallIcon", ""))
	load_icon(large_icon_texture_rect, _loaded_data.get("LargeIcon", ""))

func build_save_data()->Dictionary:
	return super()
##############################


func get_sprite_options()->Array:
	if _cached_sprite_options.size() == 0:
		var files = root_editor_control.search_current_directory(".png")
		for file in files:
			_cached_sprite_options.append(file.get_file())
	return _cached_sprite_options

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
	
