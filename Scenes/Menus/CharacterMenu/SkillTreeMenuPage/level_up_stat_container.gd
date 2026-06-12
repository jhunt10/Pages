class_name LevelUpStatLableContainer
extends StatLabelContainer

var starting_value:int

func set_starting_value(actor:BaseActor):
	starting_value = actor.stats.get_stat(stat_name, 0)
	set_stat_values(actor)

func set_stat_values(actor:BaseActor):
	super(actor)
	if current_value > starting_value:
		value_label.modulate = Color.WEB_GREEN
	elif current_value < starting_value:
		value_label.modulate = Color.FIREBRICK
	else:
		value_label.modulate = Color.BLACK
