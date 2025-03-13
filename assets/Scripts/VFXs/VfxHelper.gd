class_name VfxHelper

const FORCE_RELOAD = false

static func create_attack_vfx_node(from_actor:BaseActor, to_actor:BaseActor, bullet_vfx_key:String, vfx_data:Dictionary):
	var temp_data = vfx_data.duplicate(true)
	temp_data['SourceActorId'] = from_actor.Id
	temp_data['TargetActorId'] = to_actor.Id
	return create_vfx_on_actor(to_actor, bullet_vfx_key, temp_data)

static func create_damage_effect(target_actor:BaseActor, vfx_key:String, vfx_data:Dictionary):
	if FORCE_RELOAD: MainRootNode.vfx_libray.reload_vfxs()
	var target_actor_node:ActorNode = CombatRootControl.get_actor_node(target_actor.Id)
	if !target_actor_node:
		printerr("Failed to find actor node for: %s" % [target_actor.Id])
		return
	var vfx_def = MainRootNode.vfx_libray.get_vfx_data(vfx_key)
	if !vfx_def:
		printerr("Failed to VFX with key: %s" % [vfx_key])
		return
	
	if vfx_data.get("MatchSourceDir", false) and vfx_data.has("SourceActorId"):
		var node = CombatRootControl.get_actor_node(vfx_data["SourceActorId"])
		if node:
			vfx_data['Direction'] = node.facing_dir
	var vfx_node = VfxHelper.create_vfx_on_actor(target_actor, vfx_key, vfx_data)
	if !vfx_node:
		printerr("Failed to create VFX node from key '%s'." % [vfx_key])
		return
	#target_actor_node.vfx_holder.add_vfx(vfx_node)
	var damage_number = vfx_data.get("DamageNumber", 0)
	if damage_number >= 0:
		if damage_number > 0 and vfx_node._data.get("ShakeActor", true):
			target_actor_node.play_shake()


static func create_vfx_on_actor(actor:BaseActor, vfx_key:String, vfx_data:Dictionary)->BaseVfxNode:
	if FORCE_RELOAD: MainRootNode.vfx_libray.reload_vfxs()
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	if not actor_node:
		printerr("VfxHelper.create_vfx_on_actor: No ActorNode found for Actor '%s'." % [actor.Id])
		return null
	
	var vfx_def = MainRootNode.vfx_libray.get_vfx_def(vfx_key)
	var merged_data = BaseLoadObjectLibrary._merge_defs(vfx_data, vfx_def)
	var would_be_id = vfx_key
	if merged_data.get("CanStack", true):
		would_be_id += "_" + str(ResourceUID.create_id())
	
	if actor_node.vfx_holder.has_vfx(would_be_id):
		return actor_node.vfx_holder.get_vfx(would_be_id)
	
	var vfx_scene_path = merged_data.get("ScenePath")
	if not vfx_scene_path:
		printerr("VfxHelper.create_vfx_on_actor: vfx_data is missing 'ScenePath'.")
		return null
	var new_node =  load(vfx_scene_path).instantiate()
	if not new_node:
		printerr("VfxHelper.create_vfx_on_actor: Failed to load scene: %s" % [vfx_scene_path])
		return null
	if not new_node is BaseVfxNode:
		printerr("VfxHelper.create_vfx_on_actor: Scene '%s' is not of type BaseVfxNode." % [vfx_scene_path])
		return null
	var node:BaseVfxNode = new_node
	node.set_vfx_data(would_be_id, merged_data)
	actor_node.vfx_holder.add_vfx(node)
	node.start_vfx()
	return node

static func create_missile_vfx_node(missile_vfx_key:String, vfx_data:Dictionary):
	if FORCE_RELOAD: MainRootNode.vfx_libray.reload_vfxs()
	var vfx_def = MainRootNode.vfx_libray.get_vfx_def(missile_vfx_key)
	var merged_data = BaseLoadObjectLibrary._merge_defs(vfx_data, vfx_def)
	var would_be_id = missile_vfx_key
	if merged_data.get("CanStack", true):
		would_be_id += "_" + str(ResourceUID.create_id())
	
	var vfx_scene_path = merged_data.get("ScenePath")
	if not vfx_scene_path:
		printerr("VfxHelper.create_vfx_on_actor: vfx_data is missing 'ScenePath'.")
		return null
	var new_node =  load(vfx_scene_path).instantiate()
	if not new_node:
		printerr("VfxHelper.create_vfx_on_actor: Failed to load scene: %s" % [vfx_scene_path])
		return null
	if not new_node is BaseVfxNode:
		printerr("VfxHelper.create_vfx_on_actor: Scene '%s' is not of type BaseVfxNode." % [vfx_scene_path])
		return null
	var node:BaseVfxNode = new_node
	node.set_vfx_data(would_be_id, merged_data)
	node.start_vfx()
	return node

static func create_ailment_vfx_node(ailment_key:String, actor:BaseActor)->BaseVfxNode:
	if FORCE_RELOAD: MainRootNode.vfx_libray.reload_vfxs()
	var vfx_key = ''
	if ailment_key == "Shocked":
		vfx_key = "AilmentShockedVfx"
	elif ailment_key == "Burned":
		vfx_key = "AilmentBurnedVfx"
	elif ailment_key == "Chilled":
		vfx_key = "AilmentChilledVfx"
	else:
		printerr("VfxHelper.create_ailment_vfx_node: Unknown AilmentKey '%s'." % [ailment_key])
		return null
	return create_vfx_on_actor(actor, vfx_key, {})
