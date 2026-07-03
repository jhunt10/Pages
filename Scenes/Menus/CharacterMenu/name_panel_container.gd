class_name CharacterNamePanelContainer
extends PanelContainer

@export var name_label:Label
@export var level_label:Label
@export var xp_bar:ExpBarControl

func sync(actor:BaseActor):
	name_label.text = actor.get_display_name()
	level_label.text = str(actor.get_level())
	xp_bar.set_actor(actor)
