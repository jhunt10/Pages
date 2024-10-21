extends Control

@export var inner_container:VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_options(action_key:int, options:Array, on_option_func:Callable):
	var button_count = 0
	for option in options:
		var button:Button = Button.new()
		button.custom_minimum_size = Vector2i(0,32)
		button.text = option
		inner_container.add_child(button)
		button.pressed.connect(on_option_func.bind(option))
	var action_que_display = CombatRootControl.Instance.ui_controller.qu
