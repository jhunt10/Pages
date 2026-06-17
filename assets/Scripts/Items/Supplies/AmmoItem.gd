class_name AmmoItem
extends BaseSupplyItem

enum AmmoTypes {None, Gen, Phy, Mag, Abn, Limit}

func get_ammo_type()->AmmoTypes:
	return AmmoTypes.get(get_load_val("SuppliesData", {}).get("AmmoType", "None"))

func can_reload_page(actor:BaseActor, action:PageItemAction)->bool:
	if not action.has_ammo():
		return false
	var action_ammo_type = action.get_ammo_type()
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
