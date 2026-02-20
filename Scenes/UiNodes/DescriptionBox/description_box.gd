class_name DescriptionBox
extends RichTextLabel

const pop_up_container_path = "res://Scenes/UiNodes/DescriptionBox/DescriptionPopUpContainer/description_popup_container.tscn"
const RED_TEXT = "[color=#460000]"
const BLUE_TEXT = "[color=#000046]"

const COLORS_DIC = {
	"Red": RED_TEXT,
	"Blue": BLUE_TEXT,
	"Grey": "[color=#3f3f3f]"
}

@export var popup_container:DecscriptionPopUpContainer

func _ready() -> void:
	if popup_container:
		popup_container.hide()
	self.meta_clicked.connect(_richtextlabel_on_meta_clicked)
	self.meta_hover_started.connect(_show_pop_up)
	self.meta_hover_ended.connect(_on_mouse_hover_end)

func _richtextlabel_on_meta_clicked(meta):
	print(meta)

func _show_pop_up(data_str):
	if not popup_container:
		popup_container = load(pop_up_container_path).instantiate()
		#self.get_parent_control()
		self.add_child(popup_container)
	var data = JSON.parse_string(data_str)
	var mouse_pos = self.get_global_mouse_position()
	popup_container.show()
	popup_container.global_position = mouse_pos
	popup_container.message_box.clear()
	popup_container.parent_description_box = self
	
	if data:
		if data.has("text"):
			var line = data.get("text", "")
			line = line.replace("|>|", "]").replace("|<|", "[").replace('\\"', '"')
			popup_container.set_text(line)
		elif data.has("EffectKey"):
			var effect_def = EffectLibrary.get_effect_def(data['EffectKey'])
			var effect_description = effect_def.get("#ObjDetails", {}).get("Description", "")
			var lines = _build_bbcode_array(effect_description, effect_def, null, null)
			for line in lines:
				if line is String:
					popup_container.message_box.append_text(line)
				if line is Texture2D:
					popup_container.message_box.add_image(line, 0, 0, Color(1,1,1,1), INLINE_ALIGNMENT_BOTTOM)
	#var content_scale = get_window().content_scale_factor
	#popup_container.scale  = Vector2.ONE
	#if content_scale != 1:
		#popup_container.scale = Vector2.ZERO * (1.0/content_scale)

func color_text(color, raw_text)->String:
	if color is String:
		if color.begins_with("[color=#"):
			color = color.trim_prefix("[color=#")
		if color.ends_with("]"):
			color = color.trim_suffix("]")
	return "[color=#" + color + "]" + raw_text + "[/color]"

func _on_mouse_hover_end(_data):
	pass

func _hide_pop_up(_data):
	if popup_container:
		if is_instance_valid(popup_container):
			popup_container.queue_free()
		popup_container = null

func set_page_item(page:BasePageItem, actor:BaseActor=null):
	if not page:
		self.clear()
		self.append_text("NULL PAGE")
		return
	var merged_def = BaseLoadObjectLibrary._merge_defs(page._data, page._def)
	set_object(merged_def, page, actor)

func set_effect(effect:BaseEffect):
	if not effect:
		self.clear()
		self.append_text("NULL PAGE")
		return
	var merged_def = BaseLoadObjectLibrary._merge_defs(effect._data, effect._def)
	set_object(merged_def, effect, effect.get_effected_actor())


func set_object(object_def:Dictionary, object_inst:BaseLoadObject, actor:BaseActor):
	self.clear()
	var raw_description = object_def.get("#ObjDetails", {}).get("Description", "")
	var lines = _build_bbcode_array(raw_description, object_def, object_inst, actor)
	for line in lines:
		if line is String:
			self.append_text(line)
		if line is Texture2D:
			#var font := get_theme_default_font()
			#var font_size := get_theme_default_font_size()
			#var font_hight = font.get_height(font_size)
			self.add_image(line, 0, self.get_theme_font_size("normal_font"), Color(1,1,1,1), INLINE_ALIGNMENT_TOP)
	
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
		

