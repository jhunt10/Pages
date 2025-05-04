@tool
class_name WaterJetVfxNode
extends Node2D

signal reached_tile(tile_index:int)

@export var test:bool

@export var head:Sprite2D
@export var lead_neck:Sprite2D
@export var premade_neck:Sprite2D
@export var neck_sprites:Node2D
@export var tail:Sprite2D
@export var frame:int:
	set(val):
		frame = val
		if Engine.is_editor_hint():
			_sync()
@export var animation_frame:int
@export var animation_player:AnimationPlayer
var _emited_for:Array = []
var _data:Dictionary = {}
var _vfx_holder:VfxHolder
var _target_params:TargetParameters
var _already_hit_actor_ids:Array=[]

func _ready() -> void:
	if animation_player:
		animation_player.speed_scale = 2

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if test:
			test = false
			frame += 1
			_sync()
	else:
		_sync()
	_sync_animations()

func _sync():
	var frames_per_tile = 3 #head.hframes * head.vframes
	var tiles_traveled = frame / frames_per_tile
	if not head:
		return
	var sprite_frame = frame % head.hframes * head.vframes
	
	head.frame = 0#sprite_frame
	head.position = Vector2(0, ((-32.0 / float(frames_per_tile))* float(frame) - 32))
	
	if lead_neck:
		var sub_tile = frame % frames_per_tile
		var lead_neck_hight = ((32.0) / float(frames_per_tile))
		lead_neck.region_rect.size.y = lead_neck_hight * sub_tile
		lead_neck.region_rect.position.y = 32 - (lead_neck_hight * sub_tile)
		#lead_neck.position = Vector2(0, (lead_neck_hight))
	
	var child_count = neck_sprites.get_child_count(true)
	for child_index in range(max(child_count, tiles_traveled)):
		if child_index > child_count-1:
			neck_sprites.add_child(premade_neck.duplicate())
		var child = neck_sprites.get_child(child_index)
		child.position = Vector2i(0, -32 * (child_index + 1))
		if child_index > tiles_traveled:
			child.queue_free()
		child.visible = child_index < tiles_traveled
		child.frame = sprite_frame
	
	#TODO: This is calling DamageHelper.handle_attack and altering GameState
	#	    outside of the main update thread (not good?)
	if frame % frames_per_tile == 0:
		if not _emited_for.has(tiles_traveled):
			do_thing(tiles_traveled)
			reached_tile.emit(tiles_traveled)
			_emited_for.append(tiles_traveled)
	if tiles_traveled >= 5:
		self.queue_free()

func _sync_animations():
	var max_frame = premade_neck.hframes * premade_neck.vframes
	var sprite_frame = animation_frame % max_frame
	head.frame = sprite_frame
	lead_neck.frame = sprite_frame
	tail.frame = sprite_frame
	for child in neck_sprites.get_children(true):
		if child is Sprite2D:
			child.frame = sprite_frame

func set_data(vfx_holder:VfxHolder, data:Dictionary, target_params:TargetParameters):
	_data = data
	_vfx_holder = vfx_holder
	_target_params = target_params
	
func on_frame_end():
	frame += 1
	_sync()

func do_thing(tiles_traveled:int):
	if not _vfx_holder:
		return
	var actor_node = _vfx_holder.actor_node
	var actor = actor_node.Actor
	var game_state = CombatRootControl.Instance.GameState
	
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)
		
	var attack_details = _data.get("AttackDetails", {})
	var damage_data = _data.get("DamageData", {})
	var effect_data = _data.get("EffectData", {})
	
	var center_pos = game_state.get_actor_pos(actor)
	for offset in range(tiles_traveled + 1):
		if offset == 0:
			continue
		var hit_pos = MapPos.new(center_pos.x, center_pos.y, center_pos.y, center_pos.dir)
		if center_pos.dir == MapPos.Directions.North:
			hit_pos.y -= offset
		if center_pos.dir == MapPos.Directions.South:
			hit_pos.y += offset
		if center_pos.dir == MapPos.Directions.East:
			hit_pos.x += offset
		if center_pos.dir == MapPos.Directions.West:
			hit_pos.x -= offset
		var target_actors = game_state.get_actors_at_pos(hit_pos)
		for target:BaseActor in target_actors:
			if _already_hit_actor_ids.has(target.Id):
				continue
			_already_hit_actor_ids.append(target.Id)
			DamageHelper.handle_attack(
				actor, 
				target, 
				attack_details, 
				damage_data, 
				effect_data, 
				tag_chain, 
				game_state, 
				_target_params,
				center_pos
			)
