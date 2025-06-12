class_name PageSlotButton
extends Control

var item_key:String
@export var highlight:TextureRect
@export var page_icon:TextureRect
@export var page_background:TextureRect
@export var frame:TextureRect
@export var button:Button

@export var invalid_icon:TextureRect
@export var invalid_label:Label
@export var invalid_button:Button

@export var frame_texture:Texture2D
@export var clipped_frame_texture:Texture2D

var is_clipped:bool:
	set(val):
		is_clipped = val
		if frame:
			if is_clipped: frame.texture = clipped_frame_texture
			else: frame.texture = frame_texture

func _ready() -> void:
	is_clipped = is_clipped
	invalid_button.mouse_entered.connect(show_invaid_label)
	invalid_button.mouse_exited.connect(hide_invaid_label)
	invalid_label.hide()

func set_key(actor:BaseActor, key):
	item_key = key
	if key:
		var page = ItemLibrary.get_item(key)
		if page is PageItemAction:
			if page.use_equipment_icon():
				page_icon.texture = page.get_large_page_icon(actor)
				actor.equipment_changed.connect(_on_equipment_changed.bind(actor.Id, page.ItemKey))
			else:
				var icon_texture = page.get_large_icon()
				page_icon.texture = icon_texture
		else:
			page_icon.texture = page.get_large_icon()
		page_background.texture = page.get_rarity_background()
		var cant_equip_reasons = page.get_cant_use_reasons(actor)
		if cant_equip_reasons.size() > 0:
			invalid_label.text = ItemHelper.cant_equip_reasons_to_string(cant_equip_reasons)
			invalid_icon.show()
		else:
			invalid_icon.hide()
	else:
		invalid_icon.hide()
		page_icon.hide()
		page_background.hide()# = SpriteCache._get_no_sprite()

func _on_equipment_changed(actor_id, action_key):
	var actor = ActorLibrary.get_actor(actor_id)
	var page = ItemLibrary.get_item(item_key)
	page_icon.texture = page.get_large_page_icon(actor)

func show_highlight():
	highlight.show()

func hide_highlight():
	highlight.hide()

func show_invaid_label():
	invalid_label.show()

func hide_invaid_label():
	invalid_label.hide()
