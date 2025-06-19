class_name AttackLogEntry
extends RichTextLabel

const BLUE_TEXT = "[color=#000046]"
const RED_TEXT = "[color=#460000]"
#@export var text_box:RichTextLabel
#
#func _process(delta: float) -> void:
	#self.custom_minimum_size.y = text_box.size.y

func set_event(attack_event:AttackEvent):
	self.text = ""
	self.clear()
	var attacker = ActorLibrary.get_actor(attack_event.attacker_id)
	
	var set_text_val = ''
	var attacker_name = attacker.get_display_name()
	if attacker.is_player:
		attacker_name = BLUE_TEXT + attacker_name + "[/color]"
	else:
		attacker_name = RED_TEXT + attacker_name + "[/color]"
	set_text_val += attacker_name + " hit " 
	if attack_event.defender_ids.size() > 1:
		set_text_val += str(attack_event.defender_ids.size()) + " targets:\n"
	
	for defender_index in range(attack_event.defender_ids.size()):
		var defender = ActorLibrary.get_actor(attack_event.defender_ids[defender_index])
		var sub_event = attack_event.get_sub_event_for_defender(defender.Id)
		
		var defender_name = defender.get_display_name()
		if defender.is_player:
			defender_name = BLUE_TEXT + defender_name + "[/color]"
		else:
			defender_name = RED_TEXT + defender_name + "[/color]"
		
		var damage_vals = {}
		for damage_event:DamageEvent in sub_event.damage_events.values():
			var damage_type = DamageEvent.DamageTypes.keys()[damage_event.damage_type]
			if not damage_vals.has(damage_type):
				damage_vals[damage_type] = damage_event.final_damage
			else:
				damage_vals[damage_type] +=  damage_event.final_damage
		var dmg_strings = []
		for key in damage_vals.keys():
			dmg_strings.append("%s %s" % [damage_vals[key], key])
		var damage_string = RED_TEXT + (", ".join(dmg_strings)) + "[/color]"
		set_text_val += "%s for %s Damage" % [
			defender_name,
			damage_string
		]
		if sub_event.applied_effect_datas.size() > 0:
			var ailment_names = []
			for key in sub_event.applied_effect_datas.keys():
				if not sub_event.applied_effect_datas[key].get("WasApplied", false):
					continue
				var apply_effect_data = sub_event.applied_effect_datas[key]
				var applied_id = apply_effect_data.get("AppliedEffectId", "")
				var effect:BaseEffect = defender.effects.get_effect(applied_id)
				if effect:
					set_text_val += (" and applied [color=#000046]%s[/color]" % [effect.get_display_name()])
			pass
		if attack_event.defender_ids.size() > defender_index + 1:
			set_text_val += "\n"
	self.append_text(set_text_val)
