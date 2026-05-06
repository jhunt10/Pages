class_name VfxHelper

const FORCE_RELOAD = false

static func create_flash_text(actor_or_holder, value, flash_text_type:BaseFlashTextVfxNode.FlashTextType):
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
	var flash_text_data = {
		"VfxKey": "FlashTextVfx",
		"FlashTextVal": value,
		"FlashTextType": flash_text_type
	}
	_create_vfx_on_holder(vfx_holder, "FlashTextVfx", flash_text_data)

static func add_chained_flash_text(parent_vfx:BaseVfxNode, value, flash_text_type:BaseFlashTextVfxNode.FlashTextType):
	var vfx_holder = parent_vfx.vfx_holder
	if not vfx_holder:
		return null
	var flash_text_data = {
		"VfxKey": "FlashTextVfx",
		"FlashTextVal": value,
		"FlashTextType": flash_text_type
	}
	parent_vfx.add_chained_vfx("FlashTextVfx", flash_text_data)

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
	

static func create_vfx_on_actor(host_actor:BaseActor, vfx_key, vfx_data:Dictionary, source_actor=null)->BaseVfxNode:
	var actor_node = CombatRootControl.get_actor_node(host_actor.Id)
	if not actor_node:
		printerr("VfxHelper.create_vfx_on_actor: No BaseActorNode found for Actor '%s'." % [host_actor.Id])
		return null
	var vfx_holder = actor_node.vfx_holder
	if not vfx_holder:
		printerr("VfxHelper.create_vfx_on_actor: No VfxHolder found on ActorNode for '%s'." % [host_actor.Id])
		return null
	var source = source_actor
	if source is BaseActor:
		source = source.Id
	return _create_vfx_on_holder(actor_node.vfx_holder, vfx_key, vfx_data, source)

static func _create_vfx_on_holder(vfx_holder:VfxHolder, vfx_key, vfx_data:Dictionary, source_actor=null)->BaseVfxNode:
	if vfx_key == null or vfx_key == "":
		vfx_key = vfx_data.get("VfxKey", '')
	if FORCE_RELOAD: VfxLibrary.reload_vfxs()
	
	# Shortcut FlashText
	# Must go though FlashText Controller 
	if vfx_key == "FlashText" :
		var damage_string = str(vfx_data.get("DamageNumber", 0))
		var damage_text_type = vfx_data.get("DamageTextType", BaseFlashTextVfxNode.FlashTextType.Normal_Dmg)
		VfxHelper.create_flash_text(vfx_holder.actor_node.Actor, damage_string, damage_text_type)
		return null
	
	var vfx_def = {}
	if vfx_key and not vfx_data.get("BeenMerged", false): 
		vfx_def = VfxLibrary.get_vfx_def(vfx_key)
	var merged_data = BaseLoadObjectLibrary._merge_defs(vfx_data, vfx_def)
	
	# Set Host and Source actors
	merged_data['HostActorId'] = vfx_holder.get_host_id()
	if source_actor and not merged_data.has("SourceActorId"):
		if source_actor is BaseActor:
			merged_data['SourceActorId'] = source_actor.Id
		elif source_actor is String:
			merged_data['SourceActorId'] = source_actor
	
	# Determin Id
	var would_be_id = vfx_key
	if merged_data.get("CanStack", true):
		would_be_id += "_" + str(ResourceUID.create_id())
	
	if vfx_holder.has_vfx(would_be_id):
		return vfx_holder.get_vfx(would_be_id)
	
	var vfx_scene_path = merged_data.get("ScenePath")
	if not vfx_scene_path:
		printerr("VfxHelper.create_vfx_on_actor: vfx_data is missing 'ScenePath': %s" % [would_be_id])
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
	if FORCE_RELOAD: VfxLibrary.reload_vfxs()
	var vfx_def = VfxLibrary.get_vfx_def(missile_vfx_key)
	var override_load_path = (vfx_data.has("SpriteName") and vfx_data.get("SpriteName") != vfx_def.get("SpriteName"))
	
	var merged_data = BaseLoadObjectLibrary._merge_defs(vfx_data, vfx_def)
	var would_be_id = missile_vfx_key + "_" + str(ResourceUID.create_id())
	if override_load_path:
		merged_data['LoadPath'] = vfx_data.get('LoadPath', merged_data['LoadPath'])
	else:
		merged_data['LoadPath'] = vfx_def['LoadPath']
		
	var vfx_scene_path = merged_data.get("ScenePath")
	if not vfx_scene_path:
		printerr("VfxHelper.create_missile_vfx_node: vfx_data is missing 'ScenePath': %s" % [would_be_id])
		return null
	var new_node =  load(vfx_scene_path).instantiate()
	if not new_node:
		printerr("VfxHelper.create_missile_vfx_node: Failed to load scene: %s" % [vfx_scene_path])
		return null
	if not new_node is BaseVfxNode:
		printerr("VfxHelper.create_missile_vfx_node: Scene '%s' is not of type BaseVfxNode." % [vfx_scene_path])
		return null
	var node:BaseVfxNode = new_node
	node.set_vfx_data(would_be_id, merged_data)
	node.start_vfx()
	return node

static func create_ailment_vfx_node(ailment_key:String, actor:BaseActor)->BaseVfxNode:
	if FORCE_RELOAD: VfxLibrary.reload_vfxs()
	var vfx_key = "Ailment" + ailment_key + "Vfx"
	return create_vfx_on_actor(actor, vfx_key, {"CanStack": false})