func _build_bbcode_array(raw_description:String, object_def:Dictionary, object_inst:BaseLoadObject, actor:BaseActor)->Array:
	var out_arr = []
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
			'#EftChances':
				out_arr.append(out_line)
				out_line = ''
				var sub_lines = _parse_effect_chances(sub_tokens, object_def, object_inst, actor)
				out_arr.append_array(sub_lines)
				
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
				elif sub_tokens.size() == 3 and COLORS_DIC.keys().has(sub_tokens[1]):
					start_tag = COLORS_DIC[sub_tokens[1]]
					mid_value = sub_tokens[2]
				else:
					mid_value = sub_tokens[2]
				out_line += start_tag + mid_value + end_tag
			
			"#Stat":
				var stat_name = sub_tokens[1]
				var display_stat_name = StatHelper.get_stat_abbr(stat_name)
				var icon = StatHelper.get_stat_icon(stat_name)
				if icon: 
					out_arr.append(out_line)
					out_arr.append(icon)
					out_line = ""
				else:
					out_line += " "
				if StatHelper.CoreStats.keys().has(stat_name):
					display_stat_name = stat_name.substr(1)
				out_line +=  color_text(RED_TEXT, display_stat_name)
			
			"#Tag":
				out_arr.append(out_line)
				out_line = ''
				var sub_lines = _parse_tag_info(sub_tokens)
				out_arr.append_array(sub_lines)
			
			"#AccMod":
				var attack_details = object_def.get("ActionData", {}).get("AttackDetails", {})
				var acc_mod = attack_details.get("AccuracyMod", 1)
				out_line += color_text(RED_TEXT, str(acc_mod * 100) + "% Accuracy")
			"#TrgParm":
				var target_params_datas = object_def.get("ActionData", {}).get("TargetParams", {})
				var param_data = target_params_datas.get(sub_tokens[1], {})
				if param_data.has(sub_tokens[2]):
					out_line += color_text(RED_TEXT, str(param_data[sub_tokens[2]]))
			"#DmgData":
				out_line += _parse_damage_data(sub_tokens, object_def, object_inst, actor)
				
			'#EftData':
				var effect_datas =  get_effect_datas_from_def(object_def)
				var effect_data_key = sub_tokens[1]
				var effect_data = effect_datas.get(effect_data_key, null)
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
			'#EffLine':
				var effect_key_data = sub_tokens[1]
				var apply_effect_data = object_def.get("ActionData", {}).get("EffectDatas", {}).get(effect_key_data)
				if apply_effect_data:
					var apply_chance = apply_effect_data.get("ApplicationChance", 0)
					var duration = apply_effect_data.get("Duration", 0)
					out_line += str(apply_chance * 100) + "% chance to apply "
					out_arr.append(out_line)
					out_line = ''
					
					var effect_data = {}
					var prop_key = 'Link'
					var effect_key = apply_effect_data.get("EffectKey", "NoEffKey")
					var sub_lines = _parse_effect(effect_key, effect_data, prop_key, actor)
					out_arr.append_array(sub_lines)
					out_line += " for " + str(duration) + " on hit."
				
			'#StatMod':
				
				var mod_data = get_stat_mods_from_def(object_def)
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
				elif object_def.has("PageData"):
					mod_data = object_def.get("PageData").get("DamageMods",{}).get(sub_tokens[1],{})
				var sub_line = _parse_damage_mod(sub_tokens[2], mod_data)
				if sub_tokens.size() >= 4:
					sub_line = sub_line.replace("[/color]", sub_tokens[3] + "[/color]")
				out_line += sub_line
			'#AtkMod':
				var mod_data = {}
				if object_def.has("AttackMods"):
					mod_data = object_def.get("AttackMods",{}).get(sub_tokens[1],{})
				elif object_def.has("EquipmentData"):
					mod_data = object_def.get("EquipmentData").get("AttackMods",{}).get(sub_tokens[1],{})
				elif object_def.has("PageData"):
					mod_data = object_def.get("PageData").get("AttackMods",{}).get(sub_tokens[1],{})
				elif object_def.has("EffectData"):
					mod_data = object_def.get("EffectData").get("AttackMods",{}).get(sub_tokens[1],{})
				# Damage Mods
				if sub_tokens[2] == 'DmgMod':
					var dmg_mod = mod_data.get("DamageMods", {}).get(sub_tokens[3], {})
					var sub_line = _parse_damage_mod(sub_tokens[4], dmg_mod)
					if sub_tokens.size() >= 6:
						sub_line = sub_line.replace("[/color]", sub_tokens[5] + "[/color]")
					out_line += sub_line
				if sub_tokens[2] == "StatMod":
					var stat_mod = mod_data.get("StatMods", {}).get(sub_tokens[3], {})
					var sub_lines = _parse_stat_mod(stat_mod, object_def, object_inst, actor, sub_tokens)
					out_arr.append(out_line)
					out_arr.append_array(sub_lines)
					out_line = ''
				# Defender Faction Filter
				if sub_tokens[2].begins_with('DefFacFil'):
					var factions = []
					for def_con in mod_data.get("Conditions", {}).get("DefendersConditions", []):
						for filter:String in def_con.get("DefenderTeamFilters", []):
							if not factions.has(filter):
								factions.append(_get_title_specific_faction_name(actor, filter, sub_tokens[2].contains("|Plr")))
					out_line += color_text(RED_TEXT, ", ".join(factions))
				# Defender Tags Filter
				elif sub_tokens[2].begins_with('DefTagsFil'):
					var tags = []
					for def_con in mod_data.get("Conditions", {}).get("DefendersConditions", []):
						for filter:Dictionary in def_con.get("DefenderTagFilters", {}):
							var all_tags = filter.get("RequireAllTags", [])
							var any_tags = filter.get("RequireAnyTags", [])
							tags.append_array(all_tags)
							tags.append_array(any_tags)
					out_line += color_text(RED_TEXT, " ".join(tags))
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
				# Attacker Filters
				if sub_tokens[2] == 'AtkSrcFil':
					var what_ever_tags = []
					var tag_filters = mod_data.get("Conditions", {}).get("AttackSourceTagFilters", [])
					for filter:Dictionary in tag_filters:
						what_ever_tags.append_array(filter.get("RequireAnyTags", []))
					var sub_line = BLUE_TEXT + " ".join(what_ever_tags) + "[/color]"
					if sub_tokens.size() >= 4:
						sub_line = sub_line.replace("[/color]", sub_tokens[3] + "[/color]")
					out_line += sub_line
			"#ZoneData":
				var parsed_line = _parse_zone(object_def, object_inst, actor, sub_tokens)
				out_arr.append(out_line)
				out_arr.append(parsed_line)
				out_line = ''
					
					
					
				
	if out_line != '':
		out_arr.append(out_line)
	return out_arr

