class_name LevelUpPageControl
extends Control

signal level_up_menu_closed

@export var skill_page:SkillTreePageControl
@export var current_level_label:Label
@export var points_left_label:Label
@export var points_total_label:Label

@export var strength_controller:LevelUp_AttributeContainer
@export var agility_controller:LevelUp_AttributeContainer
@export var intelligence_controller:LevelUp_AttributeContainer
@export var wisdom_controller:LevelUp_AttributeContainer

@export var stats_container:Container
@export var confirm_button:TextureButton
@export var confirm_menu:CharacterMenuConfirmationControl

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
var stat_change_labels:Dictionary = {}

var _actor:BaseActor
var next_level:int
var exp_after_level_up:int

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm)
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

func _on_cancel():
	if _actor:_actor.stats.dirty_stats()
	level_up_menu_closed.emit()
	self.queue_free()

func _exit_tree() -> void:
	if _actor:
		_actor.stats.dirty_stats()
	
func _on_confirm():
	save_changes()
	level_up_menu_closed.emit()
	_actor = null

func save_changes():
	_actor.stats.apply_level_up(next_level, exp_after_level_up, add_values.duplicate())
	skill_page.apply_changes()

func set_actor(actor:BaseActor, confirmed:bool=false, apply_before_switch:bool=false):
	if _actor:
		if not confirmed and get_has_changes():
			confirm_menu.show_pop_up(set_actor.bind(actor, true, true), set_actor.bind(actor, true, false))
			return
		if apply_before_switch:
			save_changes()
		else:
			_actor.stats.dirty_stats()
	
	_actor = actor
	
	var current_level = _actor.stats.get_stat(StatHelper.Level, 0)
	var exp_val = _actor.stats.get_stat(StatHelper.Experience, 0)
	next_level = current_level
	var exp_to_next = _actor.stats.get_exp_to_next_level(current_level)
	var remaining = exp_val
	while remaining >= exp_to_next:
		remaining -= exp_to_next
		next_level += 1
		exp_to_next = _actor.stats.get_exp_to_next_level(current_level)
	
	
	exp_after_level_up = remaining
	
	if current_level == next_level:
		current_level_label.text = str(current_level)
	else:
		current_level_label.text = str(current_level) + " > " + str(next_level)
	
	var strength = actor.stats.get_leveled_attribute(StatHelper.Strength)
	#strength_controller.set_values(min_attribute_value, strength)
	
	var agility = actor.stats.get_leveled_attribute(StatHelper.Agility)
	#agility_controller.set_values(min_attribute_value, agility)
	
	var intel = actor.stats.get_leveled_attribute(StatHelper.Intelligence)
	#intelligence_controller.set_values(min_attribute_value, intel)
	
	var wisdom = actor.stats.get_leveled_attribute(StatHelper.Wisdom)
	#wisdom_controller.set_values(min_attribute_value, wisdom)
	
	add_values[StatHelper.Strength] = _actor.stats.attribute_levels.get(StatHelper.Strength, 0)
	add_values[StatHelper.Agility] = _actor.stats.attribute_levels.get(StatHelper.Agility, 0)
	add_values[StatHelper.Intelligence] = _actor.stats.attribute_levels.get(StatHelper.Intelligence, 0)
	add_values[StatHelper.Wisdom] = _actor.stats.attribute_levels.get(StatHelper.Wisdom, 0)
	
	starting_values[StatHelper.Strength] =  _actor.stats.attribute_levels[StatHelper.Strength]
	starting_values[StatHelper.Agility] =  _actor.stats.attribute_levels[StatHelper.Agility]
	starting_values[StatHelper.Intelligence] =  _actor.stats.attribute_levels[StatHelper.Intelligence]
	starting_values[StatHelper.Wisdom] =  _actor.stats.attribute_levels[StatHelper.Wisdom]
	#
	#_actor.stats.attribute_levels[StatHelper.Strength] =  0
	#_actor.stats.attribute_levels[StatHelper.Agility] =  0
	#_actor.stats.attribute_levels[StatHelper.Intelligence] =  0
	#_actor.stats.attribute_levels[StatHelper.Wisdom] =  0
	
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
	
	for row_child in stats_container.get_children():
		if row_child is Container:
			for child in row_child.get_children():
				if child is LevelUpStatLableContainer:
					child.set_starting_value(_actor)
	skill_page.set_actor(actor)

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
	#for attribute in add_values.keys():
		#_actor.stats.attribute_levels[attribute] = add_values[attribute]
	#_actor.stats.dirty_stats()
	_actor.stats.build_stats_with_temp_attributes(add_values)
	for attribute in attribute_controller.keys():
		var controller:LevelUp_AttributeContainer = attribute_controller[attribute]
		
		controller.value_lable.text = str(_actor.stats.get_base_stat(attribute) + add_values[attribute])
		if add_values[attribute] == 0:
			controller.minus_button.disabled = true
		else:
			controller.minus_button.disabled = false
		
		if points_left == 0:
			controller.plus_button.disabled = true
		else:
			controller.plus_button.disabled = false
	#for change_label:LevelUp_StatChangeContainer in stat_change_labels.values():
		#change_label.update_values(_actor)
	for row_child in stats_container.get_children():
		if row_child is Container:
			for child in row_child.get_children():
				if child is LevelUpStatLableContainer:
					child.set_stat_values(_actor)
		
func get_has_changes()->bool:
	var changed = (
		add_values[StatHelper.Strength] != starting_values[StatHelper.Strength]
		or add_values[StatHelper.Agility] != starting_values[StatHelper.Agility]
		or add_values[StatHelper.Intelligence] != starting_values[StatHelper.Intelligence]
		or add_values[StatHelper.Wisdom] != starting_values[StatHelper.Wisdom] 
		or skill_page.get_has_changes())
	
	return changed
