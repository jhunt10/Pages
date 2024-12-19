class_name PageDetailsCard_CostContaienr
extends HBoxContainer

@export var title_label:Label
@export var cost_label:PageDetailsCard_CostLabel

func set_costs(costs:Dictionary):
	cost_label.hide()
	for child in get_children():
		if child != title_label and child != cost_label:
			child.queue_free()
	for cost_key in costs.keys():
		var new_label:PageDetailsCard_CostLabel = cost_label.duplicate()
		new_label.set_values(cost_key, costs[cost_key])
		self.add_child(new_label)
		new_label.show()
		
