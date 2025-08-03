@tool
class_name ResistancesContainer
extends BackPatchContainer

@export var entries_contaienr:BoxContainer
@export var premade_resistance_label:HBoxContainer

func _ready() -> void:
	premade_resistance_label.hide()

func set_values(actor:BaseActor):
	for child in entries_contaienr.get_children():
		if child == premade_resistance_label:
			continue
		child.queue_free()
	for damage_type_str:String in DamageEvent.DamageTypes.keys():
		var rest_stat_name = "Resistance:" + damage_type_str
		var rest_val = actor.stats.get_stat(rest_stat_name)
		if rest_val != 0:
			var new_entry = create_new_entry(damage_type_str, actor, rest_val)
			entries_contaienr.add_child(new_entry)
			new_entry.show()

func create_new_entry(entry_key:String, actor:BaseActor, value):
	var new_entry = premade_resistance_label.duplicate()
	var icon:TextureRect = new_entry.get_child(0)
	var name_label = new_entry.get_child(1)
	var value_label = new_entry.get_child(3)
	icon.texture = DamageHelper.get_damage_icon(entry_key)
	name_label.text = entry_key
	value_label.text = str(value)
	return new_entry
