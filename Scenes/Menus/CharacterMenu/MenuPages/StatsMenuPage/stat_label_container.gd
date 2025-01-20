class_name StatLabelContainer
extends BoxContainer

@export var stat_name:String
@export var name_label:Label
@export var icon:TextureRect
@export var value_label:Label
@export var percent_value:Label

var mod_list_control


var _actor:BaseActor

func _ready() -> void:
	self.mouse_entered.connect(_on_mouse_enter)
	self.mouse_exited.connect(_on_mouse_exit)

func set_stat_values(actor:BaseActor):
	var stat_val = actor.stats.get_stat(stat_name, 0)
	value_label.text = str(stat_val)
	_actor = actor
	if percent_value:
		percent_value.text = "%2.3f" % [DamageHelper.calc_armor_reduction(stat_val)]
	#_build_stat_mod_list()

func _on_mouse_enter():
	if not _actor:
		return
	mod_list_control = load("res://Scenes/Menus/CharacterMenu/MenuPages/StatsMenuPage/stat_mod_list_control.tscn").instantiate()
	if mod_list_control:
		self.add_child(mod_list_control)
		var mods = _actor.stats.get_mod_names_for_stat(stat_name)
		mod_list_control.set_mod_list(mods)

func _on_mouse_exit():
	if mod_list_control:
		mod_list_control.queue_free()
		mod_list_control = null
