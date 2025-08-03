class_name EquipmentSlotButton
extends BaseCharacterMenu_ItemSlotButton

var default_icons_paths:Dictionary = {
	"PageBook": "res://assets/Sprites/UI/CharacterEdit/BookSlot.png",
	"SupplyBag": "res://assets/Sprites/UI/CharacterEdit/BagSlot.png",
	"Hands": "res://assets/Sprites/UI/CharacterEdit/MainHandSlot.png",
	"Hands:1": "res://assets/Sprites/UI/CharacterEdit/OffHandSlot.png",
	"Apparel:Head": "res://assets/Sprites/UI/CharacterEdit/HeadSlot.png",
	"Apparel:Body": "res://assets/Sprites/UI/CharacterEdit/BodySlot.png",
	"Apparel:Feet": "res://assets/Sprites/UI/CharacterEdit/BootSlot.png",
	"Trinket": "res://assets/Sprites/UI/CharacterEdit/TrinketSlot.png",
}

var item_key:String
var _slot_key:String
var is_off_hand:bool=false
func _ready() -> void:
	super()
	
func disable_slot():
	self.button.hide()
	self.default_icon_rect.hide()
	self.item_icon_rect.hide()
	self.valid_state_icon.hide()

func enable_slot():
	self.button.show()
	self.default_icon_rect.show()
	self.item_icon_rect.show()

func set_slot_set_key(slot_key:String, is_offhand:bool):
	_slot_key = slot_key
	if default_icon_rect:
		if is_offhand:
			default_icon_rect.texture = SpriteCache.get_sprite(default_icons_paths["Hands:1"])
			is_off_hand = true
		elif default_icons_paths.keys().has(slot_key):
			default_icon_rect.texture = SpriteCache.get_sprite(default_icons_paths[slot_key])
		
func set_item(actor:BaseActor, holder:BaseItemHolder, item:BaseItem):
	super(actor, holder, item)
	if is_off_hand:
		if item == null:
			if actor.equipment.is_two_handing():
				var primary_weapon = actor.equipment.get_primary_weapon()
				self.item_icon_rect.texture = primary_weapon.get_large_icon()
				#self.item_icon_rect.modulate = Color(1,1,1,0.6)
				self.item_icon_rect.show()
				self.default_icon_rect.hide()
	if _slot_key == "PageBook":
		if item == null:
			valid_state_icon.show()
			valid_state_label.text = "PageBook is Required"
		#else:
			#self.item_icon_rect.modulate = Color(1,1,1,1)
#
### Specifically for Action Pages with use_equipment_icon
#func _on_equipment_changed():
	#var page = ItemLibrary.get_item(item_id, false)
	#if page:
		#item_icon_rect.texture = page.get_large_page_icon(parent_sub_menu._actor)
