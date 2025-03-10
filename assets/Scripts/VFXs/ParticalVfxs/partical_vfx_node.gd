class_name AilmentVfxNode
extends BaseVfxNode

@export var particals:CPUParticles2D
@export var actor_modulate:Color = Color.WHITE

func _on_start():
	if vfx_holder:
		var actor_node = vfx_holder.actor_node
		if actor_modulate != Color.WHITE:
			actor_node.add_modulate(actor_modulate)
		if particals:
			var sprite_bounds = actor_node.actor_sprite.get_sprite_bounds()
			var sprite_area = Vector2i(sprite_bounds.size.x / 2, sprite_bounds.size.y / 2)
			particals.emission_rect_extents = sprite_area

func _on_delete():
	if vfx_holder:
		var actor_node = vfx_holder.actor_node
		actor_node.remove_modulate(actor_modulate)