func _get_title_specific_faction_name(_actor:BaseActor, faction_name:String, force_plur:bool=false)->String:
	var val = faction_name
	if force_plur:
		# TODO: Obviously bad for translations
		if val.ends_with("y"):
			val = val.trim_suffix("y") + "ies"
		elif not val.ends_with("s"):
			val += "s"
	return val

func _parse_tag_info(tokens:Array)->Array:
	var tag = tokens[1]
	var parse_type = 'Hint'
	if tokens.size() >= 3:
		parse_type = tokens[2]
	var out_line = ''
	var out_arr = []
	match  parse_type:
		"Desc":
			var tag_desc = TagsLibrary.get_tag_description(tag)
			out_arr.append(out_line)
			out_line = ""
			out_arr.append_array(_build_bbcode_array(tag_desc, {}, null, null))
		"Hint":
			var text_val = tag
			if tokens.size() >= 4:
				text_val = tokens[3]
			var hint_text = ''
			var hint_lines = _parse_tag_info(["#Tag", tag, "Desc"])
			for line in hint_lines:
				if line is String:
					hint_text += line.replace("]", "|>|").replace("[", "|<|").replace('"', '\\"')
			out_line += ('[color=blue][url={"text":"' + hint_text + '"}]' +  text_val + "[/url][/color]")
	if out_line != '':
		out_arr.append(out_line)
	return out_arr

