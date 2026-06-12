class_name CharacterMenu_ItemSlotButton
extends TextureButton

func set_item(item:BaseItem):
	var default_icon = $DefaultIcon
	var item_icon = $ItemIcon
	var invalid_icon = $InvalidIcon
	invalid_icon.hide()
	if item:
		item_icon.texture = item.get_large_icon()
		item_icon.show()
		default_icon.hide()
		var holding_actor = item.get_holding_actor()
		if holding_actor:
			if holding_actor.items.get_valid_state_of_item(item) == BaseItemHolder.ValidStates.Invalid:
				invalid_icon.show()
	else:
		item_icon.hide()
		default_icon.show()
		
