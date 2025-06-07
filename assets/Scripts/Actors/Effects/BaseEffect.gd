class_name BaseEffect
extends BaseLoadObject
# An "Effect" is any Buff, Debuff, or modifier on an actor. 

signal effect_ended

enum EffectTriggers { 
	None,
	OnCreate, OnDurationEnds,
	OnCombatStart, OnCombatEnd,
	OnTurnStart, OnTurnEnd, 
	OnActionStart, OnActionEnd, 
	OnGapTurnStart, OnGapTurnEnd,
	OnRoundStart, OnRoundEnd,
	PreMove, PostMove, OnCollision,
	OnDamageTaken, OnDamagDealt,
	OnAttacking_PreAttackRoll, OnAttacking_PostAttackRoll, OnAttacking_PostEffectRoll, OnAttacking_PostDamageRoll, OnAttacking_AfterAttack,
	OnDefending_PreAttackRoll, OnDefending_PostAttackRoll, OnDefending_PostEffectRoll, OnDefending_PostDamageRoll, OnDefending_AfterAttack,
	OnDeath, OnKill,
	OnUseItem,
	OnOtherEffectToBeAdded, # When a different effect is added
}

## Triggers which require additional information. They have thier own methods and can not be called from trigger_effect()
const TRIGGERS_WITH_ADDITIONAL_DATA = [
	EffectTriggers.PreMove, 
	EffectTriggers.PostMove, 
	EffectTriggers.OnCollision,
	EffectTriggers.OnDamageTaken, 
	EffectTriggers.OnKill,
	EffectTriggers.OnAttacking_PreAttackRoll, EffectTriggers.OnAttacking_PostAttackRoll,
	EffectTriggers.OnAttacking_PostDamageRoll, EffectTriggers.OnAttacking_PostEffectRoll, EffectTriggers.OnAttacking_AfterAttack,
	EffectTriggers.OnDefending_PreAttackRoll, EffectTriggers.OnDefending_PostAttackRoll,
	EffectTriggers.OnDefending_PostDamageRoll, EffectTriggers.OnDefending_PostEffectRoll, EffectTriggers.OnDefending_AfterAttack,
]

func get_tagable_id(): return Id
func get_tags(): return details.tags


var Id:String:
	get: return self._id
var EffectKey:String:
	get: return self._key

var effect_details:Dictionary:
	get: return get_load_val("EffectDetails", {})

# Triggers added by the system an not config, like OnTurnEnds for TurnDuration
var system_triggers:Array = []

var _icon_sprite:String

var Triggers:Array:
	get: return _triggers_to_sub_effect_keys.keys()
var DamageDatas:Dictionary:
	get: return get_load_val("DamageDatas", {})
var ZoneDatas:Dictionary:
	get: return get_load_val("ZoneDatas", {})
var StatModDatas:Dictionary:
	get: return get_load_val("StatMods", {})
var DamageModDatas:Dictionary:
	get: return get_load_val("DamageMods", {})


var _inital_duration:int = 0
var _max_duration:int = -1
# Ignore, Reset, Replace, Add
var _duration_merge_type = "Replace"
var _duration_counter:int = -1
var duration_trigger:EffectTriggers = EffectTriggers.None
var DurationData:Dictionary:
	get:
		var dets = get_load_val("EffectDetails", {}) 
		return dets.get("DurationData", {})
var RemainingDuration:int:
	get: return _duration_counter

var source_id:String:
	get: return get_load_val("SourceId")

var applied_potency:float:
	get:
		if applied_potency < 1:
			var pot = get_load_val("AppliedPotency", 1)
			applied_potency = pot
		return applied_potency

var _source
var _enabled:bool = true
var _deleted:bool = false
var _sub_effects_data:Dictionary={}
var _triggers_to_sub_effect_keys:Dictionary={}

# TODO: Merge with SubEffectData?
var _cached_data:Dictionary = {}

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	_sub_effects_data = get_load_val('SubEffects')
	var duration_data = DurationData
	if duration_data.size() > 0:
		_duration_merge_type = duration_data.get("MergeType", "Replace")
		var duration_trigger_str = DurationData.get("DurationTrigger", "")
		if BaseEffect.EffectTriggers.keys().has(duration_trigger_str):
			_inital_duration = duration_data.get("BaseDuration", 0)
			_max_duration = duration_data.get("MaxDuration", -1)
			if _max_duration > 0:
				_inital_duration = min(_inital_duration, _max_duration)
			_duration_counter = _inital_duration
			duration_trigger = EffectTriggers.get(duration_trigger_str)
		else:
			printerr("BaseEffect._init: No DurationTrigger found on '%s'." %[key])
	_cache_triggers()