func _parse_effect_chances(_tokens:Array, object_def:Dictionary, _object_inst:BaseLoadObject, actor:BaseActor, )->Array:
	var effects_datas = get_effect_datas_from_def(object_def)
	var lines = []
	for effect_data_key in effects_datas.keys():
		var effect_data = effects_datas.get(effect_data_key)
		var effect_key = effect_data.get("EffectKey", effect_data_key)
		var application_chance = effect_data.get("ApplicationChance", 1)
		lines.append("[color=blue]>"+str(application_chance*100)+"% chance to[/color] ")
		lines.append_array(_parse_effect(effect_key, effect_data, "Link", actor))
		lines.append(" [color=blue]on hit.[/color]")
	
	return lines

func _parse_damage_data(tokens:Array, object_def:Dictionary, object_inst:BaseLoadObject, actor:BaseActor, in_damage_data={})->String:
	var out_line = ''
	var damage_data = in_damage_data
	var damage_key = tokens[1]
	var extra_damage_datas = []
	var no_actor_text = ''
	var _is_weapon_damage = false
	if tokens.size() > 2:
		no_actor_text = tokens[2]
	# Get damage data if not provided
	if damage_data.size() == 0:
		if object_inst is PageItemAction:
			# Get Damage Data from Page
			var damage_datas = object_inst.get_damage_datas(actor, damage_key)
			# Get requested DamageData
			if damage_datas.keys().has(damage_key):
				damage_data = damage_datas[damage_key]
			# Cache off any extras that came with (probably OffHand Weapon)
			elif damage_datas.size() > 0:
				extra_damage_datas = damage_datas.values()
				damage_data = extra_damage_datas[0]
				extra_damage_datas.remove_at(0)
				
		elif object_def.has("ActionData"):
			damage_data = object_def.get("ActionData", {}).get("DamageDatas", {}).get(damage_key, {})
		elif object_def.has("EffectData"):
			damage_data = object_def.get("EffectData", {}).get("DamageDatas", {}).get(damage_key, {})
		elif object_def.has("DamageDatas"):
			damage_data = object_def.get("DamageDatas", {}).get(damage_key, {})
	if damage_data.size() == 0:
		return ''
	var damage_type = damage_data.get("DamageType", "???")
	var hover_line = ''
	var description_line = ''
	var is_percent_hp_damage = false
	
	# A description line was given (aka no actor text)
	if no_actor_text != '':
		description_line = no_actor_text
	# Using Weapon damage, so default to X% Weapon Damage
	elif damage_data.has("WeaponFilter"):
		_is_weapon_damage = true
		var atk_scale = damage_data.get("AtkPwrScale", 1)
		if atk_scale == 1:
			description_line += "Weapon Damage"
		else:
			description_line += str(atk_scale) + " x Weapon Damage"
	# Parse actual "100+10% Mag Attack as Fire Damage"
	else:
		var atk_power = damage_data.get("AtkPwrBase", 0)
		if damage_data.has("AtkPwrStat") and actor:
			atk_power = actor.stats.get_stat(damage_data["AtkPwrStat"], 1)
		var atk_varient = damage_data.get("AtkPwrRange", 0)
		var _atk_scale = damage_data.get("AtkPwrScale", 1)
		var atk_stat:String = damage_data.get("AtkStat", "")
		var val_line = str(atk_power)
		if atk_varient > 0:
			val_line += "@" + str(atk_varient)
		if atk_stat.begins_with("Percent"):
			is_percent_hp_damage = true
			description_line = val_line + "% Max HP as " + damage_type + " Damage" 
		else:
			description_line = val_line + "% " + StatHelper.get_stat_abbr(atk_stat) + " as " + damage_type + " Damage" 
		
	if actor and not is_percent_hp_damage:
		hover_line = description_line
		description_line = ''
		
		if damage_data.keys().has("PreviewCount"):
			var preview_count = damage_data.get("PreviewCount")
			description_line = str(preview_count) + " X "
		var min_max = DamageHelper.get_min_max_damage(actor, damage_data)
		if min_max[0] == min_max[1]:
			description_line += str(min_max[0]) + damage_type# + " Damage"
		else:
			description_line += str(min_max[0]) + " - " + str(min_max[1]) + " " + damage_type# + " Damage" 
	
	
	if extra_damage_datas.size() == 0:
		if description_line != '':
			#description_line = description_line.replace(damage_type, "[/color]" + get_damage_colored_text(damage_type) + RED_TEXT)
			if hover_line != '':
				out_line += "[url={\"text\":\"" + hover_line+ "\"}]" + get_damage_colored_text(damage_type, description_line) + "[/url]"
			else:
				out_line += get_damage_colored_text(damage_type, description_line) 
	
		return out_line
	
	# More that one damage data was found, so show total with indiviuals in popup
	var hint_lines = [hover_line, description_line]
	var first_min_max = DamageHelper.get_min_max_damage(actor, damage_data)
	var min = first_min_max[0]
	var max = first_min_max[1]
	for extra in extra_damage_datas:
		var other_damage_type = extra.get("DamageType", "???")
		var min_max = DamageHelper.get_min_max_damage(actor, damage_data)
		var other_min_max_str = str(min_max[0]) + " - " + str(min_max[1])
		if min_max[0] == min_max[1]:
			other_min_max_str = str(min_max[0])
		var other_line = other_min_max_str + " " + other_damage_type
		hint_lines.append(other_line)
		min += min_max[0]
		max += min_max[1]
	var min_max_str = str(min) + " - " + str(max)
	if min == max:
		min_max_str = str(min)
	var hint_line = "\\n".join(hint_lines)
	var show_line = get_damage_colored_text(damage_type, min_max_str + " Damage")
	out_line += "[url={\"text\":\"" + hint_line+ "\"}]" + show_line + "[/url]"
	return out_line


