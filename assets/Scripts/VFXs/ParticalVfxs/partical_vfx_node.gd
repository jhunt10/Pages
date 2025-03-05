class_name AilmentVfxNode
extends VfxNode

@export var particals:CPUParticles2D
@export var actor_modulate:Color = Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_readyed = true
	if _delayed_start:
		start_vfx()
	pass # Replace with function body.

func start_vfx():
	if !_readyed:
		_delayed_start = true
		return
	if _actor:
		var actor_node = CombatRootControl.get_actor_node(_actor.Id)
		if actor_modulate != Color.WHITE:
			actor_node.add_modulate(actor_modulate)
		if particals:
			var sprite_bounds = actor_node.actor_sprite.get_sprite_bounds()
			var sprite_area = Vector2i(sprite_bounds.size.x / 2, sprite_bounds.size.y / 2)
			particals.emission_rect_extents = sprite_area
		
			var texture_size = actor_node.actor_sprite.get_rect().size
			var center = sprite_bounds.get_center()
			var center_x = center.x - (texture_size.x / 2)
			var center_y = center.y - (texture_size.y / 2)
			self.position = Vector2(center_x, center_y)

func set_vfx_data(data:VfxData, extra_data:Dictionary):
	_data = data

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_delete():
	var actor_node = CombatRootControl.get_actor_node(_actor.Id)
	actor_node.remove_modulate(actor_modulate)
	super()
	