func merge_duplicate_effect(source, dup_effect_def:Dictionary):
	var dup_details = dup_effect_def.get("EffectDetails", {})
	var dup_duration_data = dup_details.get("DurationData", {})
	if dup_duration_data.size() > 0:
		var dup_trigger_str = dup_duration_data.get("DurationTrigger", "")
		var dup_trigger = EffectTriggers.get(dup_trigger_str)
		var dup_max_duration = dup_duration_data.get("MaxDuration", -1)
		var dup_duration = dup_duration_data.get("BaseDuration", -1)
		var dup_merge_type = dup_duration_data.get("MergeType", "Add")
		
		if dup_trigger != duration_trigger:
			printerr("%s.merge_duplicate_effect_data: Mismatched DurationTrigger: %s / %s" % [self.EffectKey, EffectTriggers.keys()[duration_trigger], dup_trigger_str])
		else:
			if _duration_merge_type == "Ignore":
				var t = true
			elif _duration_merge_type == "Reset":
				if dup_duration != self._inital_duration:
					print("%s.merge_duplicate_effect_data: Mismatched BaseDuratio on Reset merge: %s / %s" % [self.EffectKey, self._inital_duration, dup_duration])
				self._duration_counter = self._inital_duration
			elif _duration_merge_type == "Replace":
				self._max_duration = dup_max_duration
				self._inital_duration = dup_duration
				if self._max_duration > 0:
					self._inital_duration = min(self._inital_duration, self._max_duration)
				self._duration_counter = self._inital_duration
			elif _duration_merge_type == "Add":
				if dup_max_duration < 0:
					self._max_duration = dup_max_duration
					self._inital_duration = self._inital_duration + dup_duration
					self._duration_counter = self._duration_counter + dup_duration
				else:
					self._max_duration = max(self._max_duration, dup_max_duration)
					self._inital_duration = min(self._inital_duration + dup_duration, self._max_duration)
					self._duration_counter = min(self._duration_counter + dup_duration, self._max_duration)
	
	# Merge Sub Effects
	var dup_subs_datas = dup_effect_def.get('SubEffects', {})
	for sub_effect_key in dup_subs_datas.keys():
		var dupl_sub_effect_data = dup_subs_datas[sub_effect_key]
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sup_sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if sub_effect:
			sub_effect.merge_new_duplicate_sub_effect_data(self, sub_effect_data, dup_effect_def, dupl_sub_effect_data)

func get_source_actor()->BaseActor:
	var source_actor_id = get_load_val('SourceActorId', '')
	if source_actor_id != "Actor":
		return ActorLibrary.get_actor(source_actor_id)
	return null

func is_bad()->bool:
	return effect_details.get("IsBad", false)
func is_good()->bool:
	return effect_details.get("IsGood", false)

func get_effected_actor()->BaseActor:
	var actor_id = get_load_val("EffectedActorId", null)
	if actor_id == null:
		printerr("Effect '%' found with no EffectedActor")
		return null
	return ActorLibrary.get_actor(actor_id)

func show_in_hud()->bool:
	return effect_details.get("ShowInHud", false)

func show_counter()->bool:
	return effect_details.get("ShowCounter", false)
## Will be deleted after combat
func delete_after_combat()->bool:
	return effect_details.get("DeleteAfterCombat", false)

func is_instant()->bool:
	return effect_details.get("IsInstant", false)

func get_small_icon():
	return SpriteCache.get_sprite(details.small_icon_path)
func get_large_icon():
	return SpriteCache.get_sprite(details.large_icon_path)

func get_tags_added_to_actor()->Array:
	return get_load_val("AddTagsToActor", [])

func get_effect_immunities():
	return effect_details.get("AddEffectImmunity", [])

func get_active_stat_mods()->Array:
	var out_list = []
	for sub_effect_key in _sub_effects_data.keys():
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if not sub_effect:
			continue
		for mod in sub_effect.get_active_stat_mods(self, sub_effect_data):
			out_list.append(mod)
	return out_list

