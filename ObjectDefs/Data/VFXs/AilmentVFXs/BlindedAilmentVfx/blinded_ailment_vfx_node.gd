class_name BlindedAilmentVfxNode
extends AilmentVfxNode


func _on_start():
	if vfx_holder:
		var actor_node = vfx_holder.actor_node
		if not actor_node:
			printerr("AilmentVfxNode: vfx_holder.actor_node is null")
			return
		var sprite_bounds = actor_node.actor_sprite.get_sprite_bounds()
		var sprite_hight = sprite_bounds.size.y * y_scale
		
		#if actor_modulate != Color.WHITE:
			#actor_node.add_modulate(actor_modulate)
		#
		#if particals:
			#var sprite_area = Vector2i(sprite_bounds.size.x / 2, sprite_hight / 2)
			#particals.emission_rect_extents = sprite_area
			##particals.position = Vector2(0,-sprite_bounds.position.y)
		#
		#if patch_sprite:
			#patch_sprite.size = Vector2i(sprite_bounds.size.x + patch_sprite.patch_margin_left + patch_sprite.patch_margin_right,
			#sprite_bounds.size.y + patch_sprite.patch_margin_top + patch_sprite.patch_margin_bottom)
			#patch_sprite.position =  Vector2i(-patch_sprite.size.x / 2, -patch_sprite.size.y / 2)
		#
		#if top_of_head:
			#self.position = Vector2(0, 0 -  actor_node.offset_node.position.y - sprite_bounds.position.y)

func _on_delete():
	#if vfx_holder:
		#var actor_node = vfx_holder.actor_node
		#actor_node.remove_modulate(actor_modulate)
	pass
