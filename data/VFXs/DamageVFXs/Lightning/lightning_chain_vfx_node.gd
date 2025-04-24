class_name LightningChainVfxNode
extends BaseVfxNode

@export var sprite:Sprite2D
@export var animation_player:AnimationPlayer

var source_actor_id:String
var source_actor_node:BaseActorNode
var origin_position
var damage_vfx_datas = []

func parent_to_offset()->bool:
	return true

func _on_start():
	if _data.get("SourceActorId", '') == _data.get("TargetActorId", ''):
		sprite.hide()
		animation_player.speed_scale = 10
		#_create_damage_effect()
		#self.finish()
		#return
	if source_actor_id == '':
		printerr("Chain Lightning Effect: No Target ActorId")
		self.finish()
	else:
		source_actor_node = CombatRootControl.get_actor_node(source_actor_id)
		animation_player.play("animation")
		animation_player.animation_finished.connect(_on_animation_finished)
	_sync()

func _sync():
	if not source_actor_node:
		self.finish()
		return
	var actor_node = vfx_holder.actor_node
	sprite.global_position = source_actor_node.global_position
	var rot = source_actor_node.get_angle_to(actor_node.position)
	sprite.rotation = rot
	var dist = sprite.global_position.distance_to(actor_node.global_position)
	var size = sprite.get_rect().size.x
	sprite.scale.x =  dist / size

func set_vfx_data(new_id:String, data:Dictionary):
	super(new_id, data)
	source_actor_id = _data.get("SourceActorId", '')

func _on_animation_finished(animation_name:String):
	self.finish()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if vfx_holder and _state == States.Playing:
		_sync()
	pass

func add_damage_effect(vfx_data:Dictionary):
	damage_vfx_datas.append(vfx_data)

func _create_damage_effect():
	var actor = self.actor_node.Actor
	for damage_vfx_data in damage_vfx_datas:
		var vfx_key = damage_vfx_data['VfxKey']
		VfxHelper.create_damage_effect(actor, vfx_key, damage_vfx_data)
