@tool
class_name EffectDescriptionBox
extends BackPatchContainer


@export var name_label:Label
@export var duration_label:Label
@export var duration_type_label:Label
@export var description_label:RichTextLabel

func _ready() -> void:
	super()


func _process(delta: float) -> void:
	super(delta)

func set_effect(effect:BaseEffect):
	name_label.text = effect.get_display_name()
	if effect.show_counter():
		var dur_val = effect.RemainingDuration
		duration_label.text = str(dur_val)
		var duration_type = ''
		if effect.duration_trigger:
			duration_type = BaseEffect.EffectTriggers.keys()[effect.duration_trigger]
		if duration_type != '':
			var dur_str = duration_type.replace("End", "")
			if dur_val > 1:
				dur_str += 's'
			duration_type_label.text = dur_str
		else:
			duration_type_label.hide()
	else:
		duration_label.text = ''
	description_label.text = effect.get_snippet()
