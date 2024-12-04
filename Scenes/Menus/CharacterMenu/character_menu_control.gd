class_name CharacterMenuControl
extends Control

@export var equipment_page:EquipmentPageControl
@export var page_page:PagePageControl
@export var bag_page:BagPageControl

@export var scale_control:Control
@export var inventory_container:InventoryContainer
@export var close_button:Button
@export var tab_equipment_button:Button
@export var tab_pages_button:Button
@export var tab_bag_button:Button

var _actor:BaseActor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(close_menu)
	tab_equipment_button.pressed.connect(on_tab_pressed.bind("Equipment"))
	tab_pages_button.pressed.connect(on_tab_pressed.bind("Pages"))
	tab_bag_button.pressed.connect(on_tab_pressed.bind("Bag"))
	#if _actor == null:
		#ActorLibrary.new()
		#var test = ActorLibrary.get_actor("TestActor_ID")
		#set_actor(test)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_actor(actor:BaseActor):
	equipment_page.set_actor(actor)
	page_page.set_actor(actor)
	bag_page.set_actor(actor)

func close_menu():
	self.queue_free()

func on_tab_pressed(tab_name:String):
	if tab_name == "Equipment":
		equipment_page.visible = true
		page_page.visible = false
		bag_page.visible = false
	if tab_name == "Pages":
		equipment_page.visible = false
		page_page.visible = true
		bag_page.visible = false
	if tab_name == "Bag":
		equipment_page.visible = false
		page_page.visible = false
		bag_page.visible = true
