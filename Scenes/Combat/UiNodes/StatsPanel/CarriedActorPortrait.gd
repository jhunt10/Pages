class_name CarriedActorPortrait
extends TextureRect

@export var real_portrait:TextureRect
@export var hp_max_bar:ColorRect
@export var hp_cur_bar:ColorRect
@export var button:Button

var _actor:BaseActor

func set_actor(actor:BaseActor):
	if _actor:
		if _actor.health_changed.is_connected(_on_health_change):
			_actor.health_changed.disconnect(_on_health_change)
		if _actor.sprite_changed.is_connected(_on_sprite_change):
			_actor.sprite_changed.disconnect(_on_sprite_change)
	_actor = actor
	_actor.sprite_changed.connect(_on_sprite_change)
	_actor.health_changed.connect(_on_health_change)
	_on_health_change()
	_on_sprite_change()

func _on_health_change():
	var max_size = hp_max_bar.size.x
	var percent_full:float = (_actor.stats.current_health as float) / (_actor.stats.max_health as float)
	hp_cur_bar.size.x = max_size * percent_full

func _on_sprite_change():
	real_portrait.texture = _actor.sprite.get_portrait_sprite()
