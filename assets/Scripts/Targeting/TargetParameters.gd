class_name TargetParameters

enum TargetTypes {Self, Actor, Spot}

var target_key:String
var target_type:TargetTypes
var line_of_sight:bool
var target_area:AreaMatrix
var effect_area:AreaMatrix

func _init(args:Dictionary) -> void:
	
	# Assign Target Key
	target_key = args['TargetKey']
	
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
	
func is_valid_target(actor:BaseActor):
	return true
