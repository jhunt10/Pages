class_name StartCharacterSelectMenu
extends Control

signal character_selected(char_name:String)

@export var soldier_card:CharacterCard
@export var rogue_card:CharacterCard
@export var mage_card:CharacterCard
@export var priest_card:CharacterCard

@export var selected_card_parent:Control
@export var max_move_speed:float
@export var min_move_speed:float
@export var move_speed_factor:float

@export var hint_box:NinePatchRect
@export var confirm_box:NinePatchRect
@export var confirm_box_label:Label
@export var yes_button:TextureButton
@export var no_button:TextureButton
@export var back_button:Button

var selected_card_name
var selected_card:Control
var selected_start_pos:Vector2
var selected_target_pos:Vector2
var selected_org_parent_container:CenterContainer

var deselected_card_name
var deselected_card:Control
var deselected_start_pos:Vector2
var deselected_target_pos:Vector2
var deselected_org_parent_container:CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	soldier_card.button.pressed.connect(on_card_selected.bind("Soldier"))
	rogue_card.button.pressed.connect(on_card_selected.bind("Rogue"))
	mage_card.button.pressed.connect(on_card_selected.bind("Mage"))
	priest_card.button.pressed.connect(on_card_selected.bind("Priest"))
	soldier_card.fade = 1
	rogue_card.fade = 1
	mage_card.fade = 1
	priest_card.fade = 1
	hint_box.modulate.a = 0
	confirm_box.modulate.a = 0
	no_button.pressed.connect(deselect_card)
	yes_button.pressed.connect(on_card_confirmed)
	yes_button.disabled = true
	no_button.disabled = true
	back_button.pressed.connect(on_back)
	pass # Replace with function body.

func on_back():
	self.queue_free()
	MainRootNode.Instance.go_to_main_menu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if selected_card and selected_card.position != selected_target_pos:
		var dist_sqr = selected_card.position.distance_squared_to(selected_target_pos)
		var speed = min(max_move_speed,max(min_move_speed, dist_sqr *  move_speed_factor)) * delta
		if selected_card.position.distance_to(selected_target_pos)  < speed:
			selected_card.position = selected_target_pos
		else:
			selected_card.position = selected_card.position.move_toward(selected_target_pos, speed)
		var percent_there = selected_card.position.distance_to(selected_target_pos) / selected_start_pos.distance_to(selected_target_pos)
		selected_card.fade = max(selected_card.fade, 1-percent_there)
		hint_box.modulate.a = max(hint_box.modulate.a, percent_there)
		confirm_box.modulate.a = max(confirm_box.modulate.a, percent_there)
		if selected_card_name != "Soldier":
			soldier_card.fade = min(soldier_card.fade, percent_there)
		if selected_card_name != "Rogue":
			rogue_card.fade = min(rogue_card.fade, percent_there)
		if selected_card_name != "Mage":
			mage_card.fade = min(mage_card.fade, percent_there)
		if selected_card_name != "Priest":
			priest_card.fade = min(priest_card.fade, percent_there)
			
	if deselected_card:
		var dist_sqr = deselected_card.position.distance_squared_to(deselected_target_pos)
		var speed = min(max_move_speed,max(min_move_speed, dist_sqr *  move_speed_factor)) * delta
		if deselected_card.position.distance_to(deselected_target_pos)  < speed:
			selected_card_parent.remove_child(deselected_card)
			deselected_org_parent_container.add_child(deselected_card)
			deselected_card.position = Vector2.ZERO
			deselected_card_name = null
			deselected_card = null
			deselected_org_parent_container = null
		else:
			deselected_card.position = deselected_card.position.move_toward(deselected_target_pos, speed)
		if deselected_card:
			var percent_there = deselected_card.position.distance_to(deselected_target_pos) / deselected_start_pos.distance_to(deselected_target_pos)
			if selected_card:
				deselected_card.fade =percent_there
			else:
				hint_box.modulate.a = min(hint_box.modulate.a, percent_there)
				confirm_box.modulate.a = min(confirm_box.modulate.a, percent_there)
				soldier_card.fade = max(soldier_card.fade, 1 - percent_there)
				rogue_card.fade = max(rogue_card.fade, 1 - percent_there)
				mage_card.fade = max(mage_card.fade, 1 - percent_there)
				priest_card.fade = max(priest_card.fade, 1 - percent_there)

func on_card_confirmed():
	print("Pressed")
	if selected_card_name:
		character_selected.emit(selected_card_name)
		

func on_card_selected(name:String):
	print("Selecting Card: %s | cur: %s | de: %s" % [name, selected_card_name, deselected_card_name])
	if selected_card_name:
		if name != selected_card_name and !deselected_card_name:
			deselect_card()
		else:
			return
	selected_card_name = name
	yes_button.disabled = false
	no_button.disabled = false
	if selected_card_name == "Soldier": selected_card = soldier_card
	if selected_card_name == "Rogue": selected_card = rogue_card
	if selected_card_name == "Mage": selected_card = mage_card
	if selected_card_name == "Priest": selected_card = priest_card
	confirm_box_label.text = "Start as the %s?" % [selected_card_name]
	selected_start_pos = selected_card.global_position
	var target_x = (selected_card_parent.size.x - selected_card.size.x) / 2
	var target_y = (selected_card_parent.size.y - selected_card.size.y) / 2
	selected_target_pos = Vector2(target_x, target_y)
	selected_org_parent_container = selected_card.get_parent()
	selected_org_parent_container.remove_child(selected_card)
	selected_card_parent.add_child(selected_card)
	selected_card.global_position = selected_start_pos
	print("Selected Card: %s" % [selected_card_name])
	
func deselect_card():
	if !selected_card:
		return
	yes_button.disabled = true
	no_button.disabled = true
	deselected_card_name = selected_card_name
	deselected_card = selected_card
	deselected_target_pos = selected_start_pos
	deselected_start_pos = selected_target_pos
	deselected_org_parent_container = selected_org_parent_container
	selected_card_name = null
	selected_card = null
	selected_org_parent_container = null
	print("Delected Card: %s" % [deselected_card_name])
