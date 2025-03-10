class_name LevelUp_StatChangeContainer
extends StatLabelContainer

@export var goto_stat_label:Label

var starting_value:int

func set_stat_name(stat:String):
	self.stat_name = stat
	self.icon.texture = StatHelper.get_stat_icon(stat)

func set_stat_values(actor:BaseActor):
	super(actor)
	starting_value = floori(actor.stats.get_stat(stat_name, 0))
	value_label.text = str(starting_value)
	goto_stat_label.text = value_label.text

func update_values(actor:BaseActor):
	var new_value = floori(actor.stats.get_stat(stat_name, 0))
	goto_stat_label.text = str(new_value)
	if starting_value > new_value:
		goto_stat_label.modulate = Color.FIREBRICK
	elif starting_value < new_value:
		goto_stat_label.modulate = Color.WEB_GREEN
	else:
		goto_stat_label.modulate = Color.BLACK
