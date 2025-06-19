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

func set_data(page:PageItemAction, actor:BaseActor):
	if actor and actor.pages.has_item(page.Id):
		var cost = actor.Que.get_page_ammo_cost_per_use(page.ActionKey)
		var clip = actor.Que.get_page_ammo_max_clip(page.ActionKey)
		cost_val_label.text = str(cost)
		clip_val_label.text = str(clip)
		count_val_label.text = str(floori(clip/cost))
	else:
		var ammo_data = page.get_ammo_data()
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
