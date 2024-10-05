class_name ItemHolder

var _actor:BaseActor
var _max_slots:int = 0
var _slots:Array = []
var _items:Dictionary = {}

func _init(actor:BaseActor) -> void:
	_actor = actor
	if not actor.ActorData.keys().has("MaxItemSlots"):
		return
		
	_max_slots = actor.ActorData['MaxItemSlots']
	
	if _max_slots == 0:
		return
		
	for n in range(0, _max_slots):
		_slots.append(null)
	# TODO: Items shouldn't be static
	var index = 0
	for itemKey in actor.ActorData.get('Items', []):
		var item = MainRootNode.item_libary.create_new_item(itemKey, {})
		_slots[index] = item.Id
		_items[item.Id] = item
		index+=1

func get_item_in_slot(slot:int):
	if slot < 0 or slot >= _max_slots:
		return null
	if not _slots[slot]:
		return null
	return _items[_slots[slot]]

func get_item_by_id(item_id:String):
	if _items.keys().has(item_id):
		return _items[item_id]
	return null

func is_item_id_qued(item_id:String):
	for turn_data:TurnExecutionData in _actor.Que.QueExecData.TurnDataList:
		if turn_data.on_que_data.keys().has('ItemId'):
			if turn_data.on_que_data['ItemId'] == item_id:
				return true
	return false

func delete_item(item_id:String):
	if _items.keys().has(item_id):
		_items.erase(item_id)
	var slot_number = _slots.find(item_id)
	if slot_number >= 0:
		_slots[slot_number] = null
