class_name SubEditorsTabControl
extends TabBar


@export var damage_tab:DamageSubEditorContainer
@export var costs_tab:CostSubEditorContainer
@export var missiles_tab:MissileSubEditorContainer

func get_subeditor_tabs()->Dictionary:
	return {
		"Damage": damage_tab,
		"Costs": costs_tab,
		"Missiles": missiles_tab,
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.tab_changed.connect(on_tab_change)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_tab_change(index:int):
	var sub_tabs = get_subeditor_tabs()
	var selected_tab = self.get_tab_title(index).trim_prefix("*")
	if !sub_tabs.keys().has(selected_tab):
		return
	
	var sub_index = 0
	for key in sub_tabs.keys():
		var sub_edit:BaseSubEditorContainer = sub_tabs[key]
		if sub_edit.has_change():
			self.set_tab_title(sub_index, "*" + key)
		else:
			self.set_tab_title(sub_index, key)
		sub_edit.visible = (key == selected_tab)
		sub_index += 1
