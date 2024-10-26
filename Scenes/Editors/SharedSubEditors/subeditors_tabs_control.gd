class_name SubEditorsTabControl
extends TabBar

@export var tab_set:String

func get_sub_editors()->Dictionary:
	#TODO: This but not dumb
	if tab_set == "Effects":
		return {
			"StatMods": $"../StatModSubEditContainer",
			"DamageMods": $"../DamageModSubEditContainer",
			"Damage": $"../Damage"
		}
		
	if tab_set == "Actions":
		return {
			"Damage": $"../Damage",
			"Costs": $"../CostSubEditorContainer",
			"Missiles": $"../Missiles",
			"Targets": $"../TargetSubEditorContainer"
		}
	return {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.tab_clicked.connect(on_tab_change)
	_build_tabs()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _build_tabs():
	self.clear_tabs()
	for key in get_sub_editors():
		self.add_tab(key)

func on_tab_change(index:int):
	var selected_tab = self.get_tab_title(index).trim_prefix("*")
	var sub_index = 0
	var subeditors = get_sub_editors()
	for key in subeditors.keys():
		if index >= self.tab_count:
			break
		#var sub_edit_path:NodePath 
		var sub_edit = subeditors[key]
		if sub_edit.has_change():
			self.set_tab_title(sub_index, "*" + key)
		else:
			self.set_tab_title(sub_index, key)
		sub_edit.visible = (key == selected_tab)
		sub_index += 1
