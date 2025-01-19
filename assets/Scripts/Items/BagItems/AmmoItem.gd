class_name AmmoItem
extends BaseConsumableItem

enum AmmoTypes {Gen, Phy, Mag, Abn}

func get_ammo_type()->AmmoTypes:
	return AmmoTypes.get(get_load_val("AmmoType", "Gen"))

func can_reload_page(actor:BaseActor, action:BaseAction)->bool:
	if not action.has_ammo(actor):
		return false
	var ammo_data = action.get_ammo_data(actor)
	var action_ammo_type = AmmoTypes.get(ammo_data.get("AmmoType", "Gen"))
	var self_ammo_type = get_ammo_type()
	print("Checking Ammo: %s | %s" % [action_ammo_type, self_ammo_type])
	if action_ammo_type == self_ammo_type:
		return true
	if action_ammo_type == AmmoTypes.Gen:
		if self_ammo_type == AmmoTypes.Mag or self_ammo_type == AmmoTypes.Phy:
			return true
	if self_ammo_type == AmmoTypes.Gen:
		if action_ammo_type == AmmoTypes.Mag or action_ammo_type == AmmoTypes.Phy:
			return true
	return false
