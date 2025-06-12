class_name DescriptionBox
extends RichTextLabel

const pop_up_container_path = "res://Scenes/UiNodes/DescriptionBox/DescriptionPopUpContainer/description_popup_container.tscn"
const RED_TEXT = "[color=#460000]"


@export var popup_container:DecscriptionPopUpContainer

func _ready() -> void:
	if popup_container:
		popup_container.hide()
	self.meta_clicked.connect(_richtextlabel_on_meta_clicked)
	self.meta_hover_started.connect(_show_pop_up)
	self.meta_hover_ended.connect(_hide_pop_up)

func _richtextlabel_on_meta_clicked(meta):
	print(meta)

func _show_pop_up(data_str):
	if not popup_container:
		popup_container = load(pop_up_container_path).instantiate()
		self.add_child(popup_container)
	var data = JSON.parse_string(data_str)
	popup_container.show()
	popup_container.global_position = self.get_global_mouse_position()
	popup_container.message_box.clear()
	if data:
		if data.has("data"):
			var line = data.get("data", "")
			line = line.replace("|>|", "]").replace("|<|", "[")
			popup_container.message_box.append_text(line)
		elif data.has("EffectKey"):
			var effect_def = EffectLibrary.get_effect_def(data['EffectKey'])
			var lines = _build_bbcode_array(effect_def, null, null)
			for line in lines:
				if line is String:
					popup_container.message_box.append_text(line)
				if line is Texture2D:
					popup_container.message_box.add_image(line, 0, 0, Color(1,1,1,1), INLINE_ALIGNMENT_BOTTOM)
	var content_scale = get_window().content_scale_factor
	popup_container.scale  = Vector2.ONE
	#if content_scale != 1:
		#popup_container.scale = Vector2.ZERO * (1.0/content_scale)

func _hide_pop_up(data):
	if popup_container:
		popup_container.hide()

func set_page_item(page:BasePageItem, actor:BaseActor=null):
	set_object(page._def, page, actor)

func set_object(object_def:Dictionary, object_inst:BaseLoadObject, actor:BaseActor):
	self.clear()
	var lines = _build_bbcode_array(object_def, object_inst, actor)
	for line in lines:
		if line is String:
			self.append_text(line)
		if line is Texture2D:
			#var font := get_theme_default_font()
			#var font_size := get_theme_default_font_size()
			#var font_hight = font.get_height(font_size)
			self.add_image(line, 0, 0, Color(1,1,1,1), INLINE_ALIGNMENT_BOTTOM)
	
func get_damage_colored_text(damage_type, text_value='')->String:
	if damage_type is String and DamageEvent.DamageTypes.keys().has(damage_type):
		damage_type = DamageEvent.DamageTypes.get(damage_type)
	if not DamageEvent.DamageTypes.values().has(damage_type):
		return str(damage_type)
	
	if text_value == '':
		text_value = DamageEvent.DamageTypes.keys()[damage_type]
	var color_code = DamageHelper.get_damage_color(damage_type, true) 
	var out_line_color = "#000000"
	if damage_type == DamageEvent.DamageTypes.Dark:
		out_line_color = "#808080"
	var start_tag =  "[color=#" + color_code + "][outline_size=4][outline_color="+out_line_color+"]"
	var end_tag = "[/outline_color][/outline_size][/color]"
	return start_tag + text_value + end_tag
		

