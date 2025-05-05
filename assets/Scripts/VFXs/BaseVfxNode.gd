class_name BaseVfxNode
extends Node2D

signal finished

enum States {Waiting, Playing, Finished, Errored}

var id:String
var _data:Dictionary
var _state:States = States.Waiting
var vfx_holder:VfxHolder
var actor_node:BaseActorNode:
	get():
		if vfx_holder:
			return vfx_holder.actor_node
		return null

var _readyed:bool=false
var _start_when_ready:bool=false

func parent_to_offset()->bool:
	return false

func _ready() -> void:
	_readyed = true
	if _start_when_ready:
		start_vfx()

func _process(delta: float) -> void:
	pass

func set_vfx_data(new_id:String, data:Dictionary):
	id = new_id
	_data = data
	if not _data.has("ChainVfxDatas"):
		_data['ChainVfxDatas'] = {}

func start_vfx():
	if not _readyed:
		_start_when_ready = true
		return
	if _state != States.Waiting:
		printerr("Double Started VFX: %s" % [self.id])
		return
	_state = States.Playing
	_on_start()

func _on_start(): 
	pass

func finish():
	if _state == States.Finished:
		return
	
	var chain_vfx_datas = _data.get("ChainVfxDatas", {})
	var source_actor = null
	if _data.has("SourceActorId"): source_actor = ActorLibrary.get_actor(_data['SourceActorId'])
	for vfx_key in chain_vfx_datas.keys():
		VfxHelper.create_vfx_on_actor(self.actor_node.Actor, vfx_key, chain_vfx_datas[vfx_key], source_actor)
		
	_state = States.Finished
	_on_delete()
	if vfx_holder and vfx_holder.has_vfx(self.id):
		vfx_holder.remove_vfx(self.id)
	finished.emit()

func _on_delete():
	pass

func add_chained_vfx(chain_key:String, chain_data:Dictionary):
	_data['ChainVfxDatas'][chain_key] = chain_data
