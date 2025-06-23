class_name PageItemTitle
extends BasePageItem

#var title_data:Dictionary:
	#get:
		#return _def.get("TitleData", {})

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)


func get_rarity_background()->Texture2D:
	return ItemHelper.get_rarity_background(BaseItem.ItemRarity.Unique, false)

func get_item_tags()->Array:
	var tags = []
	tags = super()
	if not tags.has("Title"):
		tags.append("Title")
	return tags

func get_title_key()->String:
	return page_data.get("SourceTitle", "")
