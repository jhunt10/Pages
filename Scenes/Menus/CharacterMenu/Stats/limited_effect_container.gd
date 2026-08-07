class_name LimitedEffectContainer
extends BoxContainer

@export var name_label:Label
@export var stat_label:StatLabelContainer

func set_actor(actor:BaseActor):
	var limited_stats = actor.stats.get_stats_by_prefix("LmtEftCount")
	if limited_stats.size() == 0:
		self.hide()
	else:
		self.show()
		var stat_name = limited_stats.keys()[0]
		name_label.text = stat_name.trim_prefix("LmtEftCount:")
		stat_label.set_values(stat_name, actor)
