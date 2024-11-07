class_name StatDisplayEntry
extends HBoxContainer

var stat_name_label:Label
var stat_value_label:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !stat_name_label: stat_name_label = $StatNameLabel
	if !stat_value_label: stat_value_label = $StatValueLabel

func set_stat(name:String, value):
	if !stat_name_label: stat_name_label = $StatNameLabel
	if !stat_value_label: stat_value_label = $StatValueLabel
	stat_name_label.text = name
	stat_value_label.text = str(value)
