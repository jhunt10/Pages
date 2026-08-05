class_name ActionQueHolder

signal action_que_changed

var Id : String :
	get: return actor.Id

var actor:BaseActor
var _current_que:ActionQueData
## List corisponding to turns, 1 when Action, 0 when Gap
var _turn_padding:Array

func _init(act) -> void:
	if act.Que:
		printerr("Actor already has que")
		return
	actor = act
	actor.Que = self
	_current_que = ActionQueData.new(self, [true])

func fail_turn():
	var turn_data = get_current_turn_data()
	if !turn_data:
		return
	if turn_data.turn_failed:
		return
	turn_data.turn_failed = true
	actor.action_failed.emit()

func get_max_que_size()->int:
	var que_size = actor.stats.get_stat("PPR", -1)
	return que_size

func list_qued_actions():
	return _current_que.list_qued_actions()

func is_turn_gap(turn_index:int)->bool:
	var max_size = _current_que._max_que_size
	if max_size == 0:
		return true
	return _current_que.is_turn_gap(turn_index)

func is_ready()->bool:
	return _current_que.is_ready()

func get_action_for_turn(turn_index : int)->PageItemAction:
	return _current_que.get_action_for_turn(turn_index)

func get_last_qued_action()->PageItemAction:
	return _current_que.get_last_qued_action()

func que_action(action:PageItemAction, data:Dictionary={}):
	if action == null:
		return
	if _current_que.que_action(action, data):
		action_que_changed.emit()
		action.ammo_changed.emit()

func count_qued_page_uses(page:PageItemAction)->int:
	var qued_page_ids = _current_que.list_qued_action_ids()
	return qued_page_ids.count(page.Id)

func clear_que(supress_signals:bool=false):
	_current_que = ActionQueData.new(self, _turn_padding)
	if not supress_signals:
		action_que_changed.emit()

func delete_at_index(index):
	_current_que.delete_at_index(index)
	action_que_changed.emit()

func get_data_for_turn(turn_index:int)->TurnExecutionData:
	return _current_que.get_data_for_turn(turn_index)

func get_current_turn_data()->TurnExecutionData:
	return _current_que.get_current_turn_data()

func get_on_qued_prop_values(prop_key:String)->Array:
	var out_list = []
	for turn_index in range(_turn_padding.size()):
		var turn_data = _current_que.get_data_for_turn(turn_index)
		if turn_data and turn_data.on_que_data.keys().has(prop_key):
			out_list.append(turn_data.on_que_data[prop_key])
	return out_list

# Get the end position if all qued movement actions were resolved
func get_movement_preview_pos()->MapPos:
	var path = get_movement_preview_path()
	if path.size() > 0:
		return path[-1]
	return null

func get_movement_preview_path()->Array:
	var current_pos = CombatRootControl.Instance.GameState.get_actor_pos(actor)
	if !current_pos:
		return []
	var path = [current_pos]
	for action_id in _current_que.list_qued_action_ids():
		var action:PageItemAction = actor.get_action_page(action_id)
		if action and action.has_preview_move_offset():
			var next_pos = MoveHandler.relative_pos_to_real(current_pos, action.get_preview_move_offset())
			# Position not changeing (turning)
			if current_pos.x == next_pos.x and current_pos.y == next_pos.y:
				current_pos = next_pos
				path.append(current_pos)
			# Check if spot is open
			elif MoveHandler.is_spot_traversable(CombatRootControl.Instance.GameState, next_pos, actor):
				current_pos = next_pos
				path.append(current_pos)
			#print("Before: " + str(befor) + " | Prev: " + str(action.get_preview_move_offset() + " | After: " + str(current_pos))
	return path

# Called by ActionQurControl._pad_ques()
func _set_turn_padding(gap_or_nots:Array):
	var is_match = true
	if not _turn_padding or _turn_padding.size() != gap_or_nots.size():
		is_match = false
	if is_match:
		for index in range(_turn_padding.size()):
			if _turn_padding[index] != gap_or_nots[index]:
				is_match = false
				break
	if is_match:
		return
	_turn_padding = gap_or_nots
	var new_que = ActionQueData.new(self, gap_or_nots)
	new_que.copy_from_que(_current_que)
	_current_que = new_que
	action_que_changed.emit()
