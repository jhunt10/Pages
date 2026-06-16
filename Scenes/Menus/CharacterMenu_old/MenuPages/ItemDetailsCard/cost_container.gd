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

func set_data(page:PageItemAction, _actor:BaseActor):
	var ammo_type = page.get_ammo_type()
	if ammo_type == AmmoItem.AmmoTypes.Phy:
		ammo_icon_rect.texture = phy_ammo_icon
	elif ammo_type == AmmoItem.AmmoTypes.Mag:
		ammo_icon_rect.texture = mag_ammo_icon
	elif ammo_type == AmmoItem.AmmoTypes.Abn:
		ammo_icon_rect.texture = abn_ammo_icon
		
	var cost = page.get_ammo_cost_per_use()
	var clip = page.get_ammo_max()
	count_val_label.text = str(floori(clip/cost))
