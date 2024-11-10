class_name StatDisplayEntry
extends HBoxContainer

var stat_name_label:Label
var stat_value_label:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !stat_name_label: stat_name_label = $StatNameLabel
	if !stat_value_label: stat_value_label = $StatValueLabel

func set_values(name:String, value):
	if !stat_name_label: stat_name_label = $StatNameLabel
	if !stat_value_label: stat_value_label = $StatValueLabel
	stat_name_label.text = name
	stat_value_label.text = str(value)

func set_stat(name:String, base_value, curt_value, mod_names):
	if !stat_name_label: stat_name_label = $StatNameLabel
	if !stat_value_label: stat_value_label = $StatValueLabel
	stat_name_label.text = name
	if base_value > curt_value:
		stat_value_label.self_modulate = Color.RED
	elif base_value < curt_value:
		stat_value_label.self_modulate = Color.GREEN
	else:
		stat_value_label.self_modulate = Color.WHITE
	stat_value_label.text = str(curt_value)
	#stat_value_label.text += str(mod_names)
