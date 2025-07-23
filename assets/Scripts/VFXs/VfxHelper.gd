class_name VfxHelper

const FORCE_RELOAD = false

enum FlashTextType {
	Normal_Dmg, Blocked_Dmg, Crit_Dmg, Healing_Dmg, DOT_Dmg,
	NoAmmo, NoTarget, Miss, Evade, Protect}

#static func create_attack_vfx_node(from_actor:BaseActor, to_actor:BaseActor, bullet_vfx_key:String, vfx_data:Dictionary):
	#var temp_data = vfx_data.duplicate(true)
	#temp_data['SourceActorId'] = from_actor.Id
	#temp_data['HostActorId'] = to_actor.Id
	#return create_vfx_on_actor(to_actor, bullet_vfx_key, temp_data)

static func create_flash_text(actor_or_holder, value, flash_text_type:FlashTextType):
	var vfx_holder = null
	if actor_or_holder is BaseActorNode:
		vfx_holder = actor_or_holder.vfx_holder
	elif actor_or_holder is BaseActor:
		var actor_node = CombatRootControl.get_actor_node(actor_or_holder.Id)
		vfx_holder = actor_node.vfx_holder
	elif actor_or_holder is VfxHolder:
		vfx_holder = actor_or_holder
	
	if not vfx_holder:
		return null
	var text_value = str(value)
	vfx_holder.flash_text_controller.add_flash_text(text_value, flash_text_type)

static func create_damage_effect(target_actor:BaseActor, vfx_key:String, vfx_data:Dictionary):
	if FORCE_RELOAD: MainRootNode.vfx_libray.reload_vfxs()
	var target_actor_node:BaseActorNode = CombatRootControl.get_actor_node(target_actor.Id)
	if !target_actor_node:
		printerr("Failed to find actor node for: %s" % [target_actor.Id])
		return
	var vfx_def = MainRootNode.vfx_libray.get_vfx_data(vfx_key)
	if !vfx_def:
		printerr("Failed to VFX with key: %s" % [vfx_key])
		if vfx_data.has("DamageNumber"):
			var damage_number = vfx_data.get("DamageNumber", 0)
			var damage_color = vfx_data.get("DamageColor", Color.WHITE)
			var damage_text_type = vfx_data.get("DamageTextType", VfxHelper.FlashTextType.Normal_Dmg)
			var damage_string = str(damage_number)
			VfxHelper.create_flash_text(target_actor, damage_string, damage_text_type)
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
	if damage_number <= 0 and vfx_node._data.get("ShakeActor", true):
			target_actor_node.play_shake()

static func create_vfx_at_pos(pos:MapPos, vfx_key, vfx_data:Dictionary, source_actor:BaseActor=null)->BaseVfxNode:
	var combat_control = CombatRootControl.Instance
	if not is_instance_valid(combat_control):
		return null
	var map_controller:MapControllerNode = combat_control.MapController
	var vfx_node = map_controller.create_vfx_holder(pos)
	if not vfx_node:
		printerr("VfxHelper.create_vfx_at_pos: Failed to create VfxHolder")
		return null
	return _create_vfx_on_holder(vfx_node, vfx_key, vfx_data, source_actor)
	

static func create_vfx_on_actor(host_actor:BaseActor, vfx_key, vfx_data:Dictionary, source_actor:BaseActor=null)->BaseVfxNode:
	var actor_node = CombatRootControl.get_actor_node(host_actor.Id)
	if not actor_node:
		printerr("VfxHelper.create_vfx_on_actor: No BaseActorNode found for Actor '%s'." % [host_actor.Id])
		return null
	var vfx_holder = actor_node.vfx_holder
	if not vfx_holder:
		printerr("VfxHelper.create_vfx_on_actor: No VfxHolder found on ActorNode for '%s'." % [host_actor.Id])
		return null
	return _create_vfx_on_holder(actor_node.vfx_holder, vfx_key, vfx_data, source_actor)

static func _create_vfx_on_holder(vfx_holder:VfxHolder, vfx_key, vfx_data:Dictionary, source_actor:BaseActor=null)->BaseVfxNode:
	if vfx_key == null or vfx_key == "":
		vfx_key = vfx_data.get("VfxKey", '')
	if FORCE_RELOAD: MainRootNode.vfx_libray.reload_vfxs()
	
	var vfx_def = {}
	if vfx_key and not vfx_data.get("BeenMerged", false): 
		vfx_def = MainRootNode.vfx_libray.get_vfx_def(vfx_key)
	var merged_data = BaseLoadObjectLibrary._merge_defs(vfx_data, vfx_def)
	
	# Set Host and Source actors
	merged_data['HostActorId'] = vfx_holder.get_host_id()
	if source_actor and not merged_data.has("SourceActorId"):
		merged_data['SourceActorId'] = source_actor.Id
	
	# Determin Id
	var would_be_id = vfx_key
	if merged_data.get("CanStack", true):
		would_be_id += "_" + str(ResourceUID.create_id())
	
	if vfx_holder.has_vfx(would_be_id):
		return vfx_holder.get_vfx(would_be_id)
	
	var vfx_scene_path = merged_data.get("ScenePath")
	if not vfx_scene_path:
		printerr("VfxHelper.create_vfx_on_actor: vfx_data is missing 'ScenePath'.")
		return null
	var scene = load(vfx_scene_path)
	if not scene:
		printerr("VfxHelper.create_vfx_on_actor: No scene ound at %s" % [vfx_scene_path])
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
	vfx_holder.add_vfx(node)
	node.start_vfx()
	return node

static func create_missile_vfx_node(missile_vfx_key:String, vfx_data:Dictionary)->BaseVfxNode:
	if FORCE_RELOAD: MainRootNode.vfx_libray.reload_vfxs()
	var vfx_def = MainRootNode.vfx_libray.get_vfx_def(missile_vfx_key)
	var override_load_path = (vfx_data.has("SpriteName") and vfx_data.get("SpriteName") != vfx_def.get("SpriteName"))
	
	var merged_data = BaseLoadObjectLibrary._merge_defs(vfx_data, vfx_def)
	var would_be_id = missile_vfx_key + "_" + str(ResourceUID.create_id())
	if override_load_path:
		merged_data['LoadPath'] = vfx_data.get('LoadPath', merged_data['LoadPath'])
	else:
		merged_data['LoadPath'] = vfx_def['LoadPath']
		
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
	var vfx_key = "Ailment" + ailment_key + "Vfx"
	return create_vfx_on_actor(actor, vfx_key, {"CanStack": false})
