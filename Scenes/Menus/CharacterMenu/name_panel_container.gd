class_name CharacterNamePanelContainer
extends PanelContainer

@export var name_label:Label
@export var level_label:Label

func sync(actor:BaseActor):
	name_label.text = actor.get_display_name()
	level_label.text = str(int(actor.stats.get_stat(StatHelper.Level)))
