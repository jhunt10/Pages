class_name SubBookContainer
extends VBoxContainer

@export var slot_width:int = 4
@export var title_label:Label
@export var background_tilemap:TileMapLayer
var page_slots_containers:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func estimate_hight()->float:
	return title_label.size.y + (page_slots_containers.size() * 64)

func set_sub_book_data(tag, slots):
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
		new_button.get_child(1).pressed.connect(on_slot_pressed.bind(i))
		page_slots_containers[page_slots_containers.size()-1].add_child(new_button)
		new_button.set_key(slots[i])
		new_button.visible = true
		tile_mapping.append(Vector2i(x,y))
		x += 1
	background_tilemap.clear()
	background_tilemap.set_cells_terrain_connect(tile_mapping, 0, 0)

func on_slot_pressed(index:int):
	print("ButtonPresed!")
