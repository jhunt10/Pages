@tool
class_name ExpBarControl
extends TextureRect

@export var full_rect:Control
@export var color_rect:ColorRect
@export var level_label:Label

@export var mouse_over_control:Control
@export var current_exp_label:Label
@export var max_exp_label:Label
@export var percent_full:float:
	set(val):
		percent_full = max(min(val, 1), 0)
		if color_rect:
			color_rect.size.x = full_rect.size.x * percent_full

@export var level_up_button_control:Control
@export var level_up_button:Button
@export var level_up_button_animation:AnimationPlayer

var _actor:BaseActor
var current_exp:float = 0
var max_exp:float = 1
var level_up_menu:LevelUpContainer
var opening_menu:bool = false

func _ready() -> void:
	if mouse_over_control:
		mouse_over_control.hide()
		self.mouse_entered.connect(_on_mouse_enter)
		self.mouse_exited.connect(_on_mouse_exit)
	if level_up_button:
		level_up_button.pressed.connect(open_level_up_menu)

func set_actor(actor:BaseActor):
	if _actor:
		_actor.stats_changed.disconnect(_sync)
	_actor = actor
	_actor.stats_changed.connect(_sync)
	_sync()

func open_level_up_menu():
	if level_up_button_animation:
		level_up_button_animation.play('waiting')
	opening_menu = true
	level_up_menu = MainRootNode.Instance.open_level_up_menu(_actor)
	#opening_menu = false
	level_up_menu.closed.connect(on_menu_closed)

func on_menu_closed():
	opening_menu = false
	_sync()

func _sync():
	if level_label:
		level_label.text = str(_actor.stats.get_stat(StatHelper.Level))
	current_exp = _actor.stats.get_stat(StatHelper.Experience)
	current_exp_label.text = str(current_exp)
	max_exp = _actor.stats.get_exp_to_next_level()
	max_exp_label.text = str(max_exp)
	self.percent_full = current_exp / max_exp
	if level_up_button_control:
		if current_exp >= max_exp and not opening_menu:
			if level_up_button_animation:
				level_up_button_animation.play('flashing_animation')
		else:
			if level_up_button_animation:
				level_up_button_animation.play('waiting')

func _on_mouse_enter():
	mouse_over_control.show()
func _on_mouse_exit():
	mouse_over_control.hide()