func get_active_ammo_mods()->Dictionary:
	var out_dict = {}
	var mods_dataa = get_load_val("AmmoMods", {})
	for mod_key in mods_dataa.keys():
		var mod_data = mods_dataa[mod_key]
		if not mod_data.has("AmmoModKey"):
			mod_data["AmmoModKey"] = mod_key
		out_dict[mod_key] = mod_data
	return out_dict

func get_active_damage_mods()->Dictionary:
	var out_dict = {}
	for sub_effect_key in _sub_effects_data.keys():
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if not sub_effect:
			continue
		var mods = sub_effect.get_active_damage_mods(self, sub_effect_data)
		for mod_key in mods.keys():
			var mod_data = mods[mod_key]
			if mod_data.has("DamageModKey"):
				mod_key = mod_data['DamageModKey']
			else:
				mod_data['DamageModKey'] = mod_key
			out_dict[mod_key] = mod_data
	return out_dict

func get_active_attack_mods()->Dictionary:
	var out_dict = {}
	for sub_effect_key in _sub_effects_data.keys():
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if not sub_effect:
			continue
		var mods = sub_effect.get_active_attack_mods(self, sub_effect_data)
		for mod_key in mods.keys():
			var mod_data = mods[mod_key]
			if mod_data.has("AttackModKey"):
				mod_key = mod_data['AttackModKey']
			else:
				mod_data['AttackModKey'] = mod_key
			out_dict[mod_key] = mod_data
	return out_dict

func get_limited_effect_type()->EffectHelper.LimitedEffectTypes:
	var limited_effect_str = effect_details.get("LimitedEffectType", "None")
	var key_index = EffectHelper.LimitedEffectTypes.keys().find(limited_effect_str)
	if key_index >= 0:
		return key_index
	return EffectHelper.LimitedEffectTypes.None

func _get_sub_effect_script(sub_effect_key:String):
	if not _sub_effects_data.has(sub_effect_key):
		return null
	var script_path = _sub_effects_data[sub_effect_key].get('SubEffectScript')
	if !script_path:
		printerr("BaseEffect._get_sub_effect_script: No SubEffectScript found on SubEffect '%s' of Effect '%s'." % [sub_effect_key, self.Id])
		return null
	return EffectLibrary.get_sub_effect_script(script_path)

func _cache_triggers():
	_triggers_to_sub_effect_keys.clear()
	if is_instant():
		_triggers_to_sub_effect_keys[EffectTriggers.OnCreate] = []
		for sub_effect_key in _sub_effects_data.keys():
			_triggers_to_sub_effect_keys[EffectTriggers.OnCreate].append(sub_effect_key)
	else:
		for sub_effect_key in _sub_effects_data.keys():
			var sub_effect_data = _sub_effects_data[sub_effect_key]
			var sub_effect = _get_sub_effect_script(sub_effect_key)
			if not sub_effect:
				continue
			var trigger_list = sub_effect.get_triggers(self, sub_effect_data)
			for trig:EffectTriggers in trigger_list:
				if trig == EffectTriggers.None:
					continue
				if not _triggers_to_sub_effect_keys.keys().has(trig):
					_triggers_to_sub_effect_keys[trig] = []
				if not _triggers_to_sub_effect_keys[trig].has(sub_effect_key):
					_triggers_to_sub_effect_keys[trig].append(sub_effect_key)
	if duration_trigger != EffectTriggers.None:
		if !_triggers_to_sub_effect_keys.has(duration_trigger):
			_triggers_to_sub_effect_keys[duration_trigger] = []

func on_created(game_state:GameStateData=null):
	trigger_effect(EffectTriggers.OnCreate, game_state)
	pass

func on_delete():
	if _deleted:
		return
	for sub_effect_key in _sub_effects_data.keys():
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if sub_effect:
			sub_effect.on_delete(self, sub_effect_data)
	_deleted = true
	var actor = get_effected_actor()
	if actor and actor.effects.has_effect(self.Id):
		actor.effects.remove_effect(self)
	effect_ended.emit()

