class_name AilmentVfxNode
extends BaseVfxNode

@export var particals:CPUParticles2D
@export var actor_modulate:Color = Color.WHITE
@export var patch_sprite:NinePatchRect

func _on_start():
	if vfx_holder:
		var actor_node = vfx_holder.actor_node
		var sprite_bounds = actor_node.actor_sprite.get_sprite_bounds()
		
		if actor_modulate != Color.WHITE:
			actor_node.add_modulate(actor_modulate)
		
		if particals:
			var sprite_area = Vector2i(sprite_bounds.size.x / 2, sprite_bounds.size.y / 2)
			particals.emission_rect_extents = sprite_area
		
		if patch_sprite:
			patch_sprite.size = Vector2i(sprite_bounds.size.x + patch_sprite.patch_margin_left + patch_sprite.patch_margin_right,
			sprite_bounds.size.y + patch_sprite.patch_margin_top + patch_sprite.patch_margin_bottom)
			patch_sprite.position =  Vector2i(-patch_sprite.size.x / 2, -patch_sprite.size.y / 2)

func _on_delete():
	if vfx_holder:
		var actor_node = vfx_holder.actor_node
		actor_node.remove_modulate(actor_modulate)