func _build_bbcode_array(object_def:Dictionary, object_inst:BaseLoadObject, actor:BaseActor)->Array:
	var out_arr = []
	var raw_description = object_def.get("#ObjDetails", {}).get("Description", "")
	var tokens = raw_description.split("@@")
	var out_line = ''
	for token:String in tokens:
		if token == '': # Caused by two back to back "@@#Bala@@@@#Somthing@@
			continue
		if not token.begins_with("#"):
			out_line += token
			continue
		var sub_tokens = token.split(":")
		match sub_tokens[0]:
			'#Color': 
				var start_tag = RED_TEXT
				var mid_value = sub_tokens[1]
				var end_tag = "[/color]"
				if sub_tokens.size() == 2:
					mid_value = sub_tokens[1]
				elif sub_tokens[1] == "DmgColor":
					var color_code = DamageHelper.get_damage_color(sub_tokens[2], true) 
					start_tag = "[color=#" + color_code + "][outline_size=4][outline_color=#000000]"
					if sub_tokens.size() == 4:
						mid_value = sub_tokens[3]
					else:
						mid_value = sub_tokens[2]
					end_tag = "[/outline_color][/outline_size][/color]"
				elif sub_tokens[1] == "Ammo":
					var ammo_type = sub_tokens[2]
					if ammo_type == "Mag":
						start_tag = "[color=#A0A0FF][outline_size=4][outline_color=#30304C]"
					elif ammo_type == "Phy":
						start_tag = "[color=#FFD093][outline_size=4][outline_color=#7F5F00]"
					elif ammo_type == "Abn":
						start_tag = "[color=#FFFFFF][outline_size=4][outline_color=#000000]"
					else:
						start_tag = "[color=#262626][outline_size=4][outline_color=#5E5E5E]"
					
					mid_value = sub_tokens[3]
					end_tag = "[/outline_color][/outline_size][/color]"
				elif sub_tokens.size() == 3 and sub_tokens[1] == "Blue":
					start_tag = "[color=#000046]"
					mid_value = sub_tokens[2]
				else:
					mid_value = sub_tokens[2]
				out_line += start_tag + mid_value + end_tag
				
			"#AccMod":
				var attack_details = object_def.get("ActionData", {}).get("AttackDetails", {})
				var acc_mod = attack_details.get("AccuracyMod", 1)
				out_line += RED_TEXT + str(acc_mod * 100) + "% Accuracy[/color]"
			"#TrgParm":
				var target_params_datas = object_def.get("ActionData", {}).get("TargetParams", {})
				var param_data = target_params_datas.get(sub_tokens[1], {})
				if param_data.has(sub_tokens[2]):
					out_line += RED_TEXT + str(param_data[sub_tokens[2]]) + "[/color]"
			"#DmgData":
				var damage_data = {}
				var damage_key = sub_tokens[1]
				var no_actor_text = ''
				if sub_tokens.size() > 2:
					no_actor_text = sub_tokens[2]
				if object_inst is PageItemAction:
					var damage_datas = object_inst.get_damage_datas(actor, damage_key)
					for data_key:String in damage_datas.keys():
						if data_key.begins_with(damage_key):
							damage_data = damage_datas[data_key]
				elif object_def.has("ActionData"):
					damage_data = object_def.get("ActionData", {}).get("DamageDatas", {}).get(damage_key, {})
				elif object_def.has("EffectData"):
					damage_data = object_def.get("EffectData", {}).get("DamageDatas", {}).get(damage_key, {})
				elif object_def.has("DamageDatas"):
					damage_data = object_def.get("DamageDatas", {}).get(damage_key, {})
				if damage_data.size() == 0:
					continue
				var damage_type = damage_data.get("DamageType", "???")
				var hover_line = ''
				var sub_line = ''
				var is_percent_hp_damage = false
				if no_actor_text != '':
					sub_line = no_actor_text
				elif damage_data.has("WeaponFilter"):
					var atk_scale = damage_data.get("AtkPwrScale", 1)
					if atk_scale == 1:
						sub_line += "Weapon Damage"
					else:
						sub_line += str(atk_scale * 100) + "% Weapon Damage"
				else:
					var atk_power = damage_data.get("AtkPwrBase", 0)
					if damage_data.has("AtkPwrStat") and actor:
						atk_power = actor.stats.get_stat(damage_data["AtkPwrStat"], 1)
					var atk_varient = damage_data.get("AtkPwrRange", 0)
					var atk_scale = damage_data.get("AtkPwrScale", 1)
					var atk_stat:String = damage_data.get("AtkStat", "")
					var val_line = str(atk_power)
					if atk_varient > 0:
						val_line += "@" + str(atk_varient)
					if atk_stat.begins_with("Percent"):
						is_percent_hp_damage = true
						sub_line = val_line + "% Max HP as " + damage_type + " Damage" 
					else:
						sub_line = val_line + "% " + StatHelper.get_stat_abbr(atk_stat) + " as " + damage_type + " Damage" 
					
				if actor and not is_percent_hp_damage:
					hover_line = sub_line
					var min_max = DamageHelper.get_min_max_damage(actor, damage_data)
					if min_max[0] == min_max[1]:
						sub_line = str(min_max[0]) + damage_type + " Damage"
					else:
						sub_line = str(min_max[0]) + " - " + str(min_max[1]) + " " + damage_type + " Damage" 
				
				if sub_line != '':
					sub_line = sub_line.replace(damage_type, "[/color]" + get_damage_colored_text(damage_type) + RED_TEXT)
					if hover_line != '':
						out_line += "[url={\"data\":\"" + hover_line+ "\"}]" + RED_TEXT + sub_line + "[/color]" + "[/url]"
					else:
						out_line += RED_TEXT + sub_line + "[/color]"
			'#EftData':
				var effect_data = {}
				if object_def.has("EffectDatas"):
					effect_data = object_def.get("EffectDatas", {}).get(sub_tokens[1], null)
				elif object_def.has("ActionData"):
					effect_data = object_def['ActionData'].get("EffectDatas", null).get(sub_tokens[1], null)
				if not effect_data:
					continue
				var effect_key = effect_data.get("EffectKey", "")
				var prop_key = ''
				if sub_tokens.size() > 2:
					prop_key = sub_tokens[2]
				out_arr.append(out_line)
				out_line = ''
				var sub_lines = _parse_effect(effect_key, effect_data, prop_key, actor)
				out_arr.append_array(sub_lines)
			'#EftDef':
				var effect_data = {}
				var effect_key = sub_tokens[1]
				var prop_key = 'Link'
				if sub_tokens.size() > 2:
					prop_key = sub_tokens[2]
				out_arr.append(out_line)
				out_line = ''
				var sub_lines = _parse_effect(effect_key, effect_data, prop_key, actor)
				
				out_arr.append_array(sub_lines)
					
			'#StatMod':
				
				var mod_data = {}
				if object_def.has("StatMods"):
					mod_data = object_def.get("StatMods",{}).get(sub_tokens[1],{})
				elif object_def.has("EquipmentData"):
					mod_data = object_def.get("EquipmentData").get("StatMods",{}).get(sub_tokens[1],{})
				elif object_def.has("EffectData"):
					mod_data = object_def.get("EffectData").get("StatMods",{}).get(sub_tokens[1],{})
				var parsed_lines = _parse_stat_mod(mod_data, object_def, object_inst, actor, sub_tokens)
				out_arr.append(out_line)
				out_arr.append_array(parsed_lines)
				out_line = ''
				
			'#DmgMod':
				var mod_data = {}
				if object_def.has("DamageMods"):
					mod_data = object_def.get("DamageMods",{}).get(sub_tokens[1],{})
				elif object_def.has("EquipmentData"):
					mod_data = object_def.get("EquipmentData").get("DamageMods",{}).get(sub_tokens[1],{})
				out_line += _parse_damage_mod(sub_tokens[2], mod_data)
			'#AtkMod':
				var mod_data = {}
				if object_def.has("AttackMods"):
					mod_data = object_def.get("AttackMods",{}).get(sub_tokens[1],{})
				elif object_def.has("EquipmentData"):
					mod_data = object_def.get("EquipmentData").get("AttackMods",{}).get(sub_tokens[1],{})
				if sub_tokens[2] == 'DmgMod':
					var dmg_mod = mod_data.get("DamageMods", {}).get(sub_tokens[3], {})
					out_line += _parse_damage_mod(sub_tokens[4], dmg_mod)
				# Defender Faction Filter
				if sub_tokens[2] == 'DefFacFil':
					var factions = []
					for def_con in mod_data.get("Conditions", {}).get("DefendersConditions", []):
						for filter:String in def_con.get("DefenderFactionFilters", []):
							if not factions.has(filter):
								factions.append(_get_title_specific_faction_name(actor, filter, true))
					out_line += RED_TEXT + ", ".join(factions) + "[/color]"
				if sub_tokens[2] == 'StatMod':
					var mod_key = sub_tokens[3]
					var stat_mod_data = mod_data.get("StatMods", {}).get(mod_key, {})
					var sub_sub_tokens = sub_tokens.duplicate() 
					sub_sub_tokens.remove_at(0)
					sub_sub_tokens.remove_at(0)
					var parsed_lines = _parse_stat_mod(stat_mod_data, object_def, object_inst, actor, sub_sub_tokens)
					out_arr.append(out_line)
					out_arr.append_array(parsed_lines)
					out_line = ''
				if sub_tokens[2] == 'AtkSrcFil':
					var what_ever_tags = []
					var tag_filters = mod_data.get("Conditions", {}).get("AttackSourceTagFilters", [])
					for filter:Dictionary in tag_filters:
						what_ever_tags.append_array(filter.get("RequireAnyTags", []))
					out_line += RED_TEXT + ", ".join(what_ever_tags) + "[/color]"
					
					
					
				
	if out_line != '':
		out_arr.append(out_line)
	return out_arr

