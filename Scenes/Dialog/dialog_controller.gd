class_name DialogController
extends Control

@export var next_button:DialogControlButton
@export var skip_button:DialogControlButton
@export var auto_button:AutoDialogControlButton

## Dialog scripts are divided into "parts" made up of "blocks"
var _dialog_parts:Dictionary


# Skipping: Goes to next part. 
#			Current part is entirly abandoned and next part started
#			Skipping will be haulted if a question is answered. Question should be at start of blocks.
# ForceFinish: Goes to final state of current part. 
#			Final state will need to be determined by cycleing over all blocks.
# AutoPlay: Will automaticly move to next part when all blocks of current part finish.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
