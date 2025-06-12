class_name SubAct_DEV_SimAttacks
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Attack"]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	#
	#var turn_data = que_exe_data.get_current_turn_data()
	#var target_key = subaction_data['TargetKey']
	#var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
	#var target_param_key = turn_data.get_param_key_for_target(target_key)
	#var target_params = parent_action.get_targeting_params(target_param_key, actor)
	#
	#var weapon = actor.equipment.get_primary_weapon()
	#if !weapon:
		#printerr("No Weapon")
		#return BaseSubAction.Failed
	#var damage_data = (weapon as BaseWeaponEquipment).get_damage_data()
	#
	#var tag_chain = SourceTagChain.new()\
			#.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			#.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	#
	#
	#for target:BaseActor in targets:
		#for i in range(10):
			#var attack_event = DamageHelper.handle_attack(actor, target, {}, damage_data, [], tag_chain, game_state,target_params)
			#log_attack_event(attack_event)
	#
	##var offhand_weapon = actor.equipment.get_offhand_weapon()
	##if offhand_weapon:
		##var offhand_damage_data = (offhand_weapon as BaseWeaponEquipment).get_damage_data()
		##for target:BaseActor in targets:
			##DamageHelper.handle_attack(actor, target, offhand_damage_data, tag_chain, game_state)
	#
	return BaseSubAction.Success
	
func log_attack_event(attack_event:AttackEvent):
	for damage_event in attack_event.damage_events:
		log_damage_event(damage_event)

func log_damage_event(event:DamageEvent):
	print("-------------------------------------------------------------------------")
	print("| Attacker: BsDm:%s | AtkPow:%s | DmVar:%s | DefType:%s" % [event.base_damage, event.attack_power, event.attack_power_range, event.defense_type])
	print("| AppliedPower:%2.3f -> RawDam:%2.2f" % [event.applied_power, event.raw_damage])
	print("| Def:%s -> DefRed: %2.2f -> Dam:%2.2f" % [event.defense_value, (1-event.defense_reduction), event.damage_after_armor])
	print("| AttackMods -> Dam: %2.2f" % [event.damage_after_attack_mods])
	print("| DefenseMods -> Dam: %2.2f" % [event.damage_after_defend_mods])
	print("| Final Damage: %s" % [event.final_damage])
	print("-------------------------------------------------------------------------")