func _get_title_specific_faction_name(actor:BaseActor, faction_name:String, force_plur:bool=false)->String:
	var val = faction_name
	if force_plur:
		# TODO: Obviously bad for translations
		if val.ends_with("y"):
			val = val.trim_suffix("y") + "ies"
		elif not val.ends_with("s"):
			val += "s"
	return val

func _parse_damage_mod(parse_type:String, mod_data:Dictionary)->String:
	var out_line = ''
	if parse_type == 'Value':
		var mod_type = mod_data.get("ModType")
		var mod_value = mod_data.get("Value")
		if mod_type == "Scale":
			mod_value = (mod_value-1) * 100
			if mod_value > 0:
				out_line +=  "[color=#460000]+" + str(mod_value) + "%[/color]"
			else:
				out_line +=  RED_TEXT + str(mod_value) + "%[/color]"
		elif  mod_type == "Add":
			if mod_value > 0:
				out_line +=  "[color=#460000]+" + str(mod_value) + "[/color]"
			else:
				out_line +=  RED_TEXT + str(mod_value) + "[/color]"
		else:
			out_line +=  RED_TEXT + str(mod_value) + "[/color]"
	return out_line

func _parse_stat_mod(mod_data:Dictionary, object_def:Dictionary, object_inst:BaseLoadObject, actor:BaseActor, sub_tokens:Array)->Array:
	var out_arr = []
	var out_line = ''
	if mod_data.size() == 0:
		return ["No Mod"]
	# Multiple mods compressed into one line
	if sub_tokens[1] == "MultiMods":
		return [_parse_stat_mod_multi(object_def, object_inst, actor, sub_tokens)]
	
	if sub_tokens.size() == 2: # Give whole desription
		var stat_name:String = mod_data.get('StatName', "???")
		var value = mod_data.get('Value', 0)
		var dep_stat_name = mod_data.get("DepStatName", "")
		var mod_type = mod_data.get("ModType", "")
		
		
		var display_stat_name = StatHelper.get_stat_abbr(stat_name)
		var str_val = str(value)
		if mod_type == "Add" and value > 0:
			str_val = "+" + str_val
		if mod_type == "Scale":
			str_val = "x" + str_val
		if mod_type == "AddStat":
			if actor:
				value = actor.stats.get_stat(dep_stat_name, 0)
				str_val = "+"+str(value)+"["+StatHelper.get_stat_abbr(dep_stat_name)+"] to "
			else:
				str_val = "+"+StatHelper.get_stat_abbr(dep_stat_name)+" to "
		if stat_name.begins_with("Resistance"):
			str_val += "%"
		out_line += RED_TEXT + str_val + "[/color]"
		
		var icon = StatHelper.get_stat_icon(stat_name)
		if icon: 
			out_arr.append(out_line)
			out_arr.append(icon)
			out_line = ""
		else:
			out_line += " "
		out_line +=  RED_TEXT + display_stat_name + "[/color]"
		
	else:
		if sub_tokens[2] == "Icon":
			var stat_name = mod_data['StatName']
			var icon = StatHelper.get_stat_icon(stat_name)
			if icon:
				out_arr.append(out_line)
				out_line = ''
				out_arr.append(icon)
		elif sub_tokens[2] == "StatName":
			var stat_name:String = mod_data['StatName']
			if stat_name.begins_with("Resistance:"):
				var damage_type = stat_name.trim_prefix("Resistance:")
				out_line += get_damage_colored_text(damage_type, damage_type + " Res")
			else:
				out_line += RED_TEXT + StatHelper.get_stat_abbr(stat_name) + "[/color]"
		
		elif sub_tokens[2] == "Stat":
			var stat_name = mod_data['StatName']
			var icon = StatHelper.get_stat_icon(stat_name)
			if icon:
				out_arr.append(out_line)
				out_line = ''
				out_arr.append(icon)
			if stat_name.begins_with("Resistance:"):
				var damage_type = stat_name.trim_prefix("Resistance:")
				out_line += get_damage_colored_text(damage_type, damage_type + " Res")
			else:
				out_line += RED_TEXT + StatHelper.get_stat_abbr(stat_name) + "[/color]"
		elif sub_tokens[2] == "Value":
			var value = mod_data['Value']
			out_line += RED_TEXT + str(value) + "[/color]"
		elif sub_tokens[2] == "ValuePercent":
			var value = mod_data['Value']
			out_line += RED_TEXT + str(value*100) + "%[/color]"
		elif mod_data.has(sub_tokens[2]):
			out_line += str(mod_data.get(sub_tokens[2], ''))
	out_arr.append(out_line)
	return out_arr

