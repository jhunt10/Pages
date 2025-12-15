class_name LevelUpContainer
extends Control

const min_attribute_value = 8

signal closed

@export var exit_button:Button
@export var confirm_button:PatchButton
@export var level_up_title_container:Container
@export var edit_title_container:Container

@export var current_level_label:Label
@export var current_level_label2:Label
@export var new_level_label:Label
@export var points_left_label:Label
@export var points_total_label:Label

@export var premade_stat_label:LevelUp_StatChangeContainer

@export var strength_controller:LevelUp_AttributeContainer
@export var strength_stats_contaienr:FlowContainer
@export var agility_controller:LevelUp_AttributeContainer
@export var agility_stats_contaienr:FlowContainer
@export var intelligence_controller:LevelUp_AttributeContainer
@export var intelligence_stats_contaienr:FlowContainer
@export var wisdom_controller:LevelUp_AttributeContainer
@export var wisdom_stats_contaienr:FlowContainer

var total_points:int:
	set(val):
		total_points = val
		if points_total_label:
			points_total_label.text = str(val)
var points_left:int:
	set(val):
		points_left = val
		if points_left_label:
			points_left_label.text = str(points_left)

var starting_values:Dictionary = {}
var add_values:Dictionary = {}
var attribute_controller:Dictionary = {}
var attribute_containers:Dictionary = {}
var stat_change_labels:Dictionary = {}

var _actor:BaseActor
var next_level:int
var exp_after_level_up:int

func _ready() -> void:
	premade_stat_label.hide()
	strength_controller.plus_button.pressed.connect(_spend_point.bind(StatHelper.Strength))
	strength_controller.minus_button.pressed.connect(_take_back_point.bind(StatHelper.Strength))
	
	agility_controller.plus_button.pressed.connect(_spend_point.bind(StatHelper.Agility))
	agility_controller.minus_button.pressed.connect(_take_back_point.bind(StatHelper.Agility))
	
	intelligence_controller.plus_button.pressed.connect(_spend_point.bind(StatHelper.Intelligence))
	intelligence_controller.minus_button.pressed.connect(_take_back_point.bind(StatHelper.Intelligence))
	
	wisdom_controller.plus_button.pressed.connect(_spend_point.bind(StatHelper.Wisdom))
	wisdom_controller.minus_button.pressed.connect(_take_back_point.bind(StatHelper.Wisdom))

	attribute_controller[StatHelper.Strength] = strength_controller
	attribute_controller[StatHelper.Agility] = agility_controller
	attribute_controller[StatHelper.Intelligence] = intelligence_controller
	attribute_controller[StatHelper.Wisdom] = wisdom_controller
	
	attribute_containers[StatHelper.Strength] = strength_stats_contaienr
	attribute_containers[StatHelper.Agility] = agility_stats_contaienr
	attribute_containers[StatHelper.Intelligence] = intelligence_stats_contaienr
	attribute_containers[StatHelper.Wisdom] = wisdom_stats_contaienr
	
	exit_button.pressed.connect(_on_cancel)
	confirm_button.pressed.connect(_on_confirm)

func _on_cancel():
	if _actor and starting_values.size() > 0:
		_actor.stats.attribute_levels[StatHelper.Strength] = starting_values[StatHelper.Strength]
		_actor.stats.attribute_levels[StatHelper.Agility] = starting_values[StatHelper.Agility]
		_actor.stats.attribute_levels[StatHelper.Intelligence] = starting_values[StatHelper.Intelligence]
		_actor.stats.attribute_levels[StatHelper.Wisdom] = starting_values[StatHelper.Wisdom]
		_actor.stats.recache_stats()
		_actor = null
	closed.emit()
	self.queue_free()

func _on_confirm():
	_actor.stats.apply_level_up(next_level, exp_after_level_up, add_values.duplicate())
	closed.emit()
	self.queue_free()

