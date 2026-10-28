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

@export_multiline var text:String:
	set(val):
		text = val
		if text_box:
			text_box.text = text

@export var close_button:TextureButton
@export var info_button:TextureButton
@export var confirm_button:Button
@export var cancel_button:Button
@export var cancel_spacer:VSeparator
@export var title_label:Label
@export var text_box:RichTextLabel

func _ready() -> void:
	if confirm_button:
		confirm_button.pressed.connect(confirmed.emit)
	if cancel_button:
		cancel_button.pressed.connect(canceled.emit)
	if close_button:
		close_button.pressed.connect(canceled.emit)
