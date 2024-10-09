class_name BaseEffect
# An "Effect" is any Buff, Debuff, or modifier on an actor. 

enum SubActionPropType {TargetKey, DamageData, SubTriggers, SubDuration, SubEffectKey, StringVal, IntVal}

enum EffectTriggers { 
	OnCreate, OnTurnStart, OnTurnEnd, 
	OnRoundStart, OnRoundEnd,
	OnDamageTaken, OnDamagDealt,
	OnCalcDamageTaken, OnCalcDamageDealt,
	OnMove, OnPushed, OnPushing,
	}

var Id : String = str(ResourceUID.create_id())
var LoadPath:String
var EffectData:Dictionary
var EffectKey:String 
var DisplayName:String
var SnippetDesc:String
var Description:String
var Tags:Array = []
var Triggers:Array = []
# Triggers added by the system an not config, like OnTurnEnds for TurnDuration
var system_triggers:Array = []

var _actor:BaseActor
var _icon_sprite:String

# Instant effects are triggered and dispoded of immediately
var is_instant:bool = false
var _turn_duration:int = -1
var _turn_timer:int = 0
var _round_duration:int = -1
var _round_timer:int = 0

func _init(actor:BaseActor, args:Dictionary) -> void:
	_actor = actor
	LoadPath = args['LoadPath']
	EffectKey = args['EffectKey']
	EffectData = args
	print("Init Effect: %s | %s" % [EffectKey, args['Triggers']])
	
	#TODO: Translations
	DisplayName = args['DisplayName']
	SnippetDesc = args['SnippetDesc']
	Description = args['Description']
	Tags = args['Tags']
	_icon_sprite = args['IconSprite']
	
	# Instand effects ignore all logic bellow
	if args['Triggers'] is String and args['Triggers'] == "Instant":
		is_instant = true
		return
	
	for t in args['Triggers']:
		var temp_type = EffectTriggers.get(t)
		if temp_type:
			Triggers.append(temp_type)
		else: 
			printerr("Unknown Effect Trigger: " + t)
			
	# Get Turn and round duration for effect
	# Start and End is handeled  by automatically by the _system funcs
	if args.has("TurnDuration"):
		# Subtract 1 since the turn it's being created on wasn't counted
		_turn_duration = args['TurnDuration'] - 1
		if !system_triggers.has(EffectTriggers.OnTurnStart):
			system_triggers.append(EffectTriggers.OnTurnStart)
		if !system_triggers.has(EffectTriggers.OnTurnEnd):
			system_triggers.append(EffectTriggers.OnTurnEnd)
	if args.has("RoundDuration"):
		# Subtract 1 since the round it's being created on wasn't counted
		_round_duration = args['RoundDuration'] - 1
		if !system_triggers.has(EffectTriggers.OnRoundStart):
			system_triggers.append(EffectTriggers.OnRoundStart)
		if !system_triggers.has(EffectTriggers.OnRoundEnd):
			system_triggers.append(EffectTriggers.OnRoundEnd)

func do_effect():
	pass

func _on_duration_end():
	pass

func _on_turn_start():
	pass

func _on_turn_end():
	pass

func _on_round_start():
	pass

func _on_round_end():
	pass

func _on_deal_damage(value:int, damage_type:String, target:BaseActor):
	pass

func _on_take_damage(value:int, damage_type:String, source):
	pass

func _on_move(_old_pos:MapPos, _new_pos:MapPos, _move_type:String, _moved_by:BaseActor):
	pass

func on_delete():
	pass

func get_sprite():
	return load(LoadPath + "/" +_icon_sprite)
	
# System triggers for controlling effects outside of thier config
func _system_on_turn_start():
	_turn_timer += 1
	pass

func _system_on_turn_end():
	if _turn_duration > 0 && _turn_timer >= _turn_duration:
		_on_duration_end()
		_actor.effects.remove_effect(self)
	pass

func _system_on_round_start():
	_round_timer += 1
	pass

func _system_on_round_end():
	if _round_duration > 0 && _round_timer >= _round_duration:
		_on_duration_end()
		_actor.effects.remove_effect(self)
	pass
