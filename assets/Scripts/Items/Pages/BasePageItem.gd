class_name BasePageItem
extends BaseItem


func get_item_type()->ItemTypes:
	return ItemTypes.Equipment

func get_item_tags()->Array:
	var tags = super()
	if !tags.has("Page"):
		tags.append("Page")
	return tags

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	var details_data = def.get("Details", {})
	var action_key = def.get("ActionKey")
	if action_key:
		var action_def = ActionLibrary.get_action_def(action_key)
		details_data = BaseLoadObjectLibrary._merge_defs(details_data, action_def.get("Details", {}))
		details = ObjectDetailsData.new(ActionLibrary.Instance._defs_to_load_paths[action_key], details_data)

func get_action()->BaseAction:
	var action_key = get_load_val("ActionKey")
	if action_key:
		return ActionLibrary.get_action(action_key)
	return null

func get_effect()->BaseEffect:
	return null