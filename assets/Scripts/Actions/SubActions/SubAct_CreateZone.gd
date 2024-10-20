class_name SubAct_CreateZone
extends BaseSubAction

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, _que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	var zone_data = subaction_data['ZoneData']
	var zone:BaseZone
	var center
	if zone_data['ZoneType'] == 'Aura':
		center = actor
	elif zone_data['ZoneType'] == 'Static':
		center = game_state.MapState.get_actor_pos(actor)
	zone = BaseZone.new(zone_data, center)
	CombatRootControl.Instance.add_zone(zone)
	pass
	
