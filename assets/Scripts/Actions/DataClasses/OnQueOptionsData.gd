class_name OnQueOptionsData

var option_key:String
var title_text:String
var option_texts:Array
var options_vals:Array
var option_icons:Array

func _init(set_key:String, title, option_values:Array, option_labels:Array = [], icons:Array=[]) -> void:
	self.option_key = set_key
	self.title_text = title
	self.options_vals = option_values.duplicate()
	if option_labels:
		self.option_texts = option_labels.duplicate()
	else:
		self.option_texts = option_values.duplicate()
	self.option_icons = icons
