@tool
class_name SpeachBubbleVfxNode
extends VfxNode

enum STATES { Hidden, Growing, Printing, Showing, Unprinting, Shrinking}

signal finished_showing
signal finished_hideing

@export var showing:bool = false:
	set(val):
		if showing != val:
			showing = val
			if showing:
				if state == STATES.Hidden or state == STATES.Unprinting or state == STATES.Shrinking:
					state = STATES.Growing
			else:
				if state == STATES.Growing or state == STATES.Printing or state == STATES.Showing:
					state = STATES.Unprinting

@export var display_text:String:
	set(val):
		if display_text != val:
			display_text = val
			if text_label:
				text_label.text = display_text
			if hidden_line_edit:
				hidden_line_edit.text = val
				_sync_size()

@export var state:STATES = STATES.Hidden:
	set(val):
		if val != state:
			state = val
			if not speach_bubble_sprite or not speach_bubble_background or not text_label or not hidden_line_edit:
				return
			if state == STATES.Hidden:
				speach_bubble_sprite.scale = Vector2.ZERO
				speach_bubble_background.hide()
				speach_bubble_background.size = Vector2.ZERO
				text_label.text = ''
				hidden_line_edit.text = ''
			if state == STATES.Growing:
				speach_bubble_sprite.scale = Vector2.ZERO
				speach_bubble_background.hide()
				text_label.text = ''
				hidden_line_edit.text = ''
				speach_bubble_background.size = Vector2.ZERO
			if state == STATES.Printing:
				speach_bubble_sprite.scale = Vector2.ONE
				speach_bubble_background.show()
				text_label.text = ''
				hidden_line_edit.text = ''
				_sync_size()
			if state == STATES.Showing:
				speach_bubble_sprite.scale = Vector2.ONE
				speach_bubble_background.show()
				text_label.text = display_text
				hidden_line_edit.text = display_text
				_sync_size()
			if state == STATES.Shrinking:
				speach_bubble_background.hide()
				text_label.text = display_text
				hidden_line_edit.text = display_text
				_sync_size()
	
@export var begin_offset:int:
	set(val):
		if val != begin_offset:
			begin_offset = val
			_sync_size()
@export var end_trim:int:
	set(val):
		if val != end_trim:
			end_trim = val
			_sync_size()
@export var padding:Vector2i
@export var grow_speed:float = 1
@export var letter_delay:float = 0.1
@export var unprint_speed:float = 1
@export var text_label:Label
@export var hidden_line_edit:LineEdit
@export var speach_bubble_background:NinePatchRect
@export var speach_bubble_sprite:Sprite2D

var _letter_timer:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_readyed = true
	if _delayed_start:
		start_vfx()

func start_vfx():
	return
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == STATES.Growing:
		speach_bubble_sprite.scale.x = min(1, speach_bubble_sprite.scale.x + (delta * grow_speed))
		speach_bubble_sprite.scale.y = speach_bubble_sprite.scale.x
		if speach_bubble_sprite.scale.x >= 1:
			_letter_timer = 0
			state = STATES.Printing
			return
	if state == STATES.Printing:
		_letter_timer -= delta
		if _letter_timer <= 0:
			var current_text = text_label.text
			var remaining_text = display_text.trim_prefix(current_text)
			var next_letter = remaining_text.substr(0,1)
			text_label.text = current_text + next_letter
			hidden_line_edit.text = current_text + next_letter
			_sync_size()
			if remaining_text.length() > 1:
				_letter_timer = letter_delay
			else:
				state = STATES.Showing
				finished_showing.emit()
				return
	if state == STATES.Unprinting:
		var min_x = speach_bubble_background.custom_minimum_size.x
		var new_x = max(0, speach_bubble_background.size.x - (unprint_speed * delta))
		speach_bubble_background.size.x = new_x
		if min_x >= new_x:
			state = STATES.Shrinking
			return
	if state == STATES.Shrinking:
		speach_bubble_sprite.scale.x = max(0.0, speach_bubble_sprite.scale.x - (delta * grow_speed))
		speach_bubble_sprite.scale.y = speach_bubble_sprite.scale.x
		if speach_bubble_sprite.scale.x <= 0.001:
			state = STATES.Hidden
			finished_hideing.emit()
			return
	if Engine.is_editor_hint():
		return
	if _has_animation and !animation.is_playing():
		self.queue_free()
	if _flash_text_value and animation_half_way and not _flash_text_shown:
			CombatRootControl.Instance.create_flash_text(self.get_parent(), _flash_text_value, _flash_text_color)
			_flash_text_shown = true

func set_vfx_data(data:VfxData, extra_data:Dictionary):
	pass

func add_flash_text(text:String, color:Color):
	pass


func _sync_size():
	if !hidden_line_edit:
		printerr("SelfScalingLineEdit '%s' No Hidden TextEdit found." % [self.name])
		return
	hidden_line_edit.size = Vector2.ZERO
	hidden_line_edit.text = self.display_text
	var new_size = hidden_line_edit.size
	new_size = Vector2(new_size.x + (padding.x * 2) - end_trim, new_size.y + (padding.y*2))
	speach_bubble_background.size = new_size
