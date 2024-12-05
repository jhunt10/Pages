class_name SubBookContainer
extends VBoxContainer

signal page_item_button_down(tag, index, offset)
signal page_item_button_up(tag, index)
signal mouse_enter_item(tag, index)
signal mouse_exit_item(tag, index)

@export var slot_width:int = 4
@export var title_label:Label
@export var background_tilemap:TileMapLayer
var page_slots_containers:Array = []
var _pages_tag:String
var _buttons:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func estimate_hight()->float:
	return title_label.size.y + (page_slots_containers.size() * 64)

func set_sub_book_data(tag, slots):
	_pages_tag = tag
	title_label.text = tag
	var x = 0
	var y = -1
	var tile_mapping = []
	for i in range(slots.size()):
		if i % (slot_width) == 0:
			x = 0
			y += 1
			var new_row = HBoxContainer.new()
			self.add_child(new_row)
			new_row.add_theme_constant_override("separation", 0)
			page_slots_containers.append(new_row)
		
		var new_button = load("res://Scenes/Menus/CharacterMenu/MenuPages/PageMenuPage/page_slot_button.tscn").instantiate()
		new_button.button.button_down.connect(on_slot_button_down.bind(i))
		new_button.button.button_up.connect(on_slot_button_up.bind(i))
		new_button.button.mouse_entered.connect(on_mouse_enter_slot.bind(i))
		new_button.button.mouse_exited.connect(on_mouse_exit_slot.bind(i))
		page_slots_containers[page_slots_containers.size()-1].add_child(new_button)
		_buttons.append(new_button)
		new_button.set_key(slots[i])
		new_button.visible = true
		tile_mapping.append(Vector2i(x,y))
		x += 1
	background_tilemap.clear()
	background_tilemap.set_cells_terrain_connect(tile_mapping, 0, 0)

func clear_highlights():
	for button in _buttons:
		button.hide_highlight()

func highlight_slot(index):
	if index >= 0 and index < _buttons.size():
		_buttons[index].show_highlight()

func on_slot_button_down(index:int):
	var button = _buttons[index]
	var offset = button.get_local_mouse_position()
	page_item_button_down.emit(_pages_tag, index, offset)
	
func on_slot_button_up(index:int):
	page_item_button_up.emit(_pages_tag, index)

func on_mouse_enter_slot(index):
	mouse_enter_item.emit(_pages_tag, index)
func on_mouse_exit_slot(index):
	mouse_exit_item.emit(_pages_tag, index)
