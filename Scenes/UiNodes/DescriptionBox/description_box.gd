class_name DescriptionBox
extends RichTextLabel

const pop_up_container_path = "res://Scenes/UiNodes/DescriptionBox/DescriptionPopUpContainer/description_popup_container.tscn"

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
	popup_container.message_box.add_text(data.get("data"))
	var content_scale = get_window().content_scale_factor
	popup_container.scale  = Vector2.ONE
	#if content_scale != 1:
		#popup_container.scale = Vector2.ZERO * (1.0/content_scale)

func _hide_pop_up(data):
	if popup_container:
		popup_container.hide()

func set_page_item(page:BasePageItem, actor:BaseActor=null):
	if page.get_action_key():
		var action = page.get_action()
		set_object(action._def, action, actor)
	else:
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
			

func _build_bbcode_array(object_def:Dictionary, object_inst:BaseLoadObject, actor:BaseActor)->Array:
	var out_arr = []
	var raw_description = object_def.get("Details", {}).get("Description", "")
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
				var color = sub_tokens[1]
				out_line += "[color=#460000]" + sub_tokens[2] + "[/color]"
			"#AccMod":
				var attack_details = object_def.get("AttackDetails", {})
				var acc_mod = attack_details.get("AccuracyMod", 1)
				out_line += "[color=#460000]" + str(acc_mod * 100) + "% Accuracy[/color]"
			"#TrgParm":
				var target_params_datas = object_def.get("TargetParams", {})
				var param_data = target_params_datas.get(sub_tokens[1], {})
				if param_data.has(sub_tokens[2]):
					out_line += "[color=#460000]" + str(param_data[sub_tokens[2]]) + "[/color]"
			"#DmgData":
				var damage_data = {}
				var damage_key = sub_tokens[1]
				var no_actor_text = ''
				if sub_tokens.size() > 2:
					no_actor_text = sub_tokens[2]
				if object_inst is BaseAction:
					var damage_datas = object_inst.get_damage_datas(actor, damage_key)
					for data_key:String in damage_datas.keys():
						if data_key.begins_with(damage_key):
							damage_data = damage_datas[data_key]
				elif object_def.has("DamageDatas"):
					damage_data = object_def.get("DamageDatas", {}).get(damage_key, {})
				if damage_data.size() == 0:
					continue
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
					var damage_type = damage_data.get("DamageType", "???")
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
						sub_line = val_line + "% " + damage_type + " Damage" 
					
				if actor and not is_percent_hp_damage:
					hover_line = sub_line
					var min_max = DamageHelper.get_min_max_damage(actor, damage_data)
					var damage_type = damage_data.get("DamageType", "???")
					if min_max[0] == min_max[1]:
						sub_line = str(min_max[0]) + damage_type + " Damage"
					else:
						sub_line = str(min_max[0]) + " - " + str(min_max[1]) + " " + damage_type + " Damage" 
				
				if sub_line != '':
					if hover_line != '':
						out_line += "[color=#460000]" + "[url={\"data\":\"" + hover_line+ "\"}]" + sub_line + "[/url]"+ "[/color]"
					else:
						out_line += "[color=#460000]" + sub_line + "[/color]"
			'#EftData':
				var effect_data = {}
				if object_def.has("EffectDatas"):
					effect_data = object_def.get("EffectDatas", {}).get(sub_tokens[1], null)
				elif object_def.has("PageDetails"):
					effect_data = object_def['PageDetails'].get("EffectData", null)
				if not effect_data:
					continue
				var effect_def = EffectLibrary.get_merged_effect_def(effect_data['EffectKey'], effect_data)
				if sub_tokens.size() == 2 or sub_tokens[2] == 'Description':
					var sub_lines = _build_bbcode_array(effect_def, null, actor)
					var display_name = effect_def.get("Details", {}).get("DisplayName", "???")
					out_line += "[color=blue]" + display_name + ". [/color]"
					out_arr.append(out_line)
					out_line = ''
					for line in sub_lines:
						out_arr.append(line)
				elif sub_tokens[2] == 'AplChc':
					out_line += str(effect_data.get("ApplicationChance", 0) * 100) + "%"
				elif sub_tokens[2] == 'Name':
					
					out_line += "[color=blue]" + effect_def.get("Details", {}).get("DisplayName", "???") + "[/color]"
				elif sub_tokens[2] == 'Duration':
					var duration_data = effect_def.get("EffectDetails", {}).get("DurationData", {})
					var value = duration_data.get("BaseDuration", 0)
					var type = duration_data.get("DurationType", '')
					var type_str = type.replace("End", '').replace("Start", '')
					if value > 1:
						type_str += "s"
					out_line += "[color=#460000]" + str(value) + " " + type_str+ "[/color]"
					
			'#StatMod':
				
				if sub_tokens[1] == "MultiMods":
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
						out_line += "[color=#460000]" + "[url={\"data\":\"" + multi_stat_line+ "\"}]" + show_line + "[/url]"+ "[/color]"
					else:
						out_line += multi_stat_line
							
				else:
					var mod_data = {}
					if object_def.has("StatMods"):
						mod_data = object_def.get("StatMods",{}).get(sub_tokens[1],{})
					elif object_def.has("PageDetails"):
						mod_data = object_def.get("PageDetails").get("StatMods",{}).get(sub_tokens[1],{})
					if sub_tokens.size() == 2: # Give whole desription
						var stat_name = mod_data['StatName']
						var value = mod_data['Value']
						var dep_stat_name = mod_data.get("DepStatName", "")
						var mod_type = mod_data.get("ModType", "")
						var abrev = StatHelper.get_stat_abbr(stat_name)
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
						out_line += "[color=#460000]" + str_val + "[/color]"
						
						var icon = StatHelper.get_stat_icon(stat_name)
						if icon: 
							out_arr.append(out_line)
							out_arr.append(icon)
							out_line = ""
						else:
							out_line += " "
						out_line +=  "[color=#460000]" + abrev + "[/color]"
						
					else:
						if sub_tokens[2] == "Icon":
							var stat_name = mod_data['StatName']
							var icon = StatHelper.get_stat_icon(stat_name)
							if icon:
								out_arr.append(out_line)
								out_line = ''
								out_arr.append(icon)
						elif sub_tokens[2] == "StatName":
							var stat_name = mod_data['StatName']
							out_line += "[color=#460000]" + StatHelper.get_stat_abbr(stat_name) + "[/color]"
						elif sub_tokens[2] == "Value":
							var value = mod_data['Value']
							out_line += "[color=#460000]" + str(value) + "[/color]"
						elif sub_tokens[2] == "ValuePercent":
							var value = mod_data['Value']
							out_line += "[color=#460000]" + str(value*100) + "%[/color]"
						elif mod_data.has(sub_tokens[2]):
							out_line += str(mod_data.get(sub_tokens[2], ''))
			'#DmgMod':
				var mod_data = {}
				if object_def.has("DamageMods"):
					mod_data = object_def.get("DamageMods",{}).get(sub_tokens[1],{})
				elif object_def.has("PageDetails"):
					mod_data = object_def.get("PageDetails").get("DamageMods",{}).get(sub_tokens[1],{})
				out_line += _parse_damage_mod(sub_tokens[2], mod_data)
			'#AtkMod':
				var mod_data = {}
				if object_def.has("AttackMods"):
					mod_data = object_def.get("AttackMods",{}).get(sub_tokens[1],{})
				elif object_def.has("PageDetails"):
					mod_data = object_def.get("PageDetails").get("AttackMods",{}).get(sub_tokens[1],{})
				if sub_tokens[2] == 'DmgMod':
					var dmg_mod = mod_data.get("DamageMods", {}).get(sub_tokens[3], {})
					out_line += _parse_damage_mod(sub_tokens[4], dmg_mod)
				
	if out_line != '':
		out_arr.append(out_line)
	return out_arr

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
				out_line +=  "[color=#460000]" + str(mod_value) + "%[/color]"
		elif  mod_type == "Add":
			if mod_value > 0:
				out_line +=  "[color=#460000]+" + str(mod_value) + "[/color]"
			else:
				out_line +=  "[color=#460000]" + str(mod_value) + "[/color]"
		else:
			out_line +=  "[color=#460000]" + str(mod_value) + "[/color]"
	return out_line
