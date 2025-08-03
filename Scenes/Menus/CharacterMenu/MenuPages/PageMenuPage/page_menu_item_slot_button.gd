class_name PageSlotButton
extends BaseCharacterMenu_ItemSlotButton

var item_key:String
@export var frame:TextureRect

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


func set_item(actor:BaseActor, holder:BaseItemHolder, item:BaseItem):
	super(actor, holder, item)
	var page = item as BasePageItem
	if !page:
		return
	if page is PageItemAction:
		if page.use_equipment_icon():
			item_icon_rect.texture = page.get_large_page_icon(actor)
			if not actor.equipment_changed.is_connected(_on_equipment_changed):
				actor.equipment_changed.connect(_on_equipment_changed.bind(actor.Id, page.ItemKey))
	
	

#func set_key(actor:BaseActor, page:BasePageItem):
	##if item.ItemKey == key:
		##return
	#if page:
		#item_key = page.ItemKey
		#if page is PageItemAction:
			#if page.use_equipment_icon():
				#page_icon.texture = page.get_large_page_icon(actor)
				#if not actor.equipment_changed.is_connected(_on_equipment_changed):
					#actor.equipment_changed.connect(_on_equipment_changed.bind(actor.Id, page.ItemKey))
			#else:
				#var icon_texture = page.get_large_icon()
				#page_icon.texture = icon_texture
		#else:
			#page_icon.texture = page.get_large_icon()
		#page_background.texture = page.get_rarity_background()
		#page_icon.show()
		#page_background.show()
		#
		#var valid_state = actor.pages.get_valid_state_of_item(page)
		#if valid_state != BaseItemHolder.ValidStates.Valid:
			#invalid_icon.show()
			#invalid_label.text = BaseItemHolder.ValidStates.keys()[valid_state]
		#else:
			#invalid_icon.hide()
			#invalid_label.text = ''
		#
		##var cant_equip_reasons = page.get_cant_use_reasons(actor)
		##if cant_equip_reasons.size() > 0:
			##invalid_label.text = ItemHelper.cant_equip_reasons_to_string(cant_equip_reasons)
			##invalid_icon.show()
		##else:
			##invalid_icon.hide()
	#else:
		#item_key = ''
		#invalid_icon.hide()
		#page_icon.hide()
		#page_background.hide()# = SpriteCache._get_no_sprite()

## Specifically for Action Pages with use_equipment_icon
func _on_equipment_changed():
	var page = ItemLibrary.get_item(item_id, false)
	if page:
		item_icon_rect.texture = page.get_large_page_icon(parent_sub_menu._actor)
