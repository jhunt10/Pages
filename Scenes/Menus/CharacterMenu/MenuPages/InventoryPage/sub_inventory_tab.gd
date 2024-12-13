@tool
class_name SubInventoryTab
extends NinePatchRect

enum State {Rest, Growing, Selected, Shrinking}

@export var is_selected:bool:
	set(val):
		is_selected = val
		if is_selected and state != State.Selected:
			self.state = State.Growing
		if not  is_selected and state != State.Rest:
			self.state = State.Shrinking
@export var filter_name:String:
	set(val):
		filter_name = val
		if name_label:
			name_label.text = val
@export var state:State
@export var selected_spacer_size:float
@export var grow_speed:int = 500
@export var highlight_texture:NinePatchRect
@export var name_label:Label
@export var button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == State.Rest or state == State.Selected:
		return
	if state == State.Growing:
		var target_size = 64 + selected_spacer_size
		var new_size = self.size.x + (grow_speed * delta)
		if new_size >= target_size:
			self.size.x = target_size
			state = State.Selected
		else:
			self.size.x = new_size
		var percent_there = (new_size - 64) / (target_size - 64) 
		if highlight_texture:
			highlight_texture.self_modulate.a = (percent_there / 2)
	if state == State.Shrinking:
		var target_size = 64 
		var new_size = self.size.x - (grow_speed * delta)
		if new_size <= target_size:
			self.size.x = target_size
			state = State.Rest
		else:
			self.size.x = new_size
		var percent_there = (new_size - 64) / (target_size + selected_spacer_size - 64) 
		if highlight_texture:
			highlight_texture.self_modulate.a = (percent_there / 2)
	pass
