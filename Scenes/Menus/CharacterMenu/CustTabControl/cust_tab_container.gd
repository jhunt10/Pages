@tool
class_name CustTabContainer
extends HBoxContainer

signal tab_selected(index:int, tab_key:String)

var __cur_tab_index:int = 0
@export var current_tab_index:int:
	get:
		return __cur_tab_index
	set(val):
		_set_current_tab(val)

@export var tabs:Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for tab_index in range(tabs.size()):
		var node = get_tab_by_index(tab_index)
		node.button.pressed.connect(_on_tab_button_pressed.bind(tab_index))
	

func get_tab_by_index(index:int)->CustomTabTab:
	if index < 0 and index >= tabs.size():
		printerr("CustTabContainer: Invalid index: " + str(index))
		return null
	var node = tabs[index]
	if node is NodePath:
		node = get_node(node)
	if not node is CustomTabTab:
		printerr("CustTabContainer: Child is not a CustomTabTab")
		return null
	return node as CustomTabTab

func set_tab_by_key(key:String):
	for tab_index in range(tabs.size()):
		var node = get_tab_by_index(tab_index)
		if node.tab_key == key:
			_set_current_tab(tab_index)
			return
	printerr("CustTabContainer.set_tab_by_key: Unknown key '%s'." % [key])
	_set_current_tab(0)
	

func _set_current_tab(val):
	if !tabs:
		return
	if val >= 0 and val < tabs.size():
		__cur_tab_index = val
	else:
		__cur_tab_index = 0
	
	# Apply Tab Styles
	for tab_index in range(tabs.size()):
		var node = get_tab_by_index(tab_index)
		if !node:
			continue
		var tab = node as CustomTabTab
		# Set Selected Tab style
		if tab_index == __cur_tab_index:
			tab.label.add_theme_color_override("font_color", Color.BLACK)
		# Set Unselected Tab style
		else:
			tab.label.remove_theme_color_override("font_color")

func _on_tab_button_pressed(index):
	_set_current_tab(index)
	var tab = get_tab_by_index(index)
	tab_selected.emit(index, tab.tab_key)

func set_new_item_groups(groups:Dictionary):
	for tab_index in range(tabs.size()):
		var node = get_tab_by_index(tab_index)
		if !node:
			continue
		if groups.keys().has(node.tab_key) and groups[node.tab_key].size() > 0:
			node.plus_icon.show()
		else:
			node.plus_icon.hide()
		
