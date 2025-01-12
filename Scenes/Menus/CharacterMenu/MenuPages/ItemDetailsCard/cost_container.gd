class_name PageDetailsCard_CostContaienr
extends HBoxContainer

@export var count_val_label:Label
@export var cost_val_label:Label
@export var clip_val_label:Label
@export var ammo_icon_rect:TextureRect

@export var gen_ammo_icon:Texture2D
@export var phy_ammo_icon:Texture2D
@export var mag_ammo_icon:Texture2D
@export var abn_ammo_icon:Texture2D

func set_data(ammo_data:Dictionary):
	var ammo_type = AmmoItem.AmmoTypes.get(ammo_data.get("AmmoType", "Gen"))
	if ammo_type == AmmoItem.AmmoTypes.Phy:
		ammo_icon_rect.texture = phy_ammo_icon
	elif ammo_type == AmmoItem.AmmoTypes.Mag:
		ammo_icon_rect.texture = mag_ammo_icon
	elif ammo_type == AmmoItem.AmmoTypes.Abn:
		ammo_icon_rect.texture = abn_ammo_icon
	var clip = ammo_data.get("Clip", 1)
	var cost = ammo_data.get("Cost", 1)
	var count = floori(clip  / cost)
	cost_val_label.text = str(cost)
	clip_val_label.text = str(clip)
	count_val_label.text = str(count)
