class_name SubAct_GetTarget
extends BaseSubAction


func get_required_props()->Dictionary:
	return {
		"TargetParamKey": BaseSubAction.SubActionPropTypes.TargetParamKey,
		"SetTargetKey": BaseSubAction.SubActionPropTypes.SetTargetKey,
		"AllowAutoTarget": BaseSubAction.SubActionPropTypes.BoolVal,
		"AllowAlreadyTargeted": BaseSubAction.SubActionPropTypes.BoolVal,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Targeting"]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	# Check if Target is already set
	var setting_target_key = subaction_data['SetTargetKey']
	var turn_data:TurnExecutionData = metadata.get_current_turn_data()
	if turn_data.has_target(setting_target_key):
		return BaseSubAction.Success
	
	var target_param_key = subaction_data.get("TargetParamKey", "")
	var target_params = parent_action.get_targeting_params(target_param_key, actor)
	if !target_params:
		return BaseSubAction.Failed
	
	# Shortcut Self and FullArea
	if target_params.target_type == TargetParameters.TargetTypes.Self or target_params.target_type == TargetParameters.TargetTypes.FullArea:
		turn_data.add_target_for_key(setting_target_key, target_params.target_param_key, actor.Id,)
		return BaseSubAction.Success
	
	# Get Targeting Params
	#var actor_pos = game_state.get_actor_pos(actor)
	var allow_dups = subaction_data.get("AllowAlreadyTargeted", false)
	var allow_auto = subaction_data.get("AllowAutoTarget", false)
	
	var exclude_targets = []
	if not allow_dups:
		exclude_targets = turn_data.list_targets()
		
	var selection_data = TargetSelectionData.new(target_params, setting_target_key, actor, game_state, exclude_targets)
	var potential_target_count = selection_data.get_potential_target_count()
	# No valid targets
	if potential_target_count == 0:
		VfxHelper.create_flash_text(actor, "No Target", VfxHelper.FlashTextType.NoTarget)
		return BaseSubAction.Failed
	
	# Enemy NPCs
	if not actor.is_player:
		if AiHandler.try_handle_get_target_sub_action(actor, selection_data, parent_action, game_state):
			return BaseSubAction.Success
		else:
			return BaseSubAction.Failed 
	
	# Auto Targeting
	if allow_auto and CombatRootControl.Instance.auto_targeting_enabled: 
		# Get viable targets
		var auto_targets = TargetingHelper.get_auto_targets_for_page(selection_data, parent_action, actor, game_state)
		
		# Get last targeted Actor
		var last_target_record = CombatRootControl.Instance.last_target_records.get(actor.Id, {})
		var last_target_actor_id = last_target_record.get("ActorId", null)
		# Select last actor if locked on and can be targeted again 
		if last_target_actor_id and last_target_record.get("LockOn", false):
			for target:BaseActor in auto_targets:
				if target.Id == last_target_actor_id:
					turn_data.add_target_for_key(setting_target_key, target_param_key, target)
					return BaseSubAction.Success
		# Auto-Select single target if only one Actor in range 
		if auto_targets.size() == 1:
			turn_data.add_target_for_key(setting_target_key, target_param_key, auto_targets[0])
			CombatRootControl.Instance.last_target_records[actor.Id] = {"ActorId": auto_targets[0].Id, "LockOn": false}
			return BaseSubAction.Success
	
	CombatRootControl.pause_combat()
	
	CombatUiControl.ui_state_controller.set_ui_state_from_path(
		"res://assets/Scripts/Actions/Targeting/UiState_Targeting.gd",
	{
		"TargetSelectionData": selection_data,
		"AllowLockon": allow_auto
	})
	return BaseSubAction.Success
