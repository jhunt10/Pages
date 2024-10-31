class_name TargetingHelper

enum LOS_VALUE {Blocked, Cover, Open}

static func get_target_params(key:String, actor:BaseActor, action:BaseAction)->TargetParameters:
	#if key == "Weapon":
		#var weapon = actor.equipment.get_item_in_slot(BaseEquipmentItem.EquipmentSlots.Weapon)
		#if !weapon:
			#return null
		#return (weapon as BaseWeaponEquipment).target_parmas
	return action.get_targeting_params(key)

static func trace_los(from_point, to_point, _map_state):
	var los_dict = {}
	var line = safe_calc_line(from_point, to_point,  false, false, true)
	for point in line:
		los_dict[point] = LOS_VALUE.Open
	return los_dict

static func get_line_of_sight_for_spots(from_point, to_point, map:MapStateData, check_cache:Dictionary = {}, log=false)->LOS_VALUE:
	var in_line_is_unbroken = true
	var out_line_is_unbroken = true
	if log: print("#### LOS CHECK")
	if log: print("# From: %s | To: %s" % [from_point, to_point])
		
	var path = safe_calc_line(from_point, to_point, false, true, false)
	if log: print("# Path: %s" % [path])
	for p in path:
		if in_line_is_unbroken and _spot_blocks_los(p, check_cache, map):
			in_line_is_unbroken = false
	
	path = safe_calc_line(from_point, to_point, true, false, true)
	if log: print("# Path: %s" % [path])
	for p in path:
		if out_line_is_unbroken and _spot_blocks_los(p, check_cache, map):
			out_line_is_unbroken = false
	
	if in_line_is_unbroken:
		check_cache[to_point] = LOS_VALUE.Open
	elif out_line_is_unbroken:
		check_cache[to_point] = LOS_VALUE.Cover
	else:
		check_cache[to_point] = LOS_VALUE.Blocked
	#if log: print("# OutLine %s: %s" % [p, out_line_is_unbroken])
	return check_cache[to_point]

static func _spot_blocks_los(spot:Vector2i, check_cache:Dictionary, map:MapStateData):
	return map.spot_blocks_los(MapPos.Vector2i(spot))
	
# Calculate path as if m is positive and < 1. Then rotate and mirror as needed
# Rounding down will give a more generious results "leaning out" on corners
static func safe_calc_line(start, end, round_down=false, fill_back:bool=false, fill_down:bool=false)->Array:
	var out_line = []
	
	# Vertical line case (m = inf)
	if start.x == end.x:
		for y in range(min(start.y, end.y), max(start.y, end.y) + 1):
			var check_vec = Vector2i(start.x, y)
			out_line.append(check_vec)
		return out_line
	
	var x_change = abs(start.x - end.x)
	var y_change = abs(start.y - end.y)
	
	var min_point = Vector2i(0, 0)
	var max_point = Vector2i(max(x_change, y_change), min(x_change, y_change))
	
	# Is line being mirrored over Y Axis
	var is_x_mirrored = start.x > end.x
	# Is line being mirrored over Y Axis
	var is_y_mirrored = start.y > end.y
	# Is line being flipped over itself
	var is_inverted = x_change < y_change
	if is_inverted:
		is_y_mirrored = start.x > end.x
		is_x_mirrored = start.y > end.y
		#var temp_fill = fill_back
		#fill_back = fill_down
		#fill_down = temp_fill
		
	
	var check_line = []
	var last_x = min_point.x
	var last_y = min_point.y
	var m:float = float(max_point.y - min_point.y) / float(max_point.x - min_point.x)
	for check_x in range(min_point.x, max_point.x+1):
		var check_y = 0
		if round_down: check_y = floori(m * float(check_x))
		else: check_y = round(m * float(check_x))
		if check_y != last_y:
			if fill_back:
				check_line.append(Vector2i(check_x-1, check_y))
			if fill_down:
				check_line.append(Vector2i(check_x, check_y-1))
		check_line.append(Vector2i(check_x, check_y))
		last_y = check_y
		
	for check_point in check_line:
		var base_x = start.x
		var base_y = start.y
		if is_inverted:
			base_x = start.y
			base_y = start.x
		var res_x = 0
		var res_y = 0
		if is_x_mirrored: 
			res_x = base_x - check_point.x
		else: 
			res_x = base_x + check_point.x
		if is_y_mirrored: 
			res_y = base_y - check_point.y
		else: 
			res_y = base_y + check_point.y
		if is_inverted:
			out_line.append(Vector2i(res_y, res_x))
		else:
			out_line.append(Vector2i(res_x, res_y))
	#print("Inverted: %s | Xmirror: %s | YMirror: %s" % [is_inverted, is_y_mirrored, is_x_mirrored])
	
	return out_line
	
static func round(val:float)->int:
	var floor:int = floori(val)
	if val - float(floor) > 0.5:
		return floor + 1
	return floor
