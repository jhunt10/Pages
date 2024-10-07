class_name TargetParameters

enum TargetTypes {Self, Spot, OpenSpot, Actor, Ally, Enemy}

static func is_spot_target(parms:TargetParameters)->bool:
	return (parms.target_type == TargetTypes.Spot or 
			parms.target_type == TargetTypes.OpenSpot)
			
static func is_actor_target(parms:TargetParameters)->bool:
	return (parms.target_type == TargetTypes.Actor or 
			parms.target_type == TargetTypes.Ally or 
			parms.target_type == TargetTypes.Enemy)

var target_key:String
var target_type:TargetTypes
var line_of_sight:bool
var target_area:AreaMatrix
var effect_area:AreaMatrix

func _init(target_key:String, args:Dictionary) -> void:
	# Assign Target Key
	self.target_key = target_key
	
	# Get Target Type
	if args['TargetType'] is int:
		target_type = args['TargetType']
	elif args['TargetType'] is String:
		var temp_type = TargetTypes.get(args['TargetType'])
		if temp_type:
			target_type = temp_type
		else: 
			printerr("Unknown Target Type: " + args['TargetType'])
		
	# Requires Line of Sight
	line_of_sight = args.get('LineOfSight', true)
	
	# Get Targeting Area
	if args.has('TargetAreaKey'):
		#TODO
		target_area = AreaMatrix.new([[0,0]])
	else:
		target_area = AreaMatrix.new(args['TargetArea'])
	
	if args.has('EffectArea'):
		effect_area = AreaMatrix.new(args['EffectArea'])
		
func is_point_in_area(center:MapPos, point:Vector2i)->bool:
	return target_area.to_map_spots(center).has(point)
	
func is_valid_target(actor:BaseActor, target:BaseActor):
	if target_type == TargetTypes.Enemy:
		return actor.FactionIndex != target.FactionIndex
	if target_type == TargetTypes.Ally:
		return actor.FactionIndex == target.FactionIndex
	return true
	
func get_valid_target_area(center:MapPos, line_of_sight:bool)->Array:
	var spots =  target_area.to_map_spots(center)
	if not line_of_sight:
		return spots
	var los_dict = {}
	for check in spots:
		get_line_of_sight_for_spots(center, check, CombatRootControl.Instance.GameState.MapState, los_dict)
	var valid_list = []
	for vec in los_dict.keys():
		if los_dict[vec]:
			valid_list.append(vec)
	return valid_list

static func get_line_of_sight_for_spots(from_point, to_point, map:MapStateData, check_cache:Dictionary = {}):
	var m:float = float(to_point.y - from_point.y) / float(to_point.x - from_point.x)
	var b:int = from_point.y - int(m * float(from_point.x)) 
	# to save on checking, we'll check the whole line and return what is/isn't valid
	# when checking area, we can use the previous cached results
	var line_is_unbroken = true
	
	# Vertical line case (m = inf)
	if from_point.x == to_point.x:
		var step = 1
		if from_point.y > to_point.y:
			step = -1
		for y in range(from_point.y, to_point.y + step, step):
			var check_vec = Vector2i(from_point.x, y)
			if line_is_unbroken and _spot_blocks_los(check_vec, check_cache, map):
				line_is_unbroken = false
			check_cache[check_vec] = line_is_unbroken
		return line_is_unbroken
	
	# Get y that will start counting from
	var last_y = from_point.y
	var step_x = 1
	if from_point.x > to_point.x: step_x = -1
	for check_x in range(from_point.x, to_point.x+step_x, step_x):
		var check_y = 0
		if m >= 0: 
			check_y = floori(m * float(check_x)) + b
		if m < 0: 
			check_y = ceili(m * float(check_x)) + b
		
		# If skipped a bunch of ys, back fill
		if abs(last_y - check_y) > 1:
			var step = 1
			if last_y > check_y: step = -1
			for back_y in range(last_y + step, check_y, step):
				var check_vec = Vector2i(check_x - step_x, back_y)
				if line_is_unbroken and _spot_blocks_los(check_vec, check_cache, map):
					line_is_unbroken = false
				check_cache[check_vec] = line_is_unbroken
				
		var check_vec = Vector2i(check_x, check_y)
		if line_is_unbroken and _spot_blocks_los(check_vec, check_cache, map):
			line_is_unbroken = false
		check_cache[check_vec] = line_is_unbroken
		last_y = check_y
	return line_is_unbroken

static func _spot_blocks_los(spot:Vector2i, check_cache:Dictionary, map:MapStateData):
	#if check_cache.keys().has(spot):
		#return check_cache[spot]
	return map.spot_blocks_los(MapPos.Vector2i(spot))
