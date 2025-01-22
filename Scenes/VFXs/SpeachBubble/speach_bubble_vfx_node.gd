@tool
class_name SpeachBubbleVfxNode
extends VfxNode

enum GrowDirections {Left, Center, Right}
enum STATES { Hidden, Growing, Printing, Showing, Unprinting, Shrinking}

enum BubbleType {Text, Bang, Question}


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

@export var bubble_type:BubbleType:
	set(val):
		bubble_type =  val
		if (not speach_bubble_background 
		or not bang_icon or not question_icon):
			return
		elif bubble_type == BubbleType.Text:
			speach_bubble_background.show()
			bang_icon.hide()
			question_icon.hide()
		elif bubble_type == BubbleType.Bang:
			speach_bubble_background.hide()
			bang_icon.show()
			question_icon.hide()
		elif bubble_type == BubbleType.Question:
			speach_bubble_background.hide()
			bang_icon.hide()
			question_icon.show()
			
@export var bounce:bool = false
@export var display_text:String:
	set(val):
		if display_text != val:
			display_text = val
			if text_label:
				text_label.text = display_text
				bounce_text_controller.display_text = display_text
				if Engine.is_editor_hint():
					_sync_size()

@export var grow_direction:GrowDirections:
	set(val):
		grow_direction = val
		if corner_spike_bot_left:
			if grow_direction == GrowDirections.Left:
				corner_spike_bot_left.show()
				corner_spike_bot_center.hide()
				corner_spike_bot_right.hide()
			if grow_direction == GrowDirections.Center:
				corner_spike_bot_left.hide()
				corner_spike_bot_center.show()
				corner_spike_bot_right.hide()
			if grow_direction == GrowDirections.Right:
				corner_spike_bot_left.hide()
				corner_spike_bot_center.hide()
				corner_spike_bot_right.show()

@export var state:STATES = STATES.Hidden:
	set(val):
		if val != state:
			state = val
			if not scale_control or not speach_bubble_background or not text_label:
				return
			if state == STATES.Hidden:
				scale_control.scale = Vector2.ZERO
				#speach_bubble_background.hide()
				speach_bubble_background.size = Vector2.ZERO
				text_label.text = ''
				bounce_text_controller.display_text = ''
			if state == STATES.Growing:
				scale_control.scale = Vector2.ZERO
				#speach_bubble_background.hide()
				text_label.text = ''
				bounce_text_controller.display_text = ''
				speach_bubble_background.size = Vector2.ZERO
			#if state == STATES.Printing:
				#scale_control.scale = Vector2.ONE
				#speach_bubble_background.show()
				text_label.text = ''
				bounce_text_controller.display_text = ''
				_sync_size()
			if state == STATES.Showing:
				scale_control.scale = Vector2.ONE
				#speach_bubble_background.show()
				text_label.text = display_text
				bounce_text_controller.display_text = display_text
				_sync_size()
			if state == STATES.Shrinking or state == STATES.Unprinting:
				bounce_text_controller.hide()
				text_label.hide()
			else:
				if bounce:
					text_label.hide()
					bounce_text_controller.show()
				else:
					bounce_text_controller.hide()
					text_label.show()
				#speach_bubble_background.hide()
				#text_label.text = display_text
				#hidden_line_edit.text = display_text
				#_sync_size()
	
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
@export var speach_bubble_background:NinePatchRect
@export var scale_control:Control
@export var bounce_text_controller:BounceTextControl
@export var bang_icon:TextureRect
@export var question_icon:TextureRect
@export var corner_spike_bot_left:TextureRect
@export var corner_spike_bot_center:TextureRect
@export var corner_spike_bot_right:TextureRect

var _letter_timer:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_readyed = true
	self.state = STATES.Hidden
	if showing:
		self.state = STATES.Growing
	#scale_control.scale = Vector2.ZERO
	if grow_direction == GrowDirections.Left:
		speach_bubble_background.position = Vector2(3, -speach_bubble_background.size.y-3)
	if grow_direction == GrowDirections.Center:
		speach_bubble_background.position = Vector2(-28/ 2.0, -speach_bubble_background.size.y-5)
	if grow_direction == GrowDirections.Right:
		speach_bubble_background.position = Vector2(-28-3, -speach_bubble_background.size.y-3)
	if _delayed_start:
		start_vfx()

