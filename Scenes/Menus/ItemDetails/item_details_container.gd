class_name ItemDetailsContainer
extends BoxContainer

@export var icon:TextureRect
@export var icon_background:TextureRect
@export var title_lable:FitScaleLabel
@export var rarity_lable:Label
@export var tag_container:TagsContainer
@export var description_box:RichTextLabel
@export var exit_button:Button
#@export var equip_button:Button
#@export var button_label:Label

@export var weapon_details:WeaponDetailsControl
@export var armor_details:ArmorDetailsControl
@export var action_page_details:ActionDetailsControl
@export var passive_page_details:EffectPageDetailsControl
@export var page_book_details:PageBookDetailsControl
@export var default_details:DefaultItemDetailsControl

var _item_id
var actor_has_item
var _current_card

func set_detail_card_item(actor:BaseActor, item:BaseItem, confirm_button_text:String, disable_confirm:bool=false):
	_item_id = item.Id
	icon_background.texture = item.get_rarity_background()
	icon.texture = item.get_small_icon()
	title_lable.text = item.get_display_name()
	rarity_lable.text = item.get_rarity_string() + " " + item.get_taxonomy_leaf()
	
	tag_container.set_tags(item.get_tags())
	default_details.hide()
	weapon_details.hide()
	armor_details.hide()
	action_page_details.hide()
	passive_page_details.hide()
	page_book_details.hide()
	
	if item is BaseWeaponEquipment:
		var weapon = (item as BaseWeaponEquipment)
		weapon_details.set_weapon(actor, weapon)
		_current_card = weapon_details
		weapon_details.show()
	elif item is BaseApparelEquipment:
		var armor = (item as BaseApparelEquipment)
		armor_details.set_armor(actor, armor)
		_current_card = armor_details
		armor_details.show()
	elif item is BasePageItem:
		var page = (item as BasePageItem)
		if item is PageItemAction:
			action_page_details.set_action(actor, page)
			_current_card = action_page_details
			action_page_details.show()
		else:
			passive_page_details.set_action(actor, page)
			_current_card = passive_page_details
			passive_page_details.show()
			#default_details.set_item(item)
			#default_details.show()
	elif item is BaseQueEquipment:
		page_book_details.set_item(actor, item)
		_current_card = page_book_details
		page_book_details.show()
	else:
		default_details.set_item(item)
		_current_card = default_details
		default_details.show()
	
