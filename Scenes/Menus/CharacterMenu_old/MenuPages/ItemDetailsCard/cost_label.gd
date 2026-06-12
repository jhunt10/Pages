class_name PageDetailsCard_CostLabel
extends HBoxContainer

@export var name_label:Label
@export var cost_label:Label

func set_values(stat_name:String, cost:int):
	name_label.text = stat_name
	cost_label.text = str(cost)
