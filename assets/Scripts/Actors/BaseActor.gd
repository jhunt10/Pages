class_name BaseActor
extends BaseLoadObject

# Actor holds no references to the current map state so this method is called by MapState.set_actor_pos()
signal on_move(old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by:BaseActor)
signal on_death()

var Que:ActionQue
var node:ActorNode
var stats:StatHolder
var effects:EffectHolder
var items:BaseItemBag
var details:ObjectDetailsData
var equipment:EquipmentHolder

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

var _default_sprite:String
var _allow_auto_que:bool = false

var is_dead:bool = false

func _init(key:String, load_path:String, def:Dictionary, id:String, data:Dictionary) -> void:
	super(key, load_path, def, id, data)
	spawn_map_layer = _def.get('SpawnOnMapLayer', MapStateData.DEFAULT_ACTOR_LAYER)
	
	_default_sprite = _def['Sprite']
	_allow_auto_que = _def.get('AutoQueing', false)
	
	Que = ActionQue.new(self)
	
	var stat_data = _def["Stats"]
	stats = StatHolder.new(self, stat_data)
	effects = EffectHolder.new(self)
	#items = BaseItemBag.new(self)
	details = ObjectDetailsData.new(_def_load_path, _def.get("Details", {}))
	equipment = EquipmentHolder.new(self)

func save_data()->Dictionary:
	var data = super()
	data['EquiptItems'] = equipment.save_data()
	return data

func die():
	is_dead = true
	on_death.emit()
	node.sprite.texture = get_coprse_texture()
	
func  get_default_sprite()->Texture2D:
	return load(_def_load_path + "/" +_default_sprite)
	
func get_portrait_sprite()->Texture2D:
	return load(_def_load_path + "/" +_default_sprite)

func get_coprse_texture()->Texture2D:
	if _def.has("CorpseSprite"):
		return load(LoadPath + "/" +_def['CorpseSprite'])
	return SpriteCache._get_no_sprite()

func auto_build_que(current_turn:int):
	if !_allow_auto_que:
		return
	printerr("Auto Que for : " + ActorKey)
	#if Que:
		#if Que.available_action_list.size() > 0:
			#var action = ActionLibrary.get_action(Que.available_action_list[0])
			#for n in range(Que.que_size):
				#print("AutoQue: " + action.ActionKey)
				#Que.que_action(action)
			
func get_action_list()->Array:
	var que_data = get_que_data()
	return que_data.get("ActionList", [])

func get_que_data()->Dictionary:
	if !_data.keys().has('QueData'):
		_data['QueData'] = _def['QueData']
	return _data['QueData']