func _parse_damage_mod(parse_type:String, mod_data:Dictionary)->String:
	var out_line = ''
	if parse_type.begins_with('Value'):
		var mod_type = mod_data.get("ModType")
		var mod_value = mod_data.get("Value")
		if mod_type == "Scale":
			mod_value = (mod_value-1) * 100
			if mod_value > 0:
				out_line +=  color_text(RED_TEXT, "+" + str(mod_value) + "%")
			else:
				out_line +=  color_text(RED_TEXT, str(mod_value) + "%")
		elif  mod_type == "Add":
			if mod_value > 0:
				out_line +=  color_text(RED_TEXT, "+" + str(mod_value))
			else:
				out_line +=  color_text(RED_TEXT, str(mod_value))
		else:
			out_line +=  color_text(RED_TEXT, str(mod_value))
	elif parse_type.begins_with('Filters'):
		var filters = []
		var filter_arry = mod_data.get("Conditions", {}).get("SourceTagFilters", [])
		for filt in filter_arry:
			var reqired = filt.get("RequireAnyTags", [])
			for req in reqired:
				if not filters.has(req):
					filters.append(req)
		out_line +=  BLUE_TEXT + (" ".join(filters)) + "[/color]"
	elif parse_type.begins_with('DefFacFil'):
		var filters = []
		var faction_arry = mod_data.get("Conditions", {}).get("DefenderTeamFilters", [])
		for faction:String in faction_arry:
			if parse_type.contains("|Plr"):
				if faction.ends_with("y"):
					faction = faction.trim_suffix("y")
					faction += "ies"
			if not filters.has(faction):
				filters.append(faction)
		out_line +=  color_text(RED_TEXT, " ".join(filters))
	return out_line

func _parse_stat_mod(mod_data:Dictionary, object_def:Dictionary, object_inst:BaseLoadObject, actor:BaseActor, sub_tokens:Array)->Array:
	var out_arr = []
	var out_line = ''
	if mod_data.size() == 0:
		return ["No Mod"]
	# Multiple mods compressed into one line
	if sub_tokens[1] == "MultiMods":
		return [_parse_stat_mod_multi(object_def, object_inst, actor, sub_tokens)]
	
	if mod_data.keys().has(sub_tokens[1]):
		mod_data = mod_data[sub_tokens[1]]
	
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
		out_line += color_text(RED_TEXT, str_val)
		
		var icon = StatHelper.get_stat_icon(stat_name)
		if icon: 
			out_arr.append(out_line)
			out_arr.append(icon)
			out_line = ""
		else:
			out_line += " "
		out_line +=  color_text(RED_TEXT, display_stat_name)
		
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
				out_line += color_text(RED_TEXT, StatHelper.get_stat_abbr(stat_name))
		
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
				out_line += color_text(RED_TEXT, StatHelper.get_stat_abbr(stat_name))
		elif sub_tokens[2] == "Value":
			var value = mod_data['Value']
			out_line += color_text(RED_TEXT,  str(value))
		elif sub_tokens[2] == "ValuePercent":
			var value = mod_data['Value']
			out_line += color_text(RED_TEXT, str(value*100) + "%")
		elif sub_tokens[2] == "InvertPercent":
			var value = mod_data['Value']
			out_line += color_text(RED_TEXT, str((value-1)*100) + "%")
		elif mod_data.has(sub_tokens[2]):
			out_line += str(mod_data.get(sub_tokens[2], ''))
	out_arr.append(out_line)
	return out_arr

