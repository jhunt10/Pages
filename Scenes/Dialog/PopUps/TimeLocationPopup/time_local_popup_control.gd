class_name TimeLocationPopUpControl
extends Control

signal outro_finished

@onready var location_label:Label = $ScaleControl/ColorRect/VBoxContainer/LocationLabel
@onready var time_label:Label = $ScaleControl/ColorRect/VBoxContainer/TimeLabel

var location_string:String
var time_string:String

func _ready() -> void:
	location_label.text = location_string
	time_label.text = time_string
	

func set_location_and_time(location:String, time:String):
	location_string = location
	time_string = time

func animation_finished():
	outro_finished.emit()
	self.queue_free()
