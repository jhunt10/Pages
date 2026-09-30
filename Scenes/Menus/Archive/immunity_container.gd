class_name ImmunityContainer
extends VBoxContainer

@export var premade_resistance_label:HBoxContainer

func _ready() -> void:
	premade_resistance_label.hide()

func set_values(actor:BaseActor):
	for child in self.get_children():
		if child == premade_resistance_label:
			continue
		if child is HBoxContainer:
			child.queue_free()
	var immunities = actor.get_effect_immunity()
	if immunities.size() == 0:
		self.hide()
	else:
		self.show()
		for effect_key:String in immunities:
			var new_entry = create_new_entry(effect_key, actor)
			self.add_child(new_entry)
			new_entry.show()

func create_new_entry(effect_key:String, _actor:BaseActor):
	var new_entry = premade_resistance_label.duplicate()
	var icon:TextureRect = new_entry.get_child(0)
	var name_label = new_entry.get_child(1)
	
	icon.texture = EffectHelper.get_effect_icon(effect_key)
	name_label.text = EffectHelper.get_effect_display_name(effect_key)
	return new_entry
