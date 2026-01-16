class_name AttackLogEntry
extends RichTextLabel

const BLUE_TEXT = "[color=#000046]"
const RED_TEXT = "[color=#460000]"
const GREEN_TEXT = "[color=#004600]"
#@export var text_box:RichTextLabel
#
#func _process(delta: float) -> void:
	#self.custom_minimum_size.y = text_box.size.y


## TODO: Translation
func set_event(attack_event:AttackEvent):
	self.text = ""
	self.clear()
	var attacker = ActorLibrary.get_actor(attack_event.attacker_id)
	
	var attacker_name = attacker.get_display_name()
	if attacker.is_player:
		attacker_name = BLUE_TEXT + attacker_name + "[/color]"
	else:
		attacker_name = RED_TEXT + attacker_name + "[/color]"
	
	var display_name = attack_event.attack_details.get("DisplayName", "an Attack")
	var action_verb = attack_event.attack_details.get("ActionVerb", "used " + display_name + " on")
	# Actor [Action_Verb] Defender
	# Action_Verb: attacked | healed | threw a "Item" at | poarded "Potion" on | ... 
	
	# Single defender attack
	if attack_event.defender_ids.size() == 1:
		var defender_id = attack_event.defender_ids[0]
		var defender = ActorLibrary.get_actor(defender_id)
		var sub_event = attack_event.get_sub_event_for_defender(defender_id)
		
		var defender_name = defender.get_display_name()
		if defender.is_player:
			defender_name = BLUE_TEXT + defender_name + "[/color]"
		else:
			defender_name = RED_TEXT + defender_name + "[/color]"
		
		var result_line = ''
		
		if attack_event.attack_details.get("AutoHit"):
			result_line = ""
		elif sub_event.is_miss:
			result_line = "but misses"
		elif sub_event.is_evade:
			result_line = "but they evaded"
		elif sub_event.is_blocked:
			result_line = "who blocked"
		else:
			result_line = ""
		
		# Shortcut single damage healing events
		if sub_event.damage_events.size() == 1 and sub_event.damage_events.values()[0].final_damage < 0:
			result_line = "healing for +" + GREEN_TEXT + str(-sub_event.damage_events.values()[0].final_damage) + " HP[/color]"
		else:
			var damage_vals_str = _join_damage_values(sub_event)
			if damage_vals_str != '':
				result_line += " for " + damage_vals_str
		
		if attack_event.final_leached_damage > 0:
			result_line += " and gained " + GREEN_TEXT + str(attack_event.final_leached_damage) + " HP[/color]"
		
		var effects_line = _join_effect_values(attack_event, sub_event)
		if effects_line != '':
			result_line += " " + effects_line
		
		var full_line = attacker_name + " " + action_verb + " " + defender_name + " " + result_line
		self.append_text(full_line)
		return
	else:
		var defender_count = str(attack_event.defender_ids.size()) + " targets"
		var total_damage = attack_event.get_total_damage()
		var result_line = " " + defender_count + " hitting for " + str(total_damage) + " total damage"
		
		var full_line = attacker_name + " " + action_verb + result_line
		self.append_text(full_line)


func _join_damage_values(sub_event:AttackSubEvent)->String:
	var damage_vals = {}
	for damage_event:DamageEvent in sub_event.damage_events.values():
		var damage_type = DamageEvent.DamageTypes.keys()[damage_event.damage_type]
		if not damage_vals.has(damage_type):
			damage_vals[damage_type] = damage_event.final_damage
		else:
			damage_vals[damage_type] +=  damage_event.final_damage
	if damage_vals.size() == 0:
		return ''
	var dmg_strings = []
	for key in damage_vals.keys():
		dmg_strings.append("%s %s" % [damage_vals[key], key])
	return (", ".join(dmg_strings))

func _join_effect_values(attack_event:AttackEvent, sub_event:AttackSubEvent)->String:
	var resisted_effect_names = []
	var applied_effect_names = []
	for effect_data_key in sub_event.applied_effect_datas.keys():
		var effect_key = attack_event.effect_datas[effect_data_key].get("EffectKey", "")
		var effect_def = EffectLibrary.get_effect_def(effect_key)
		var display_name = effect_def.get("#ObjDetails", {}).get("DisplayName", "EFFECT_NAME")
		if sub_event.applied_effect_datas[effect_data_key].get("WasApplied", false):
			applied_effect_names.append(display_name)
		else:
			resisted_effect_names.append(display_name)
	var out_line = ''
	if applied_effect_names.size() > 0: 
		out_line += "and applied " + (",".join(applied_effect_names))
	if resisted_effect_names.size() > 0: 
		if applied_effect_names.size() > 0: 
			out_line += " but "
		out_line += "but they reisted " + (",".join(resisted_effect_names))
	return out_line
	
