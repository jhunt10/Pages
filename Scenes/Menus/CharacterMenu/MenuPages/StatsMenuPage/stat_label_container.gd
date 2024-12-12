class_name StatLabelContainer
extends BoxContainer

@export var stat_name:String
@export var name_label:Label
@export var icon:TextureRect
@export var value_label:Label

func set_stat_values(actor:BaseActor):
	var stat_val = actor.stats.get_stat(stat_name, 0)
	value_label.text = str(stat_val)
