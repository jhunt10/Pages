class_name  ObjectDetailsData

var display_name:String
var snippet:String
var description:String
var large_icon_path:String
var small_icon_path:String
var tags:Array

func _init(load_path:String, data:Dictionary) -> void:
	display_name = data.get("DisplayName", "No Display Name!")
	snippet = data.get("SnippetDesc", "No Snippet Desc!")
	description = data.get("Description", "No Description!")
	var large_icon_file = data.get("LargeIcon", "")
	if large_icon_file != "" and load_path != "":
		self.large_icon_path = load_path.path_join(large_icon_file)
		
	var small_icon_file = data.get("SmallIcon", "")
	if small_icon_file != "" and load_path != "":
		self.small_icon_path = load_path.path_join(small_icon_file)
	
	tags = data.get("Tags", [])
