@tool
class_name HTabsControls
extends Control

signal selected_index_changed(index:int)

@export var dot_texture_empty:Texture2D
@export var dot_texture_filled:Texture2D
@export var dot_texture_selected:Texture2D
@export var left_button:Button
@export var right_button:Button
@export var premade_dot:NinePatchRect
@export var dots_container:HBoxContainer

@export var selected_index:int:
	set(val):
		var new_val = max(0, min(dot_count, val))
		if new_val != selected_index:
			selected_index = new_val
			selected_index_changed.emit(selected_index)
		if dots_container and dots_container.get_child_count() > selected_index:
			var dots = dots_container.get_children()
			for index in range(dots.size()):
				if index == selected_index:
					dots[index].texture = dot_texture_filled
				else:
					dots[index].texture = dot_texture_empty
@export var dot_count:int:
	get:
		if dots_container:
			return dots_container.get_child_count()
		return 0
	set(val):
		if dots_container and dot_count != val:
			_create_dots(val)
			selected_index = selected_index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if premade_dot and not Engine.is_editor_hint():
		if premade_dot.visible:
			premade_dot.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _create_dots(count:int):
	if !dots_container or !premade_dot:
		return
	for child in dots_container.get_children():
		child.queue_free()
	for i in range(count):
		var new_dot = premade_dot.duplicate()
		new_dot.get_child(0).pressed.connect(on_dot_pressed.bind(i))
		dots_container.add_child(new_dot)
		new_dot.visible = true
		

func on_dot_pressed(index:int):
	selected_index = index
	pass
