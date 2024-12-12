class_name StatEntryContainer
extends HBoxContainer

@export var name_label:Label
@export var base_value_label:Label
@export var value_label:Label

func set_stat(actor:BaseActor, stat_name:String):
	var base_val = actor.stats.get_base_stat(stat_name, -1)
	var val = actor.stats.get_stat(stat_name)
	if base_val >= 0:
		base_value_label.text = str(base_val)
	else:
		base_value_label.text = "--"
	value_label.text = str(val)
	
	if stat_name.begins_with("Regen:"):
		var tokens = stat_name.split(':')
		name_label.text = tokens[1] + " P" + tokens[2].substr(0,1)
	elif stat_name.begins_with("Max:"):
		name_label.text = stat_name.replace(':', ' ')
	elif stat_name == 'PagesPerRound':
		name_label.text = "PPR"
	else:
		name_label.text = stat_name
	
