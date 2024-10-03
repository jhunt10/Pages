class_name BaseStatMod

var Id : String = str(ResourceUID.create_id())

# Called at start of turn
func on_turn_start():
	pass

# Called at end of turn
func on_turn_end():
	pass

# Called at start of round
func on_round_start():
	pass

# Called at end of round
func on_round_end():
	pass

# Called when the target of this mod changes potision
func on_move(old_pos:Vector3i, new_pos:Vector3i, move_type:String, pushed_by_actor:BaseActor = null):
	pass

# Called when the source of this mod changes position (Like if someone with an aura moves)	
func on_source_move():
	pass
	
# Called as damage is being calculated 
func on_receiving_damage(value:int, damage_type:String, source)->int:
	return value
	
# Called after target of this mod has taken damage
func on_damage_taken(value:int, damage_type:String, source):
	pass
	
