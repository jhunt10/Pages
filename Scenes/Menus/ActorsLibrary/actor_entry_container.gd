extends HBoxContainer






func set_actor_and_values(actor:BaseActor, stat_names:Array, parent_control):
	var icon:TextureRect = $IconRect
	var premade_label:Label = $Label
	var column_seperator:VSeparator = $VSeparator
	if !actor:
		return
	var icon_texture = actor.get_large_icon()
	icon.texture = icon_texture
	icon.mouse_entered.connect(parent_control.on_mouse_enter_actor_icon.bind(actor.Id))
	icon.mouse_exited.connect(parent_control.on_mouse_leaves)
	for stat_name in stat_names:
		var stat_val = actor.stats.get_stat(stat_name)
		var new_label = premade_label.duplicate()
		new_label.text = str(stat_val)
		new_label.mouse_entered.connect(parent_control.on_mouse_enter_stat_label.bind(actor.Id, stat_name))
		new_label.mouse_exited.connect(parent_control.on_mouse_leaves)
		
		self.add_child(new_label)
		self.add_child(column_seperator.duplicate())
	premade_label.hide()
	
