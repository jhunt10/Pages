class_name ItemSelectMenuControl
extends Control

signal on_item_selected(item_id:String)

@onready var menu_panel:Control = $MenuPanel
@onready var button_container:VBoxContainer = $MenuPanel/VBoxContainer
#
#var buttons:Array = []
#var _item_holder:BaseItemBag
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	#
#func set_items(item_holder:BaseItemBag):
	#_item_holder = item_holder
	#_build_buttons()
	#
#
#func _build_buttons():
	#while buttons.size() > 0:
		#buttons[buttons.size()-1].queue_free()
		#buttons.remove_at(buttons.size()-1)
		#
	#for i in range(0, _item_holder._max_slots):
		#var item:BaseItem = _item_holder.get_item_in_slot(i)
		#var new_button:Button = Button.new()
		#button_container.add_child(new_button)
		#new_button.visible = true
		#if not item:
			#new_button.text = "---"
			#new_button.disabled = true
		#else:
			#new_button.text = item.DisplayName
			#if _item_holder.is_item_id_qued(item.Id):
				#new_button.disabled = true
				#new_button.text = "-" + item.DisplayName
			#new_button.button_down.connect(_on_button_pressed.bind(item.Id))
			#new_button.mouse_entered.connect(_on_button_enter.bind(item.Id))
			#new_button.mouse_exited.connect(_on_button_exit.bind(item.Id))
		#
		#buttons.append(new_button)
	#menu_panel.size = Vector2i(menu_panel.size.x, _item_holder._max_slots * 31)
#
#func _on_button_pressed(item_id):
	#on_item_selected.emit(item_id)
	#
#func _on_button_enter(item_id):
	#pass
#func _on_button_exit(item_id):
	#pass
