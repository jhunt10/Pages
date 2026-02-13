class_name ActorDetailsCard
extends BoxContainer


@export var icon_rect:TextureRect
@export var actor_node_parent:Node2D
@export var actor_node:BaseActorNode
@export var title_label:FitScaleLabel
@export var tags_box:TagBox

@export var xp_label:Label
@export var money_label:Label

@export var strength_label:StatLabelContainer
@export var agility_label:StatLabelContainer
@export var int_label:StatLabelContainer
@export var wisdom_label:StatLabelContainer

@export var health_label:StatLabelContainer
@export var ppr_label:StatLabelContainer
@export var mass_label:StatLabelContainer
@export var speed_label:StatLabelContainer
@export var phy_atk_label:StatLabelContainer
@export var mag_atk_label:StatLabelContainer
@export var armor_label:StatLabelContainer
@export var ward_label:StatLabelContainer
@export var acc_label:StatLabelContainer
@export var eva_label:StatLabelContainer
@export var pot_label:StatLabelContainer
@export var pro_label:StatLabelContainer
@export var description_box:DescriptionBox

@export var resisances_container:ResistContainer
@export var weaknesses_container:ResistContainer

@export var item_drop_entry:ActorDropEntry
@export var item_drop_container:BoxContainer
@export var passive_pages_container:BoxContainer
@export var action_pages_container:BoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_drop_entry.hide()

func set_actor(actor:BaseActor):
	var actor_node_script = actor.get_node_scene_path()
	if not actor_node_script:
		printerr("Failed to find actor node script: " + actor_node_script)
		if actor_node:
			actor_node.hide()
	else:
		var script = load(actor_node_script)
		var new_node = script.instantiate()
		actor_node_parent.add_child(new_node)
		actor_node.queue_free()
		actor_node = new_node
		actor_node.set_actor(actor)
		# Dumb Hack
		if not actor_node is LeverActorNode:
			actor_node.position = Vector2(0,8)
	icon_rect.texture = actor.get_large_icon()
	title_label.text = actor.get_display_name()
	
	var tags = actor.get_tags()
	tags_box.set_tags(tags)
	
	if actor.is_player:
		money_label.hide()
		xp_label.hide()
	else:
		money_label.show()
		xp_label.show()
		money_label.text = str(actor.actor_data.get("MoneyValue", 0))
		xp_label.text = str(actor.actor_data.get("ExpValue", 0))
	
	strength_label.set_stat_values(actor)
	agility_label.set_stat_values(actor)
	int_label.set_stat_values(actor)
	wisdom_label.set_stat_values(actor)
	
	health_label.set_stat_values(actor)
	ppr_label.set_stat_values(actor)
	mass_label.set_stat_values(actor)
	speed_label.set_stat_values(actor)
	phy_atk_label.set_stat_values(actor)
	mag_atk_label.set_stat_values(actor)
	armor_label.set_stat_values(actor)
	ward_label.set_stat_values(actor)
	eva_label.set_stat_values(actor)
	acc_label.set_stat_values(actor)
	pot_label.set_stat_values(actor)
	pro_label.set_stat_values(actor)
	
	var title_page = actor.pages.get_title_page()
	if title_page:
		description_box.set_page_item(title_page, actor)
	else:
		description_box.set_object(actor._def, actor, actor)
	
	resisances_container.set_values(actor)
	weaknesses_container.set_values(actor)
	
	for child in item_drop_container.get_children():
		child.queue_free()
	var item_drops = actor.actor_data.get("DropItemsSet", {})
	for item_key in item_drops.keys():
		if item_key == "":
			continue
		var new_entry = item_drop_entry.duplicate()
		new_entry.set_item(item_key)
		new_entry.show()
		item_drop_container.add_child(new_entry) 
	
	
	for child in passive_pages_container.get_children():
		child.queue_free()
	for child in action_pages_container.get_children():
		child.queue_free()
	for item_key in  actor.pages.list_passives_keys():
		if item_key == "":
			continue
		var new_entry = item_drop_entry.duplicate()
		new_entry.set_item(item_key)
		new_entry.show()
		passive_pages_container.add_child(new_entry) 
	for item_key in  actor.pages.list_action_keys():
		if item_key == "":
			continue
		var new_entry = item_drop_entry.duplicate()
		new_entry.set_item(item_key)
		new_entry.show()
		action_pages_container.add_child(new_entry) 
	
