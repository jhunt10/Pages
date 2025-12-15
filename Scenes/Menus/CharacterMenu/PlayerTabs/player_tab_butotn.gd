@tool
class_name PlayerTabButton
extends Control

enum States {Hidden, Growing, Showing, Shrinking}

@export var showing:bool:
	set(val):
		showing = val
		if val:
			if state == States.Hidden or state == States.Shrinking:
				state = States.Growing
		else:
			if state == States.Showing or state == States.Growing:
				state = States.Shrinking

@export var state:States:
	set(val):
		state = val
		if button_texture:
			button_texture.position.x = (self.size.x / 2) - (button_texture.size.x / 2)
			if state == States.Hidden:
				button_texture.position.y = 0
			if state == States.Showing:
				button_texture.position.y = -(top_hight)

@export var show_invalid:bool:
	set(val):
		show_invalid = val
		if invalid_icon and button_label:
			if show_invalid:
				invalid_icon.show()
				button_label._size_dirty = true
			else:
				invalid_icon.hide()
				button_label._size_dirty = true

@export var slide_speed:float = 100
@export var top_hight:int = 16
@export var button_texture:TextureRect
@export var button_label:FitScaleLabel
@export var button:Button
@export var invalid_icon:Control

var _actor_id:String = ''
var _actor_name:String = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	delta = min(delta, 0.03)
	if state == States.Growing:
		var move = delta * slide_speed
		if button_texture.position.y - move < 0 - top_hight:
			state = States.Showing
		else:
			button_texture.position.y -= move
	if state == States.Shrinking:
		var move = delta * slide_speed
		if button_texture.position.y + move > 0:
			state = States.Hidden
		else:
			button_texture.position.y += move

func set_actor(actor:BaseActor):
	var title_page:BasePageItem = actor.pages.get_title_page()
	if title_page:
		_actor_name = title_page.get_display_name()
	else:
		_actor_name = actor.get_display_name()
	_actor_id = actor._id
	check_level_up()
	if not actor.stats_changed.is_connected(check_level_up):
		actor.stats_changed.connect(check_level_up)

func check_level_up():
	if _actor_id:
		var actor = ActorLibrary.get_actor(_actor_id)
		if !actor:
			return
		if actor.stats.can_level_up():
			self.button_label.text = "+" + _actor_name
		else:
			self.button_label.text = _actor_name
