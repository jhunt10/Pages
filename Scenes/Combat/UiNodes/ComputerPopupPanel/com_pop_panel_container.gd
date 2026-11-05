@tool
class_name ComPopContainer
extends PanelContainer

signal confirmed
signal canceled

@export var highlight_target:CombatTutorialControl.HighlightTargets

@export var title_prefix:String:
	set(val):
		title_prefix = val
		if title_label:
			title_label.text = title_prefix + title_text

@export var title_text:String:
	set(val):
		title_text = val
		if title_label:
			title_label.text = title_prefix + title_text

@export var comfirm_button_text:String:
	set(val):
		comfirm_button_text = val
		if confirm_button:
			confirm_button.text = comfirm_button_text

@export var show_cancel_button:bool:
	set(val):
		show_cancel_button = val
		if cancel_button:
			cancel_button.visible = show_cancel_button
		if cancel_spacer:
			cancel_spacer.visible = !show_cancel_button
@export var show_info_button:bool:
	set(val):
		show_info_button = val
		if info_button:
			info_button.visible = show_info_button

@export_multiline var text:String:
	set(val):
		text = val
		if text_box:
			text_box.text = text

@export var close_button:TextureButton
@export var info_button:TextureButton
@export var click_drag_button:Button
@export var confirm_button:Button
@export var cancel_button:Button
@export var cancel_spacer:VSeparator
@export var title_label:Label
@export var text_box:RichTextLabel

var drag_offset = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if confirm_button: confirm_button.pressed.connect(confirmed.emit)
	if cancel_button: cancel_button.pressed.connect(canceled.emit)
	if close_button: close_button.pressed.connect(canceled.emit)
	if click_drag_button: 
		click_drag_button.button_down.connect(_click_drag_down)
		click_drag_button.button_up.connect(_click_drag_up)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if drag_offset:
		var mouse_pos = get_global_mouse_position()
		var self_pos = mouse_pos - drag_offset
		safe_set_position(self_pos)

func _click_drag_down():
	drag_offset = get_local_mouse_position()
	
func _click_drag_up():
	drag_offset = null

func safe_set_position(pos:Vector2):
	var self_rec = get_rect()
	var screen_rect = get_viewport_rect().size
	if pos.x < 0: 
		pos.x = 0
	if pos.x > screen_rect.x - self_rec.size.x:
		pos.x = screen_rect.x - self_rec.size.x
	if pos.y < 0: 
		pos.y = 0
	if pos.y > screen_rect.y - self_rec.size.y:
		pos.y = screen_rect.y - self_rec.size.y
	self.position = pos
