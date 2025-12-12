class_name GameUnlockScreen
extends Control


@export var new_actor_name_label:Label
@export var new_actor_icon:TextureRect
@export var camp_button:Button

func _ready() -> void:
	self.hide()
	camp_button.pressed.connect(_on_camp_button)

func show_game_result():
	var story_index = StoryState._story_stage_index
	var new_actor_key = ""
	match story_index:
		0: new_actor_key = "RogueTemplate"
		1: new_actor_key = "PriestTemplate"
		2: new_actor_key = "MageTemplate"
	if new_actor_key:
		var new_actor:BaseActor = StoryState.add_actor_to_party(new_actor_key)
		new_actor_name_label.text = new_actor.get_display_name()
		new_actor_icon.texture = new_actor.get_large_icon()
	StoryState._story_stage_index += 1
	self.show()
	

func _on_camp_button():
	MainRootNode.Instance.open_camp_menu()
