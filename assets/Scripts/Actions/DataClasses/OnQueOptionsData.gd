class_name OnQueOptionsData

var option_key:String
var title_text:String
var options_datas:Array
var option_texts:Array
var options_vals:Array
var option_icons:Array
var disable_options:Array

func _init(set_key:String, title) -> void:
	self.option_key = set_key
	self.title_text = title

func append_option(value, text:String='', icon:Texture2D=null, disabled:bool=false):
	var data = {
		"Value": value,
		"Text": value,
		"Disabled": disabled
	}
	if text and text != '':
		data["Text"] = text
	if icon:
		data["Icon"] = icon
	options_datas.append(data)
	pass

func append_divider(text):
	options_datas.append({
		"DividerText": text
	})