func set_actor(actor:BaseActor):
	if _actor:
		_actor.stats.clear_temp_mods()
	_actor = actor
	
	var current_level = _actor.stats.get_stat(StatHelper.Level, 0)
	var exp = _actor.stats.get_stat(StatHelper.Experience, 0)
	next_level = current_level
	var exp_to_next = _actor.stats.get_exp_to_next_level(current_level)
	var remaining = exp 
	while remaining >= exp_to_next:
		remaining -= exp_to_next
		next_level += 1
		exp_to_next = _actor.stats.get_exp_to_next_level(current_level)
	
	current_level_label.text = str(current_level)
	current_level_label2.text = str(current_level)
	new_level_label.text = str(next_level)
	exp_after_level_up = remaining
	
	if current_level == next_level:
		level_up_title_container.hide()
		edit_title_container.show()
	else:
		level_up_title_container.show()
		edit_title_container.hide()
	
	var strength = actor.stats.get_leveled_attribute(StatHelper.Strength)
	strength_controller.set_values(min_attribute_value, strength)
	
	var agility = actor.stats.get_leveled_attribute(StatHelper.Agility)
	agility_controller.set_values(min_attribute_value, agility)
	
	var intel = actor.stats.get_leveled_attribute(StatHelper.Intelligence)
	intelligence_controller.set_values(min_attribute_value, intel)
	
	var wisdom = actor.stats.get_leveled_attribute(StatHelper.Wisdom)
	wisdom_controller.set_values(min_attribute_value, wisdom)
	
	add_values[StatHelper.Strength] = _actor.stats.attribute_levels.get(StatHelper.Strength, 0)
	add_values[StatHelper.Agility] = _actor.stats.attribute_levels.get(StatHelper.Agility, 0)
	add_values[StatHelper.Intelligence] = _actor.stats.attribute_levels.get(StatHelper.Intelligence, 0)
	add_values[StatHelper.Wisdom] = _actor.stats.attribute_levels.get(StatHelper.Wisdom, 0)
	
	starting_values[StatHelper.Strength] =  _actor.stats.attribute_levels[StatHelper.Strength]
	starting_values[StatHelper.Agility] =  _actor.stats.attribute_levels[StatHelper.Agility]
	starting_values[StatHelper.Intelligence] =  _actor.stats.attribute_levels[StatHelper.Intelligence]
	starting_values[StatHelper.Wisdom] =  _actor.stats.attribute_levels[StatHelper.Wisdom]
	
	_actor.stats.attribute_levels[StatHelper.Strength] =  0
	_actor.stats.attribute_levels[StatHelper.Agility] =  0
	_actor.stats.attribute_levels[StatHelper.Intelligence] =  0
	_actor.stats.attribute_levels[StatHelper.Wisdom] =  0
	
	total_points = StatHelper.get_attribute_points_for_level(next_level)
	var spent_points = (
		add_values[StatHelper.Strength] +
		add_values[StatHelper.Agility] +
		add_values[StatHelper.Intelligence] +
		add_values[StatHelper.Wisdom] 
	) 
	points_left = total_points - spent_points
	
	_sync_values()
	for label in stat_change_labels.values():
		label.queue_free()
	stat_change_labels.clear()
	for attribute in attribute_controller.keys():
		var modded_stats = actor.stats.get_stats_dependant_on_attribute(attribute)
		for stat_name in modded_stats:
			var stat_label_key = attribute+":"+stat_name
			if not stat_change_labels.has(stat_label_key):
				var new_stat_label:LevelUp_StatChangeContainer = premade_stat_label.duplicate()
				new_stat_label.set_stat_name(stat_name)
				new_stat_label.set_stat_values(actor)
				attribute_containers[attribute].add_child(new_stat_label)
				stat_change_labels[stat_label_key] = new_stat_label
				new_stat_label.show()

func _spend_point(stat_name:String):
	if points_left == 0:
		return
	add_values[stat_name] += 1
	points_left -= 1
	_sync_values()

func _take_back_point(stat_name:String):
	add_values[stat_name] -= 1
	points_left += 1
	_sync_values()
	
	pass

func _sync_values():
	for attribute in add_values.keys():
		_actor.stats.attribute_levels[attribute] = add_values[attribute]
	_actor.stats.dirty_stats()
	for attribute in attribute_controller.keys():
		var controller:LevelUp_AttributeContainer = attribute_controller[attribute]
		controller.goto_value = _actor.stats.get_leveled_attribute(attribute)
		if add_values[attribute] == 0:
			controller.minus_button.hide()
		else:
			controller.minus_button.show()
		
		if points_left == 0:
			controller.plus_button.hide()
		else:
			controller.plus_button.show()
	for change_label:LevelUp_StatChangeContainer in stat_change_labels.values():
		change_label.update_values(_actor)
		
		
