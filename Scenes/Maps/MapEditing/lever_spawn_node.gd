@tool
class_name LeverSpawnNode
extends ActorSpawnNode

@export var gate_key:String
@export var gate_color:Color:
	set(val):
		gate_color = val
		self.self_modulate = gate_color
		if Engine.is_editor_hint():
			var sceen_root = $"../../.."
			if sceen_root is MapControllerNode:
				var gates = sceen_root.get_gate_nodes()
				var gate = gates.get(gate_key)
				if gate:
					gate.get("Node").modulate = gate_color
				else:
					printerr("No Gate found with key: " + gate_key)


func get_actor_data()->Dictionary:
	return {
		"GateKey": gate_key,
		"GateColor": gate_color
	}
