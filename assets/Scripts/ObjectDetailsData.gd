class_name  ObjectDetailsData

const NO_ICON_SPRITE = "res://assets/Sprites/BadSprite.png"

var display_name:String
var snippet:String
var description:String
var large_icon_path:String
var small_icon_path:String
var tags:Array

func _init(load_path:String, data:Dictionary) -> void:
	display_name = data.get("DisplayName", "")
	snippet = data.get("SnippetDesc", "")
	description = data.get("Description", "")
	var large_icon_file = data.get("LargeIcon", "")
	if large_icon_file != "" and load_path != "":
		self.large_icon_path = load_path.path_join(large_icon_file)
	else:
		self.large_icon_path = NO_ICON_SPRITE
		
	var small_icon_file = data.get("SmallIcon", "")
	if small_icon_file != "" and load_path != "":
		self.small_icon_path = load_path.path_join(small_icon_file)
	else:
		self.small_icon_path = NO_ICON_SPRITE
	
	tags = data.get("Tags", [])
