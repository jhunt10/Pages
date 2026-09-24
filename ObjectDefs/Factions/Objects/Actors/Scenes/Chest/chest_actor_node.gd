class_name ChestActorNode
extends BaseActorNode

@export var item_sprite:Sprite2D
@export var top_sprite:Sprite2D
@export var silver_sprite_sheet:Texture2D

func set_actor(actor:BaseActor, connect_signals=true):
	super(actor, connect_signals)
	if actor is ChestActor:
		actor.triggered.connect(on_triggered)
		top_sprite.texture = actor_sprite.texture 
		item_sprite.hide()
			
	else:
		printerr("None ChestActor set on ChestActorode")
		self.queue_free()

func on_triggered():
	if Actor is ChestActor:
		var item_icon_path = Actor._spawned_item_icon_path
		if item_icon_path:
			var sprite = SpriteCache.get_sprite(item_icon_path)
			item_sprite.texture = sprite
			item_sprite.show()
	# Death Animation is Open Chest Animation
	pass

#func start_death_animation():
	##damage_animation_player.play("open_chest")
	#damage_animation_player.play("DamageAnimations/open_chest")
	#damage_animation_player.animation_finished.connect(on_death_animation_finished)
