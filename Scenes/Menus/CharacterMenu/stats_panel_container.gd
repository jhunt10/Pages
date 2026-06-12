class_name StatsPanelContainer
extends PanelContainer

func sync(actor:BaseActor):
	var stats_container = $StatsContainer
	for child in stats_container.get_children():
		if child is StatLabelContainer:
			child.set_stat_values(actor)
