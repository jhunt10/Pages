class_name LightningChainVfxNode
extends BaseVfxNode

@export var sprite:Sprite2D
@export var animation_player:AnimationPlayer

var origin_position
var damage_vfx_datas = []

func parent_to_offset()->bool:
	return true

func _on_start():
	# Host and Source Actors are the same
	if _data.get("SourceActorId", '') == _data.get("HostActorId", ''):
		printerr("%s: SourceActor and Host Actor are same." % [self.id])
		sprite.hide()
		animation_player.speed_scale = 10
	if source_actor_id == '':
		printerr("Chain Lightning Effect: No Target ActorId")
		self.finish()
	_sync()
	animation_player.play("main_animation")
	animation_player.animation_finished.connect(_on_animation_finished)

func _sync():
	var source_actor_node = get_source_actor_node()
	if not source_actor_node:
		return
	sprite.global_position = source_actor_node.global_position
	var rot = source_actor_node.get_angle_to(actor_node.position)
	sprite.rotation = rot
	var dist = sprite.global_position.distance_to(actor_node.global_position)
	var size = sprite.get_rect().size.x
	sprite.scale.x =  dist / size

func set_vfx_data(new_id:String, data:Dictionary):
	super(new_id, data)
	source_actor_id = _data.get("SourceActorId", '')

func _on_animation_finished(_animation_name:String):
	self.finish()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if vfx_holder and _state == States.Playing:
		_sync()
