class_name ShopItemMenuController
extends NinePatchRect

signal back_button_pressed()
signal catagory_selected(sub_list)
signal item_button_pressed(item_key:String)

@export var entries_container:VBoxContainer
@export var premade_sub_item_list:ShopSubItemList
@export var back_button:Button

var _catagory_sub_lists:Dictionary = {}

func _ready() -> void:
	premade_sub_item_list.hide()
	back_button.pressed.connect(back_button_pressed.emit)

func set_data(data:Dictionary):
	for old_cat in _catagory_sub_lists.keys():
		if not data.keys().has(old_cat):
			
			print("Deleteing Cat: " + str(old_cat))
			_catagory_sub_lists[old_cat].queue_free()
			_catagory_sub_lists.erase(old_cat)
		else:
			print("Keeping Cat: " + str(old_cat))
			entries_container.remove_child(_catagory_sub_lists[old_cat])
	
	for cat in data.keys():
		print("Creating Cat: " + str(cat))
		var item_id_list = data[cat]
		var sub_list:ShopSubItemList = null
		if _catagory_sub_lists.keys().has(cat):
			sub_list = _catagory_sub_lists[cat]
		else:
			sub_list = premade_sub_item_list.duplicate()
			sub_list.parent_controller = self
			sub_list.title_button.pressed.connect(_on_show_catagory.bind(cat))
			_catagory_sub_lists[cat] = sub_list
		entries_container.add_child(sub_list)
		sub_list.set_item_list(cat, item_id_list)
		sub_list.state = ShopSubItemList.States.Hidden
		sub_list.show()


func _on_item_button_pressed(item_key):
	item_button_pressed.emit(item_key)

func _on_show_catagory(selected_catagory:String):
	for catagory in _catagory_sub_lists.keys():
		var sub_list:ShopSubItemList = _catagory_sub_lists[catagory]
		if catagory == selected_catagory:
			sub_list.showing = true
			catagory_selected.emit(sub_list)
		else:
			sub_list.showing = false
	
