class_name PagePageControl
extends Control

@export var name_label:Label
@export var book_icon:TextureRect
@export var premade_sub_container:SubBookContainer
@export var sub_container:FlowContainer
@export var slot_width:int 
@export var scroll_dots:HTabsControls

var sub_book_pages:Array = []
var max_hight = 278

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_sub_container.visible = false
	scroll_dots.selected_index_changed.connect(show_page)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_actor(actor:BaseActor):
	var ques = actor.equipment.get_equipt_items_of_slot_type("Que")
	if !ques or ques.size() == 0:
		name_label.text = "No Book!"
		return
	elif ques.size() > 1:
		name_label.text = "2 Books?"
		return
	var que:BaseQueEquipment = ques[0]
	name_label.text = que.details.display_name
	book_icon.texture = que.get_large_icon()
	
	var current_hight = 0
	var current_width = 0
	var current_page_index = 0
	sub_book_pages.clear()
	sub_book_pages.append([])
	
	var tags = actor.pages._page_tagged_slots
	for tag in tags.keys():
		var slots = tags[tag]
		var sub = _create_sub_container(tag, slots)
		
		var estimated_hight = sub.estimate_hight()
		
		if current_width > 0 and current_width + slots.size() <= 4:
			current_width += slots.size()
			sub_book_pages[current_page_index].append(sub)
			continue
			
		if current_hight + estimated_hight > max_hight:
			sub_book_pages.append([])
			current_page_index += 1
			current_width = 0
			current_hight = estimated_hight
		else:
			current_hight += estimated_hight
			if slots.size() < 4:
				current_width += slots.size()
		sub_book_pages[current_page_index].append(sub)
	show_page(0)
	var page_count = sub_book_pages.size()
	scroll_dots.dot_count = sub_book_pages.size()
	if page_count < 2:
		scroll_dots.hide()
	else:
		scroll_dots.show()

func show_page(index):
	for sub_index in range(sub_book_pages.size()):
		var subs = sub_book_pages[sub_index]
		for sub in subs:
			sub.visible = sub_index == index
			print("Setting Page %s Sub Hidde: %s | %s " % [sub_index, sub, sub.visible])
		
func _create_sub_container(tag, slots)->SubBookContainer:
	var new_sub:SubBookContainer = premade_sub_container.duplicate()
	new_sub.set_sub_book_data(tag, slots)
	sub_container.add_child(new_sub)
	return new_sub
