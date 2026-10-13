class_name SubAct_DeployActor
extends BaseSubAction


func get_required_props()->Dictionary:
	return {
	}

## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(parent_action:PageItemAction, subaction_data:Dictionary)->Array:
	return super(parent_action, subaction_data)

func do_thing(_parent_action:PageItemAction, subaction_data:Dictionary, metadata,
				game_state:GameStateData, actor:BaseActor)->bool:
	var turn_data:TurnExecutionData = null
	var carrier_actor:CarrierActor = null
	if subaction_data.get("IsBeingDeployed"):
		carrier_actor = actor.get_carrier_actor()
		# Sub Act was already handeled by other actor
		if !carrier_actor:
			return Success
		turn_data = carrier_actor.Que.get_current_turn_data()
	else:
		carrier_actor = actor
		turn_data = metadata.get_current_turn_data()
	
	if !turn_data:
		printerr("SubAct_DeployActor: Failed to find turn data")
		return Success
	
	var deploying_actor_id = turn_data.on_que_data.get("DeployingActorId", "")
	if !deploying_actor_id:
		printerr("SubAct_DeployActor: No DeployingActorId")
		return Success
	
	var deploying_actor:BaseActor = ActorLibrary.get_actor(deploying_actor_id)
	var extra_actor_ids = turn_data.on_que_data.get("TransferActorIds", [])
	
	# Sub Act was already handeled by the other actor
	if not deploying_actor.is_being_carried():
		return Success
	
	var deploy_pos = turn_data.on_que_data.get("DeploymentPos", null)
	var cur_pos = game_state.get_actor_pos(carrier_actor)
	var real_pos = MapPos.new(
		cur_pos.x + deploy_pos.x,
		cur_pos.y + deploy_pos.y,
		cur_pos.z,
		deploy_pos.dir
	)
	var deployed_success = DeploymentHelper.deploy_actor(deploying_actor, real_pos, extra_actor_ids)
	if not deployed_success:
		deploying_actor.Que.fail_round()
		return BaseSubAction.Failed
	else:
		VfxHelper.create_vfx_on_actor(deploying_actor, "DeployActorVfx", {}, carrier_actor)
	return BaseSubAction.Success


## Return a of OnQueOptionsData to select the parent action is qued. 
func get_on_que_options(_parent_action:PageItemAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	# Check actors that have already been qued
	
	# TODO: Translation
	var selection_description = "Please select the actor to deploy."
	var options = OnQueOptionsData.new("DeployActor", selection_description)
	
	return [options]
	