static func create_vfs_for_attack_event(attack_event:AttackEvent, game_state:GameStateData, override_source_actor:BaseActor = null):
	for sub_attack_event_key in attack_event.sub_events.keys():
		var sub_attack_event:AttackSubEvent = attack_event.sub_events.get(sub_attack_event_key)
		create_vfx_for_sub_attack_event(attack_event, game_state, sub_attack_event, override_source_actor)

static func create_vfx_for_sub_attack_event(attack_event:AttackEvent, game_state:GameStateData, sub_attack_event:AttackSubEvent, override_source_actor:BaseActor = null):
	var attack_vfx_key = attack_event.attack_details.get("AttackVfxKey")
	var attack_vfx_data = attack_event.attack_details.get("AttackVfxData", {})
	var defender:BaseActor = game_state.get_actor(sub_attack_event.defending_actor_id)
	
	var attacker = game_state.get_actor(attack_event.attacker_id)
	var source_actor:BaseActor = attacker
	if override_source_actor:
		source_actor = override_source_actor
	
	# Make VFX for Attack
	var attack_vfx:BaseVfxNode = null
	if attack_vfx_key or attack_vfx_data.has("ScenePath"):
		attack_vfx = create_vfx_on_actor(defender, attack_vfx_key, attack_vfx_data, source_actor)
	
	# Make "Evade" Flash Text
	if sub_attack_event.is_evade:
		var evade_flash_text_data = {
			"VfxKey": "FlashTextVfx",
			"FlashTextType": BaseFlashTextVfxNode.FlashTextType.Evade
		}
		if attack_vfx:
			attack_vfx.add_chained_vfx("FlashTextVfx", evade_flash_text_data)
		else:
			create_vfx_on_actor(defender, "FlashTextVfx", evade_flash_text_data, source_actor)
	# Make "Miss" Flash Text
	elif sub_attack_event.is_miss:
		var miss_flash_text_data = {
			"VfxKey": "FlashTextVfx",
			"FlashTextType": BaseFlashTextVfxNode.FlashTextType.Miss
		}
		if attack_vfx:
			attack_vfx.add_chained_vfx("FlashTextVfx", miss_flash_text_data)
		else:
			create_vfx_on_actor(attacker, "FlashTextVfx", miss_flash_text_data)
	# Make Vfx for Damage
	else:
		for damage_event_key in sub_attack_event.damage_events.keys():
			var damage_event:DamageEvent = sub_attack_event.damage_events[damage_event_key]
			var damage_data = attack_event.damage_datas.get(damage_event.damage_data_key)
			var damage_vfx_data = _build_vfx_data_from_damage_event(source_actor.Id, damage_event, damage_data, sub_attack_event)
			var damage_vfx_key = damage_vfx_data.get("VfxKey")
			if attack_vfx:
				attack_vfx.add_chained_vfx(damage_vfx_key, damage_vfx_data)
			else:
				create_vfx_on_actor(defender, damage_vfx_key, damage_vfx_data, source_actor)
	

static func create_vfx_for_damage_event(actor:BaseActor, damage_event:DamageEvent, damage_data:Dictionary):
	var damage_vfx_data = _build_vfx_data_from_damage_event(actor.Id, damage_event, damage_data, null)
	var damage_vfx_key = damage_vfx_data.get("VfxKey")
	create_vfx_on_actor(actor, damage_vfx_key, damage_vfx_data, actor)

static func chain_vfx_for_damage_event(parent_vfx_node:BaseVfxNode, damage_event:DamageEvent, damage_data:Dictionary):
	var damage_vfx_data = _build_vfx_data_from_damage_event(parent_vfx_node.source_actor_id, damage_event, damage_data, null)
	var damage_vfx_key = damage_vfx_data.get("VfxKey")
	parent_vfx_node.add_chained_vfx(damage_vfx_key, damage_vfx_data)

static func _build_vfx_data_from_damage_event(attacker_id:String, damage_event:DamageEvent, damage_data:Dictionary, attack_sub_event:AttackSubEvent)->Dictionary:
	var damage_vfx_key = damage_data.get("DamageVfxKey", '')
	var damage_vfx_data = damage_data.get("DamageVfxData", {}).duplicate()
	
	if damage_vfx_key == "AUTO":
		var damage_type = DamageEvent.DamageTypes.keys()[damage_event.damage_type]
		damage_vfx_key = damage_type + "_DamageEffect"
	damage_vfx_data['VfxKey'] = damage_vfx_key
	damage_vfx_data['SourceActorId'] = attacker_id
	
	var flash_text_data = {
		"VfxKey": "FlashTextVfx",
		"FlashTextVal": str(damage_event.final_damage),
		"FlashTextType": BaseFlashTextVfxNode.FlashTextType.Normal_Dmg
	}
	if damage_event.final_damage < 0:
		flash_text_data['FlashTextType'] = BaseFlashTextVfxNode.FlashTextType.Healing_Dmg
	elif damage_event.source_tag_chain.has_tag("DOT"):
		flash_text_data['FlashTextType'] = BaseFlashTextVfxNode.FlashTextType.DOT_Dmg
	elif attack_sub_event:
		if attack_sub_event.is_crit and not attack_sub_event.is_blocked:
			flash_text_data['FlashTextType'] = BaseFlashTextVfxNode.FlashTextType.Crit_Dmg
		elif attack_sub_event.is_blocked and not attack_sub_event.is_crit:
			flash_text_data['FlashTextType'] = BaseFlashTextVfxNode.FlashTextType.Blocked_Dmg
	
	damage_vfx_data['ChainVfxDatas'] = {
		"FlashTextVfx": flash_text_data
	}
	return  damage_vfx_data
