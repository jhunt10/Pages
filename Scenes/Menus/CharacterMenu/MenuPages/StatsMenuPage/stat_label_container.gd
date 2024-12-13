class_name StatLabelContainer
extends BoxContainer

@export var stat_name:String
@export var name_label:Label
@export var icon:TextureRect
@export var value_label:Label
@export var percent_value:Label

func set_stat_values(actor:BaseActor):
	var stat_val = actor.stats.get_stat(stat_name, 0)
	value_label.text = str(stat_val)
	if percent_value:
		percent_value.text = "%2.3f" % [DamageHelper.calc_armor_reduction(stat_val)]
