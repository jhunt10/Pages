class_name DescriptionBox
extends RichTextLabel

@export var popup_container:BackPatchContainer
@export var popup_message:RichTextLabel

func _ready() -> void:
	if popup_container:
		popup_container.hide()
		self.meta_clicked.connect(_richtextlabel_on_meta_clicked)
		self.meta_hover_started.connect(_show_pop_up)
		self.meta_hover_ended.connect(_show_pop_hide)

func _richtextlabel_on_meta_clicked(meta):
	print(meta)

func _show_pop_up(data_str):
	var data = JSON.parse_string(data_str)
	popup_container.show()
	popup_message.clear()
	popup_message.add_text(data.get("data"))
	pass

func _show_pop_hide(data):
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
				if damage_data.size() == 0:
					continue
				var hover_line = ''
				var sub_line = ''
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
					var atk_power = damage_data.get("AtkPwrBase", 100)
					if damage_data.has("AtkPwrStat") and actor:
						atk_power = actor.stats.get_stat(damage_data["AtkPwrStat"], 1)
					var atk_varient = damage_data.get("AtkPwrRange", 0)
					var atk_scale = damage_data.get("AtkPwrScale", 1)
					sub_line = str(atk_power) + "@" + str(atk_varient) + "% " + damage_type + " Damage" 
					
				if actor:
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
				var effect_data = object_def.get("EffectDatas", {}).get(sub_tokens[1], null)
				if not effect_data:
					continue
				if sub_tokens[2] == 'AplChc':
					out_line += str(effect_data.get("ApplicationChance", 0) * 100) + "%"
				if sub_tokens[2] == 'Name':
					var effect_def = EffectLibrary.get_effect_def(effect_data['EffectKey'])
					out_line += "[color=blue]" + effect_def.get("Details", {}).get("DisplayName", "???") + "[/color]"
				if sub_tokens[2] == 'Description':
					var effect_def = EffectLibrary.get_effect_def(effect_data['EffectKey'])
					var sub_lines = _build_bbcode_array(effect_def, null, actor)
					var display_name = effect_def.get("Details", {}).get("DisplayName", "???")
					out_line += "[color=blue]" + display_name + ". [/color]"
					out_arr.append(out_line)
					out_line = ''
					for line in sub_lines:
						out_arr.append(line)
			'#StatMod':
				var mod_data = {}
				if object_def.has("StatMods"):
					mod_data = object_def.get("StatMods",{}).get(sub_tokens[1],{})
				elif object_def.has("PageDetails"):
					mod_data = object_def.get("PageDetails").get("StatMods",{}).get(sub_tokens[1],{})
				if sub_tokens.size() == 2: # Give whole desription
					var stat_name = mod_data['StatName']
					var value = mod_data['Value']
					var abrev = StatHelper.get_stat_abbr(stat_name)
					var icon = StatHelper.get_stat_icon(stat_name)
					var str_val = str(value)
					if mod_data.get("ModType", "") == "Add" and value > 0:
						str_val = "+" + str_val
					if mod_data.get("ModType", "") == "Scale":
						str_val = "x" + str_val
					out_line += "[color=#460000]" + str_val
					if icon: 
						out_line += "[/color]"
						out_arr.append(out_line)
						out_arr.append(icon)
						out_line = "[color=#460000]"
					else:
						out_line += " "
					out_line += abrev + "[/color]"
					
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
					
	if out_line != '':
		out_arr.append(out_line)
	return out_arr
