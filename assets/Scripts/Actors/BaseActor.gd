class_name BaseActor
extends BaseLoadObject

# These signals are emited by ActionQueController
## Emitted only when this Actor starts a turn (not emitted on gap turns)
signal turn_starting
## Emitted only when this Actor ends a turn (not emitted on gap turns)
signal turn_ended
# This is just here because I don't want all the Holders to have to connect dirrectly to ActionQueController
signal round_starting
signal round_ended

signal equipment_changed
signal bag_items_changed
signal page_list_changed
signal action_que_changed

# Actor holds no references to the current map state so this method is called by MapState.set_actor_pos()
signal on_move(old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by:BaseActor)
signal on_death()
signal sprite_changed()

var Que:ActionQue
var node:ActorNode
var sprite:ActorSprite
var stats:StatHolder
var effects:EffectHolder
var items:ItemHolder
var equipment:EquipmentHolder
var pages:PageHolder

var Id : String:
	get: return _id
var ActorKey : String:
	get: return _key
func get_tagable_id(): return Id
func get_tags(): return Tags

var FactionIndex : int

var LoadPath:String:
	get: return _def_load_path
var DisplayName:String:
	get: return _data.get("DisplayName", details.display_name)
	set(val): _data["DisplayName"] = val
var SnippetDesc:String:
	get: return details.snippet
var Description:String:
	get: return details.description
var Tags:Array = []

var spawn_map_layer

var _allow_auto_que:bool = false

var is_player:bool = false
var is_dead:bool = false

func _init(key:String, load_path:String, def:Dictionary, id:String, data:Dictionary) -> void:
	super(key, load_path, def, id, data)
	spawn_map_layer = _def.get('SpawnOnMapLayer', MapStateData.DEFAULT_ACTOR_LAYER)
	
	var auto_que_list = _def.get("AutoQue", [])
	_allow_auto_que = auto_que_list.size() > 0
	
	var stat_data = _def["Stats"]
	
	sprite = ActorSprite.new(self)
	stats = StatHolder.new(self, stat_data)
	effects = EffectHolder.new(self)
	details = ObjectDetailsData.new(_def_load_path, _def.get("Details", {}))
	equipment = EquipmentHolder.new(self)
	items = ItemHolder.new(self)
	Que = ActionQue.new(self)
	pages = PageHolder.new(self)
	if get_load_val("IsPlayer", false):
		is_player = true

func save_me()->bool:
	return self.is_player

func save_data()->Dictionary:
	var data = super()
	data['Pages'] = pages.get_pages_per_page_tags()
	data['BagItems'] = items.get_items_per_item_tags()
	return data

func on_combat_start():
	effects.on_combat_start()

func set_pos(old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by:BaseActor):
	on_move.emit(old_pos, new_pos, move_type, moved_by)
	node.set_display_pos(new_pos)

func on_turn_failed():
	node.cancel_current_animation()

func die():
	is_dead = true
	on_death.emit()
	#node.set_corpse_sprite()
	node.queue_death()
	
func auto_build_que(current_turn:int):
	if !_allow_auto_que:
		return
	var auto_que_list = get_load_val("AutoQue", null)
	if Que:
		for action_key in auto_que_list:
			var action = ActionLibrary.get_action(action_key)
			print("AutoQue: " + action.ActionKey)
			if action:
				Que.que_action(action)
			
func get_action_list()->Array:
	return pages.list_action_keys()