func trigger_effect(trigger:EffectTriggers, game_state:GameStateData):
	if TRIGGERS_WITH_ADDITIONAL_DATA.has(trigger):
		printerr("BaseEffect.trigger_effect: Called with trigger '%s' which requirers it's own method." % [trigger])
		return
	# Trigger each sub effect mapped to trigger
	for sub_effect_key in _triggers_to_sub_effect_keys.get(trigger, []):
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if sub_effect:
			sub_effect.on_effect_trigger(self, sub_effect_data, trigger, game_state)
	if trigger == duration_trigger and _duration_counter > 0:
		_duration_counter -= 1
	# Check if durration has ended and remove self if so
	#printerr("trigger_effect:Check Duration: %s" % _duration_counter)
	if _enabled and _duration_counter == 0 and trigger != EffectTriggers.OnDurationEnds:
		trigger_effect(EffectTriggers.OnDurationEnds, game_state)
		_enabled = false
		var actor = get_effected_actor()
		if actor:
			actor.effects.remove_effect(self)

func trigger_other_effect_to_be_added(game_state:GameStateData, other_effect:BaseEffect, meta_data:Dictionary):
	for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.OnOtherEffectToBeAdded, []):
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if sub_effect:
			sub_effect.other_effect_to_be_added(self, sub_effect_data, game_state, other_effect, meta_data)
	

func trigger_pre_move(game_state:GameStateData, old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by_actor:BaseActor):
	for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.PreMove, []):
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if sub_effect:
			sub_effect.before_move(self, sub_effect_data, game_state, old_pos, new_pos, move_type, moved_by_actor)
func trigger_post_move(game_state:GameStateData, old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by_actor:BaseActor):
	for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.PostMove, []):
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if sub_effect:
			sub_effect.after_move(self, sub_effect_data, game_state, old_pos, new_pos, move_type, moved_by_actor)
func trigger_collision(game_state:GameStateData, collision_event:CollisionEvent):
	for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.PostMove, []):
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if sub_effect:
			sub_effect.on_collision(self, sub_effect_data, collision_event, game_state)


func trigger_on_damage_taken(game_state:GameStateData, damage_event:DamageEvent):
	for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.OnDamageTaken, []):
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if sub_effect:
			sub_effect.on_damage_taken(self, sub_effect_data, game_state, damage_event)

func trigger_on_damage_dealt(game_state:GameStateData, damage_event:DamageEvent):
	for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.OnDamagDealt, []):
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if sub_effect:
			sub_effect.on_damage_dealt(self, sub_effect_data, game_state, damage_event)

func trigger_on_attack(attack_event:AttackEvent, game_state:GameStateData):
	var is_attacking = attack_event.attacker_id == get_load_val("EffectedActorId", null)
	var is_defending = attack_event.defender_ids.has(get_load_val("EffectedActorId", null))
	#
	#var attacking_trigger = null
	#var defending_trigger = null
	#if attack_event.attack_stage == AttackHandler.AttackStage.Created:
		#if is_attacking: attacking_trigger = EffectTriggers.OnAttacking_PreAttackRoll
		#if is_defending: defending_trigger = EffectTriggers.OnDefending_PreAttackRoll
	#elif attack_event.attack_stage == AttackHandler.AttackStage.RolledForHit:
		#if is_attacking: attacking_trigger = EffectTriggers.OnAttacking_PreEffectRoll
		#if is_defending: defending_trigger = EffectTriggers.OnDefending_PreEffectRoll
		#
	
	if attack_event.attack_stage == AttackHandler.AttackStage.Created:
		if is_attacking: _trigger_on_atk(EffectTriggers.OnAttacking_PreAttackRoll, attack_event, game_state)
		if is_defending: _trigger_on_atk(EffectTriggers.OnDefending_PreAttackRoll, attack_event, game_state)
	elif attack_event.attack_stage == AttackHandler.AttackStage.RolledForHit:
		if is_attacking: _trigger_on_atk(EffectTriggers.OnAttacking_PostAttackRoll, attack_event, game_state)
		if is_defending: _trigger_on_atk(EffectTriggers.OnDefending_PostAttackRoll, attack_event, game_state)
	elif attack_event.attack_stage == AttackHandler.AttackStage.RolledForDamage:
		if is_attacking: _trigger_on_atk(EffectTriggers.OnAttacking_PostDamageRoll, attack_event, game_state)
		if is_defending: _trigger_on_atk(EffectTriggers.OnDefending_PostDamageRoll, attack_event, game_state)
	elif attack_event.attack_stage == AttackHandler.AttackStage.RolledForEffects:
		if is_attacking: _trigger_on_atk(EffectTriggers.OnAttacking_PostEffectRoll, attack_event, game_state)
		if is_defending: _trigger_on_atk(EffectTriggers.OnDefending_PostEffectRoll, attack_event, game_state)
	elif attack_event.attack_stage == AttackHandler.AttackStage.Resolved:
		if is_attacking: _trigger_on_atk(EffectTriggers.OnAttacking_AfterAttack, attack_event, game_state)
		if is_defending: _trigger_on_atk(EffectTriggers.OnDefending_AfterAttack, attack_event, game_state)

