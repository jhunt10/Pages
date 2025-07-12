class_name ItemMissile
extends BaseMissile


var _item_id:String
var _target_pos:MapPos

func _init(source_actor:BaseActor, missile_data:Dictionary, source_tag_chain:SourceTagChain, 
			start_pos:MapPos, target_pos:MapPos, load_path:String) -> void:
	missile_data['UseLobPath'] = true
	super(source_actor, missile_data, source_tag_chain, start_pos, target_pos, load_path)
	_item_id = missile_data.get("ThrownItemId", '')
	_target_pos = target_pos

func get_missile_vfx_data()->Dictionary:
	var thrown_item = ItemLibrary.get_item(_item_id)
	var sprite_path = thrown_item.get_small_icon_path()
	var vfx_key = "ThrownItemMissileVFX"
	var vfx_data = {
		"AnimationSpeed": 1,
		"RandomOffsets": [0,0],
		"RandomRotation": [0,0],
		"Scale": [1, 1],
		"ScenePath": "res://assets/Scripts/VFXs/MissileVfx/item_missile_vfx_node.tscn",
		"SpriteName": sprite_path.get_file(),
		"SpriteSheetHight": 1,
		"SpriteSheetWidth": 1
	}
	if _missle_data.has("MissileVfxData"):
		vfx_data = BaseLoadObjectLibrary._merge_defs(_missle_data['MissileVfxData'], vfx_data)
	var data = VfxLibrary.get_vfx_def(vfx_key, vfx_data, null, sprite_path.get_base_dir())
	return data


func _do_missile_thing(game_state:GameStateData):
	var source_actor = get_source_actor()
	var thrown_item = ItemLibrary.get_item(_item_id)
	if thrown_item is BaseSupplyItem:
		thrown_item.use_in_combat(source_actor, _target_pos, game_state)
	
	pass
