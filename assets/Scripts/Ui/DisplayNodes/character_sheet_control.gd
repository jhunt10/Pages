class_name CharacterSheetControl
extends Control

@onready var character_portrait_rect:TextureRect = $Background/CharacterPortraitRect/TextureRect
@onready var character_name_label:Label = $Background/NameLabelBox/HBoxContainer/NameLabel
@onready var character_level_label:Label = $Background/NameLabelBox/HBoxContainer/LevelLabel
@onready var edit_name_button:TextureButton = $Background/NameLabelBox/HBoxContainer/EditButton
@onready var character_name_line_edit:LineEdit = $Background/NameLabelBox/HBoxContainer/NameLineEdit

@onready var stat_box_container:VBoxContainer = $Background/StatBox/ScrollContainer/VBoxContainer
@onready var stat_desc_box_prefab:HBoxContainer = $Background/StatBox/ScrollContainer/VBoxContainer/StatDescrBox
@onready var stat_box_seperator_prefab = $Background/StatBox/ScrollContainer/VBoxContainer/HSeparator

@onready var page_container:HBoxContainer = $Background/PagesBox/HBoxContainer
@onready var page_prefab = $Background/PagesBox/HBoxContainer/PageSlot
@onready var page_description_control:PageDescControl = $Background/PageDescBox

var stat_desc_boxes:Array = []
var stat_desc_seprs:Array = []
var page_slots:Array = []

var _editing_actor:BaseActor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	edit_name_button.pressed.connect(_on_edit_name_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	stat_desc_box_prefab.visible = false
	stat_box_seperator_prefab.visible = false
	page_prefab.visible = false
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE:
		self.close_menu()

func close_menu():
	ActorLibrary.save_actors()
	self.queue_free()

func set_actor(actor:BaseActor):
	_editing_actor = actor
	character_portrait_rect.texture = _editing_actor.get_default_sprite()
	character_name_label.text = _editing_actor.DisplayName
	character_level_label.text = "Lv " + str(_editing_actor.stats.level)
	_build_stat_box(_editing_actor)
	_build_page_list(_editing_actor)

func _build_stat_box(actor:BaseActor):
	for stat_key in actor.stats._base_stats.keys():
		if stat_desc_boxes.size() > 0:
			var seperator = stat_box_seperator_prefab.duplicate()
			stat_box_container.add_child(seperator)
			stat_desc_seprs.append(seperator)
		var stat_box:HBoxContainer = stat_desc_box_prefab.duplicate()
		stat_box.get_child(0).text = stat_key
		stat_box.get_child(2).text = str(actor.stats.get_stat(stat_key))
		stat_box.visible = true
		stat_box_container.add_child(stat_box)
		stat_desc_boxes.append(stat_box)

func _build_page_list(actor:BaseActor):
	var que_data = actor.get_que_data()
	for page_key in que_data['ActionList']:
		var page = MainRootNode.action_library.get_action(page_key)
		if !page:
			printerr("CharacterSheetControl._build_page_list: Failed to find Page with ActionKey: '%s'." % [page_key])
			continue
		var page_slot:TextureButton = page_prefab.duplicate()
		var page_image:TextureRect = page_slot.get_child(0)
		page_slot.mouse_entered.connect(page_description_control.set_page.bind(page))
		page_image.texture = page.get_large_sprite()
		page_container.add_child(page_slot)
		page_slots.append(page_slot)

func _on_edit_name_pressed():
	if character_name_line_edit.visible:
		_editing_actor.DisplayName = character_name_line_edit.text
		character_name_line_edit.visible = false
		character_name_label.visible = true
		character_name_label.text = _editing_actor.DisplayName
	else:
		character_name_line_edit.text = _editing_actor.DisplayName
		character_name_line_edit.visible = true
		character_name_label.visible = false
