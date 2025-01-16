@tool
class_name QueInput_StartButton
extends Control

enum States {Hidden, Growing, Showing, Shrinking}
@export var vertical:bool = false
@export var state:States
@export var grow_speed:float
@export var button_texture:TextureRect
@export var button:Button
@export var label:Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == States.Hidden:
		return
	elif state == States.Growing:
		var move = delta * grow_speed
		if vertical:
			if button_texture.position.y < move:
				button_texture.position.y = 0
				state = States.Showing
			else:
				button_texture.position.y -= move
		else:
			if button_texture.position.x > 0 - move:
				button_texture.position.x = 0
				state = States.Showing
			else:
				button_texture.position.x += move
	elif state == States.Showing:
		return
	elif state == States.Shrinking:
		var move = delta * grow_speed
		if vertical:
			var button_width = button_texture.size.y
			print("Width: %s | Pos: %s | Move: %s" % [button_width, button_texture.position.x, move] )
			if button_texture.position.y + move > button_width:
				button_texture.position.y = button_width
				state = States.Hidden
			else:
				button_texture.position.y += move
		else:
			var button_width = button_texture.size.x
			print("Width: %s | Pos: %s | Move: %s" % [button_width, button_texture.position.x, move] )
			if button_texture.position.x - move < 0- button_width:
				button_texture.position.x = 0 - button_width
				state = States.Hidden
			else:
				button_texture.position.x -= move
	pass
