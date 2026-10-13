class_name DeploymentHelper


static var preview_deployment_cache:Dictionary = {}

static func is_deployed(actor)->bool:
	var check_actor = actor
	if actor is String:
		check_actor = CombatRootControl.Instance.GameState.get_actor(actor)
	if check_actor:
		return not check_actor.is_being_carried()
	return false

static func deploy_actor(actor, pos:MapPos, take_with:Array=[], preview_deployment:bool=false)->bool:
	# Get Deploying and Carrier Actor
	var deploying_actor:BaseActor = null
	if actor is String: deploying_actor = CombatRootControl.Instance.GameState.get_actor(actor)
	if actor is BaseActor: deploying_actor = actor
	var carrier_actor = deploying_actor.get_carrier_actor()
	if !carrier_actor:
		printerr("DeploymentHelper.deploy_actor: Carrier Actor not found on '%s'." % [deploying_actor.Id])
		return false
	
	if not preview_deployment:
		# Check map spot
		if not CombatRootControl.Instance.GameState.map_data.is_spot_open(pos):
			printerr("DeploymentHelper.deploy_actor: Invalid MapPosition '%s'." % [pos])
			return false
	else:
		preview_deployment_cache[deploying_actor.Id] = carrier_actor.Id
	
	#  Build Transfer list of TakeWith actors
	var confirmed_take = []
	for sub_actor_id in take_with:
		if carrier_actor.is_carrying_actor(sub_actor_id):
			carrier_actor.remove_held_actor(sub_actor_id, true)
			confirmed_take.append(sub_actor_id)
	
	# Remove the deploying actor
	carrier_actor.remove_held_actor(deploying_actor)
	# Transfer TakeWith actors
	for actor_id in confirmed_take:
		deploying_actor.add_carried_actor(actor_id)
	
	# Add to GameState
	CombatRootControl.Instance.GameState.set_actor_pos(deploying_actor, pos)
	# Show Deployed Actor Node
	var actor_node = CombatRootControl.get_actor_node(deploying_actor)
	actor_node.show()
	
	# Trigger effects
	if not preview_deployment:
		deploying_actor.effects._trigger_effects(BaseEffect.EffectTriggers.OnDeployed, CombatRootControl.Instance.GameState)
	
	# Update ActionQueControl
	CombatRootControl.Instance.QueController.add_action_que(deploying_actor.Que)
	CombatRootControl.Instance.QueController.clear_and_check_ques()
	CombatRootControl.Instance.ui_control.build_player_stats_panels()
	return true

static func un_deploy_preview(actor):
	# Get deploying actor
	var deployed_actor:BaseActor = null
	if actor is String:
		deployed_actor = CombatRootControl.Instance.GameState.get_actor(actor)
	if actor is BaseActor:
		deployed_actor = actor
	var deployed_from_carrier_id = preview_deployment_cache.get(deployed_actor.Id)
	if not deployed_from_carrier_id:
		printerr("DeploymentHelper: un_deploy_preview lost CarrierId for '%s'." %[deployed_actor.Id])
		return
	var carrier_actor = CombatRootControl.Instance.GameState.get_actor(deployed_from_carrier_id)
	if carrier_actor:
		merge_actors(carrier_actor, deployed_actor, true)
		preview_deployment_cache.erase(deployed_actor.Id)
		CombatRootControl.Instance.QueController.remove_action_que(deployed_actor.Que, true)
		CombatRootControl.Instance.QueController.clear_and_check_ques()
	

static func merge_actors(actor_a, actor_b, preview_deployment:bool=false):
	var deployed_actor = actor_a
	if deployed_actor is String:
		deployed_actor = CombatRootControl.Instance.GameState.get_actor(deployed_actor)
	var carrier_actor = actor_b
	if carrier_actor is String:
		carrier_actor = CombatRootControl.Instance.GameState.get_actor(carrier_actor)
	
	# Check if we need to swap parent and child
	if deployed_actor is CarrierActor:
		# actor_a is only carrier
		if (not carrier_actor is CarrierActor
		# or actor_a has lower carrier priority
		or deployed_actor.get_carrier_priority() < carrier_actor.get_carrier_priority()):
			var temp = deployed_actor
			deployed_actor = carrier_actor
			carrier_actor = temp
	
	CombatRootControl.Instance.GameState.remove_actor_from_map(deployed_actor)
	if not preview_deployment:
		var deployed_node = CombatRootControl.get_actor_node(deployed_actor)
		if deployed_node:
			deployed_node.cancel_move_animation()
		CombatRootControl.Instance.QueController.remove_action_que(deployed_actor.Que)
	else:
		var deployed_node = CombatRootControl.get_actor_node(deployed_actor)
		if deployed_node:
			deployed_node.hide()
	
	carrier_actor.add_carried_actor(deployed_actor)
	
	if not preview_deployment:
		deployed_actor.effects._trigger_effects(BaseEffect.EffectTriggers.OnMerged, CombatRootControl.Instance.GameState)
	
	CombatRootControl.Instance.ui_control.build_player_stats_panels()
	if deployed_actor == CombatRootControl.Instance.get_current_player_actor():
		CombatRootControl.Instance.set_current_player_actor(carrier_actor, true)

static func transfer_actor(actor, new_carrier):
	var deploying_actor = actor
	if deploying_actor is String:
		deploying_actor = CombatRootControl.Instance.GameState.get_actor(deploying_actor)
	
	var new_carrier_actor = new_carrier
	if new_carrier_actor is String:
		new_carrier_actor = CombatRootControl.Instance.GameState.get_actor(new_carrier_actor)
	
	var carrier_actor = deploying_actor.get_carrier_actor()
	if !carrier_actor:
		printerr("DeploymentHelper.transfer_actor: Carrier Actor not found on '%s'." % [deploying_actor.Id])
		return
	if carrier_actor.is_carrying_actor(deploying_actor):
		carrier_actor.remove_held_actor(deploying_actor, true)
	new_carrier_actor.add_carried_actor(deploying_actor)
	CombatRootControl.Instance.ui_control.build_player_stats_panels()
	

static func recall_actor(actor_a, actor_b):
	var deployed_actor = actor_a
	if deployed_actor is String:
		deployed_actor = CombatRootControl.Instance.GameState.get_actor(deployed_actor)
	var carrier_actor = actor_b
	if carrier_actor is String:
		carrier_actor = CombatRootControl.Instance.GameState.get_actor(carrier_actor)
	
	var deployed_node = CombatRootControl.get_actor_node(deployed_actor)
	deployed_node.cancel_move_animation()
	#var carrier_node = get_actor_node(carrier_actor)
	var vfx = VfxHelper.create_vfx_on_actor(carrier_actor, "RecallActorVfx", {}, deployed_actor)
	vfx.finished.connect(on_recall_finish.bind(deployed_actor, carrier_actor))

static func on_recall_finish(deployed_actor, carrier_actor):
	merge_actors(deployed_actor, carrier_actor)
	CombatRootControl.Instance.QueController.clear_and_check_ques()
	#var deployed_node = get_actor_node(deployed_actor)
	#deployed_node.damage_animation_player.play()