func _parse_stat_mod_multi(object_def:Dictionary, object_inst:BaseLoadObject, actor:BaseActor, sub_tokens:Array)->String:
	var out_line = ''
	var mod_datas = {}
	if object_def.has("StatMods"):
		mod_datas = object_def.get("StatMods",{})
	elif object_def.has("PageDetails"):
		mod_datas = object_def.get("PageDetails").get("StatMods",{})
	var mods_by_type_value = {}
	for mod_data in mod_datas.values():
		var type = mod_data.get("ModType", "")
		var val = mod_data.get("Value", 0)
		var stat = mod_data.get("StatName", "")
		if not mods_by_type_value.has(type):
			mods_by_type_value[type] = {}
		if not mods_by_type_value[type].has(val):
			mods_by_type_value[type][val] = []
		mods_by_type_value[type][val].append(stat)
	var multi_stat_line = ""
	for mod_type in mods_by_type_value.keys():
		for value in mods_by_type_value[mod_type].keys():
			if not multi_stat_line == "":
				multi_stat_line += "\n"
			var str_val = str(value)
			if mod_type == "Add" and value > 0:
				multi_stat_line = "+" + str_val
			if mod_type == "Scale":
				multi_stat_line = "x" + str_val
			multi_stat_line += " " + ", ".join(mods_by_type_value[mod_type][value])
	if sub_tokens.size() > 2:
		var show_line = sub_tokens[2]
		out_line += RED_TEXT + "[url={\"data\":\"" + multi_stat_line+ "\"}]" + show_line + "[/url]"+ "[/color]"
	else:
		out_line += multi_stat_line
	return out_line