func _parse_stat_mod_multi(object_def:Dictionary, _object_inst:BaseLoadObject, _actor:BaseActor, sub_tokens:Array)->String:
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
		out_line += color_text(RED_TEXT, "[url={\"text\":\"" + multi_stat_line+ "\"}]" + show_line + "[/url]")
	else:
		out_line += multi_stat_line
	return out_line

func _parse_effect(effect_key:String, effect_data:Dictionary, prop_key:String, actor:BaseActor=null)->Array:
	var out_arr = []
	var out_line = ''
	if not EffectLibrary.has_effect_key(effect_key):
		# Might be because you used #EftDef instead of #EFtData
		return [color_text(RED_TEXT, "'" + effect_key + "' Not Found")]
	var effect_def = EffectLibrary.get_merged_effect_def(effect_key, effect_data)
	if prop_key == '' or prop_key == 'Description':
		var effect_description = effect_def.get("#ObjDetails", {}).get("Description", "")
		var sub_lines = _build_bbcode_array(effect_description, effect_def, null, actor)
		var display_name = effect_def.get("#ObjDetails", {}).get("DisplayName", "???")
		out_line += "[color=blue]" + display_name + ". [/color]"
		out_arr.append(out_line)
		out_line = ''
		for line in sub_lines:
			out_arr.append(line)
	elif prop_key == 'AplChc':
		out_line += str(effect_data.get("ApplicationChance", 0) * 100) + "%"
	elif prop_key == 'Name' or prop_key == 'DisplayName':
		
		out_line += "[color=blue]" + effect_def.get("#ObjDetails", {}).get("DisplayName", "???") + "[/color]"
	elif prop_key == 'Duration':
		var duration_data = effect_def.get("EffectData", {}).get("EffectDetails", {}).get("DurationData", {})
		var value = duration_data.get("BaseDuration", 0)
		var type = duration_data.get("DurationTrigger", '')
		var type_str = type.replace("End", '').replace("Start", '').trim_prefix("On")
		if value > 1:
			type_str += "s"
		out_line += color_text(RED_TEXT, str(value) + " " + type_str)
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


func _parse_zone(object_def:Dictionary, _object_inst:BaseLoadObject, _actor:BaseActor, sub_tokens:Array)->String:
	var zone_datas = object_def.get("ActionData", {}).get("ZoneDatas", {})
	var zone_key = sub_tokens[1]
	var zone_data = zone_datas.get(zone_key)
	if !zone_data:
		return ""
	
	if sub_tokens.size() > 2 and sub_tokens[2] == 'Duration':
		var dur_val = zone_data.get("Duration", -1)
		var dur_type = zone_data.get("DurationType", "???")
		var line = str(dur_val)+" "+dur_type
		if dur_val > 0:
			line += "s"
		return color_text(RED_TEXT, line)
	
	return ""

func get_effect_datas_from_def(def:Dictionary)->Dictionary:
	if def.has("ActionData"):
		return def['ActionData'].get("EffectDatas", {})
	if def.has("PageData"):
		var effect_key = def['PageData'].get("EffectData", {}).get("EffectKey", null)
		if effect_key:
			return EffectLibrary.get_effect_def(effect_key)
	if def.has("SuppliesData"):
		return def['SuppliesData'].get("EffectDatas", {})
		
	return {}


func get_stat_mods_from_def(def:Dictionary)->Dictionary:
	if def.has("PageData"):
		return def['PageData'].get("StatMods", {})
	if def.has("EffectData"):
		return def['EffectData'].get("StatMods", {})
	if def.has("EquipmentData"):
		return def['EquipmentData'].get("StatMods", {})
	return {}
