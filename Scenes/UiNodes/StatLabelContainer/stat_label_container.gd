class_name StatLabelContainer
extends BoxContainer

@export var stat_name:String
@export var name_label:Label
@export var icon:TextureRect
@export var value_label:Label
@export var percent_value:Label
@export var force_to_int:bool

@export var mouse_over_parent:Control

var mod_list_control


var _actor:BaseActor
var _icon_loaded = false

func _ready() -> void:
	self.mouse_entered.connect(_on_mouse_enter)
	self.mouse_exited.connect(_on_mouse_exit)

func set_values(stat_name:String, actor:BaseActor):
	self.stat_name = stat_name
	name_label.show()
	self.name_label.text = StatHelper.get_stat_abbr(stat_name)
	load_icon()
	set_stat_values(actor)

func set_stat_values(actor:BaseActor):
	var stat_val = actor.stats.get_stat(stat_name, 0)
	if force_to_int:
		stat_val = floori(stat_val)
	value_label.text = str(stat_val)
	_actor = actor
	if percent_value:
		percent_value.text = "%2.3f" % [DamageHelper.calc_armor_reduction(stat_val)]
	if not _icon_loaded:
		load_icon()
	#_build_stat_mod_list()

func load_icon():
	var icon_texture = StatHelper.get_stat_icon(stat_name)
	if icon_texture:
		self.icon.texture = icon_texture
		self.icon.show()
	else:
		self.icon.hide()
	_icon_loaded = true

func _on_mouse_enter():
	if not _actor:
		return
	mod_list_control = load("res://Scenes/Menus/CharacterMenu/MenuPages/StatsMenuPage/stat_mod_list_control.tscn").instantiate()
	if mod_list_control:
		if mouse_over_parent:
			mouse_over_parent.add_child(mod_list_control)
			mod_list_control.global_position = self.global_position
		else:
			self.add_child(mod_list_control)
		var mods = _actor.stats.get_mod_names_for_stat(stat_name)
		mod_list_control.set_mod_list(stat_name, mods)

func _on_mouse_exit():
	if mod_list_control:
		mod_list_control.queue_free()
		mod_list_control = null
