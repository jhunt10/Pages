class_name BaseVfxNode
extends Node2D

signal finished

enum States {
	Waiting, # Created and not yet started
	Playing, # Is Playing
	Finished, # Finished Playing and waiting to be deleted
	# Deleted, # Not a state because it's deleted
	Errored # Failed with an Error
	}
	
@export var delete_immediately_on_finish:bool = true

var id:String
var _data:Dictionary
var _state:States = States.Waiting
var vfx_holder:VfxHolder
var actor_node:BaseActorNode:
	get():
		if vfx_holder:
			return vfx_holder.actor_node
		return null

var _readyed:bool = false
var _start_when_ready:bool = false
var _built_chained_vfxs:bool = false
var _been_deleted:bool = false

func parent_to_offset()->bool:
	return false

func _ready() -> void:
	_readyed = true
	if _start_when_ready:
		start_vfx()

func _process(_delta: float) -> void:
	# Check if node is fully finished and ready to delet
	# Some animations / particals lag after finish()
	if _state == States.Finished and not _been_deleted:
		if is_ready_to_delete():
			_delete_self()

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
	if _data.get("ShakeActor", false):
		if vfx_holder and vfx_holder.actor_node:
			vfx_holder.actor_node.play_shake()

func _on_start(): 
	pass

func _trigger_next_vfxs():
	if not _built_chained_vfxs:
		build_chained_vfx()

func build_chained_vfx():
	if _built_chained_vfxs:
		return
	_built_chained_vfxs = true
	var chain_vfx_datas = _data.get("ChainVfxDatas", {})
	var source_actor = _data.get('SourceActorId')
	for vfx_key in chain_vfx_datas.keys():
		if chain_vfx_datas[vfx_key].has("DamageNumber"):
			VfxHelper.create_damage_effect(self.actor_node.Actor, vfx_key, chain_vfx_datas[vfx_key])
		else:
			VfxHelper.create_vfx_on_actor(self.actor_node.Actor, vfx_key, chain_vfx_datas[vfx_key], source_actor)

## Called after the node has "finished" to check for any lingering Audio or Particals to finish.
func is_ready_to_delete()->bool:
	return true

func finish():
	if _state == States.Finished:
		return
	_on_finish()
	if not _built_chained_vfxs:
		build_chained_vfx()
	
	_state = States.Finished
	if is_ready_to_delete():
		_delete_self()
	finished.emit()

func _delete_self():
	_been_deleted = true
	_on_delete()
	if vfx_holder and vfx_holder.has_vfx(self.id):
		vfx_holder.remove_vfx(self.id)
	self.queue_free()

func _on_finish():
	pass

func _on_delete():
	pass

func add_chained_vfx(chain_key:String, chain_data:Dictionary):
	_data['ChainVfxDatas'][chain_key] = chain_data

# Only called by VfxHolder.remove_vfx. Exists to double check logic
func _removed_from_vfx_holder():
	if not _state == States.Finished:
		printerr("Vfx removed without finishing")
		self.finish()
	if not _been_deleted:
		printerr("Vfx removed without deleting")
		self._delete_self()