func _parse_effect(effect_key:String, effect_data:Dictionary, prop_key:String, actor:BaseActor=null)->Array:
	var out_arr = []
	var out_line = ''
	var effect_def = EffectLibrary.get_merged_effect_def(effect_key, effect_data)
	if prop_key == '' or prop_key == 'Description':
		var sub_lines = _build_bbcode_array(effect_def, null, actor)
		var display_name = effect_def.get("#ObjDetails", {}).get("DisplayName", "???")
		out_line += "[color=blue]" + display_name + ". [/color]"
		out_arr.append(out_line)
		out_line = ''
		for line in sub_lines:
			out_arr.append(line)
	elif prop_key == 'AplChc':
		out_line += str(effect_data.get("ApplicationChance", 0) * 100) + "%"
	elif prop_key == 'Name':
		
		out_line += "[color=blue]" + effect_def.get("#ObjDetails", {}).get("DisplayName", "???") + "[/color]"
	elif prop_key == 'Duration':
		var duration_data = effect_def.get("EffectData", {}).get("EffectDetails", {}).get("DurationData", {})
		var value = duration_data.get("BaseDuration", 0)
		var type = duration_data.get("DurationTrigger", '')
		var type_str = type.replace("End", '').replace("Start", '').trim_prefix("On")
		if value > 1:
			type_str += "s"
		out_line += RED_TEXT + str(value) + " " + type_str+ "[/color]"
	elif prop_key == "Link":
		#var sub_lines = _build_bbcode_array(effect_def, null, actor)
		#var url_line = ''
		#for lin in sub_lines:
			#if lin is String:
				#url_line += lin
		##url_line = "Test"
		#url_line = url_line.replace("[", "|<|").replace("]", "|>|")
		out_line += "[color=blue]" + "[url={\"EffectKey\":\"" + effect_key + "\"}]" +  effect_def.get("#ObjDetails", {}).get("DisplayName", "???") + "[/url][/color]"
		
	out_arr.append(out_line)
	return out_arr