func start_vfx():
	return
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == STATES.Growing:
		if scale_control.scale.x < 1:
			## Correct for odd offset when growing to right. Maybe rounding error?
			if grow_direction == GrowDirections.Center and scale_control.scale.x  <= 0.001:
				speach_bubble_background.position.x = -14
			if grow_direction == GrowDirections.Right and scale_control.scale.x  <= 0.001:
				speach_bubble_background.position.x = speach_bubble_background.position.y
				
			scale_control.scale.x = min(1, scale_control.scale.x + (delta * grow_speed))
			scale_control.scale.y = scale_control.scale.x
			if scale_control.scale.x >= 1:
				#_letter_timer = 0
				#state = STATES.Printing
				scale_control.scale.x = 1
	#if state == STATES.Growing or state == STATES.Printing:
		_letter_timer -= delta
		var remaining_text = display_text.trim_prefix(text_label.text)
		if _letter_timer <= 0:
			var current_text = text_label.text
			var next_letter = remaining_text.substr(0,1)
			text_label.text = current_text + next_letter
			if bounce:
				bounce_text_controller.display_text = text_label.text 
			_sync_size()
			if remaining_text.length() > 1:
				_letter_timer = letter_delay
			
		if scale_control.scale.x >= 1 and remaining_text.length() == 0:
			state = STATES.Showing
			finished_showing.emit()
			return
			
	if state == STATES.Unprinting:
		var min_x = speach_bubble_background.custom_minimum_size.x
		var new_x = maxf(0, speach_bubble_background.size.x - (unprint_speed * delta))

		if min_x >= new_x:
			state = STATES.Shrinking
			return
		else:
			speach_bubble_background.size.x = new_x
			if grow_direction == GrowDirections.Left:
				speach_bubble_background.position = Vector2(3, -speach_bubble_background.size.y-3)
			if grow_direction == GrowDirections.Center:
				speach_bubble_background.position = Vector2(-new_x/ 2.0, -speach_bubble_background.size.y-5)
			if grow_direction == GrowDirections.Right:
				speach_bubble_background.position = Vector2(-new_x-3, -speach_bubble_background.size.y-3)
	if state == STATES.Shrinking:
		scale_control.scale.x = max(0.0, scale_control.scale.x - (delta * grow_speed))
		scale_control.scale.y = scale_control.scale.x
		if scale_control.scale.x <= 0.001:
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

func set_block_data(block_data:Dictionary):
	var grow_direction_str = block_data.get("GrowDirection", "Center")
	grow_direction = GrowDirections.keys().find(grow_direction_str)
	var offset = block_data.get("Offset", [0,-8])
	self.position = Vector2(offset[0],offset[1])
	display_text = block_data.get("Text", "null")
	if display_text == "?":
		self.bubble_type = BubbleType.Question
	elif display_text == "!":
		self.bubble_type = BubbleType.Bang
	else: 
		self.bubble_type = BubbleType.Text
	bounce = block_data.get("UseBounceText", false)
	letter_delay = block_data.get("LetterDelay", letter_delay)

func add_flash_text(text:String, color:Color):
	pass


func _sync_size():
	var new_size = text_label.get_minimum_size()
	new_size.x += text_label.offset_left - text_label.offset_right -2
	new_size.y = 28
	new_size = Vector2(new_size.x + (padding.x * 2) - end_trim, new_size.y + (padding.y*2))
	if new_size.x > 28:
		new_size.x += 1
		text_label.offset_right = -5
	else:
		text_label.offset_right = -4
	speach_bubble_background.size = new_size
	var new_width = max(speach_bubble_background.custom_minimum_size.x, new_size.x)
	if grow_direction == GrowDirections.Left:
				speach_bubble_background.position = Vector2i(3, -new_size.y-3)
	if grow_direction == GrowDirections.Center:
		speach_bubble_background.position = Vector2i(-new_width/ 2, -new_size.y-5)
	if grow_direction == GrowDirections.Right:
		speach_bubble_background.position = Vector2i(-new_width-3, -new_size.y-3)
