class_name OnQueOptionsData

var option_key:String
var title_text:String
var options_arr:Array

func _init(key, title, options) -> void:
	self.option_key = key
	self.title_text = title
	self.options_arr = options