## Helper function to cleanup trigger_on_attack 
func _trigger_on_atk(sub_trigger:EffectTriggers, attack_event:AttackEvent, game_state:GameStateData):
	for sub_effect_key in _triggers_to_sub_effect_keys.get(sub_trigger, []):
		var sub_effect_data = _sub_effects_data[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		if sub_effect:
			if sub_trigger == EffectTriggers.OnAttacking_PreAttackRoll:
				sub_effect.on_attacking_pre_attack_roll(self, sub_effect_data, game_state, attack_event)
			elif sub_trigger == EffectTriggers.OnAttacking_PostAttackRoll:
				sub_effect.on_attacking_post_attack_roll(self, sub_effect_data, game_state, attack_event)
			elif sub_trigger == EffectTriggers.OnAttacking_PostDamageRoll:
				sub_effect.on_attacking_post_damage_roll(self, sub_effect_data, game_state, attack_event)
			elif sub_trigger == EffectTriggers.OnAttacking_PostEffectRoll:
				sub_effect.on_attacking_post_effect_roll(self, sub_effect_data, game_state, attack_event)
			elif sub_trigger == EffectTriggers.OnAttacking_AfterAttack:
				sub_effect.on_attacking_after_attack(self, sub_effect_data, game_state, attack_event)
				
			elif sub_trigger == EffectTriggers.OnDefending_PreAttackRoll:
				sub_effect.on_defending_pre_attack_roll(self, sub_effect_data, game_state, attack_event)
			elif sub_trigger == EffectTriggers.OnDefending_PostAttackRoll:
				sub_effect.on_defending_post_attack_roll(self, sub_effect_data, game_state, attack_event)
			elif sub_trigger == EffectTriggers.OnDefending_PostDamageRoll:
				sub_effect.on_defending_post_damage_roll(self, sub_effect_data, game_state, attack_event)
			elif sub_trigger == EffectTriggers.OnDefending_PostEffectRoll:
				sub_effect.on_defending_post_effect_roll(self, sub_effect_data, game_state, attack_event)
			elif sub_trigger == EffectTriggers.OnDefending_AfterAttack:
				sub_effect.on_defending_after_attack(self, sub_effect_data, game_state, attack_event)

func get_damage_data(damage_data_key:String, actor:BaseActor=null)->Dictionary:
	if damage_data_key == "Weapon":
		if actor == null:
			printerr("BaseAction.get_damage_data: Null Actor when asking for Weapon damage.")
			return {}
		var weapon = actor.equipment.get_primary_weapon()
		if !weapon:
			printerr("BaseAction.get_damage_data: No Weapon when asking for Weapon damage.")
			return {}
		return weapon.get_damage_data()
	var damage_datas = get_load_val("DamageDatas", {})
	if damage_datas.has(damage_data_key):
		return damage_datas[damage_data_key].duplicate()
	return {}

func get_nested_effect_data(effect_data_key:String)->Dictionary:
	var effect_datas = get_load_val("NestedEffectDatas", {})
	if effect_datas.has(effect_data_key):
		return effect_datas[effect_data_key].duplicate()
	return {}

func get_zone_data(zone_data_key:String)->Dictionary:
	var zone_datas = get_load_val("ZoneDatas", {})
	if zone_datas.has(zone_data_key):
		return zone_datas[zone_data_key].duplicate()
	return {}

func has_aura_zone()->bool:
	return _cached_data.has("AuraZoneId")

func get_aura_zone(game_state:GameStateData)->BaseZone:
	var zone_id = _cached_data.get("AuraZoneId")
	if not zone_id:
		return null
	return game_state.get_zone(zone_id)
