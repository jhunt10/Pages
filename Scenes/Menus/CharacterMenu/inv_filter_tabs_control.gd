class_name ItemFilterTabsControl
extends Control

signal on_tab_selected(tab_name:String)
signal on_tab_unselected(tab_name:String)

@export var premade_sub_tab:SubInventoryTab

var _tabs:Dictionary = {}

func _ready() -> void:
	premade_sub_tab.visible = false

func set_tabs(arr:Array):
	for tab in get_children():
		if tab != premade_sub_tab:
			tab.queue_free()
	_tabs.clear()
	for val in arr:
		var new_tab:SubInventoryTab = premade_sub_tab.duplicate()
		self.add_child(new_tab)
		new_tab.position = Vector2i(0, (premade_sub_tab.size.y + 8) * _tabs.size())
		new_tab.filter_name = val
		new_tab.visible = true
		new_tab.button.pressed.connect(on_tab_pressed.bind(val))
		_tabs[val] = new_tab

func on_tab_pressed(name_val:String):
	if _tabs[name_val].is_selected:
		_tabs[name_val].is_selected = false
		on_tab_unselected.emit(name_val)
	else:
		_tabs[name_val].is_selected = true
		on_tab_selected.emit(name_val)
	pass
