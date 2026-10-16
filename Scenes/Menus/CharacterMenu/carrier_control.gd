class_name CarrierControl
extends HBoxContainer

@export var rogue_button:TextureButton
@export var priest_button:TextureButton
@export var mage_button:TextureButton

@export var rogue_x_icon:TextureRect
@export var priest_x_icon:TextureRect
@export var mage_x_icon:TextureRect

var _actor
var buttons = [rogue_button, priest_button, mage_button]
var x_icons = [rogue_x_icon, priest_x_icon, mage_x_icon]

func _ready() -> void:
	rogue_button.pressed.connect(_on_button_pressed.bind(1))
	priest_button.pressed.connect(_on_button_pressed.bind(2))
	mage_button.pressed.connect(_on_button_pressed.bind(3))

func sync(actor:BaseActor):
	var players = StoryState.list_party_actors()
	if not actor is CarrierActor or players.size() <= 1:
		_actor = null
		self.hide()
	else:
		_actor = actor
		self.show()
	if !_actor:
		return
	
	if players.size() > 1:
		rogue_button.show()
		if actor.list_carried_actor_ids().has(players[1].Id):
			rogue_x_icon.hide()
		else:
			rogue_x_icon.show()
	else:
		rogue_button.hide()
	
	
	if players.size() > 2 and actor.Id != players[2].Id:
		priest_button.show()
		if actor.list_carried_actor_ids().has(players[2].Id):
			priest_x_icon.hide()
		else:
			priest_x_icon.show()
	else:
		priest_button.hide()
	
	
	if  players.size() > 3:
		mage_button.show()
		if actor.list_carried_actor_ids().has(players[3].Id):
			mage_x_icon.hide()
		else:
			mage_x_icon.show()
	else:
		mage_button.hide()
	
func _on_button_pressed(index:int):
	# Do nothing in combat mod
	if CombatRootControl.Instance and CombatRootControl.is_valid():
		return
	if !_actor:
		return
	var players = StoryState.list_party_actors()
	var other_actor:BaseActor = players[index]
	if _actor.list_carried_actor_ids().has(other_actor.Id):
		_actor.remove_held_actor(other_actor)
	else:
		_actor.add_carried_actor(other_actor)
	self.sync(_actor)
	
	
