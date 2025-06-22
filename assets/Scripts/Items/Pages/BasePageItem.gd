class_name BasePageItem
extends BaseEquipmentItem

var page_data:Dictionary:
	get:
		return get_load_val("PageData", {})

func get_item_type()->ItemTypes:
	return ItemTypes.Page

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)

func get_item_tags()->Array:
	var tags = []
	tags = super()
	if not tags.has("Page"):
		tags.append("Page")
	return tags

## Returns a diction of failed requirements, mapped by requirment type 
func get_cant_use_reasons(actor:BaseActor):
	var requirment_data = get_load_val("Requirments", {})
	var missing_requirements = super(actor)
	
	for tag in requirment_data.get("ReqTags", []):
		if not actor.get_tags().has(tag):
			if not missing_requirements.has("Tags"):
				missing_requirements['Tags'] = []
			missing_requirements['Tags'].append(tag)
	
