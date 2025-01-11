@tool
class_name QueInputButtonControl
extends Control

enum Rarity {Common, Uncommon, Rare, Epic}

@export var rarity:Rarity:
	set(val):
		rarity = val
		if background_texture:
			if rarity == Rarity.Common: background_texture.texture = common_texture
			if rarity == Rarity.Uncommon: background_texture.texture = uncommon_texture
			if rarity == Rarity.Rare: background_texture.texture = rare_texture
			if rarity == Rarity.Epic: background_texture.texture = epic_texture
@export var button:Button
@export var background_texture:TextureRect
@export var page_icon_texture:TextureRect
@export var ammo_display:PageAmmoBar

@export var common_texture:Texture2D
@export var uncommon_texture:Texture2D
@export var rare_texture:Texture2D
@export var epic_texture:Texture2D

var action_key:String

func set_page(actor:BaseActor, action:BaseAction):
	action_key = action.ActionKey
	page_icon_texture.texture = action.get_large_page_icon(actor)
	var ammo_data = action.get_ammo_data()
	if !ammo_data:
		ammo_display.hide()
	else:
		ammo_display.clip_val = ammo_data.get("Clip")
		ammo_display.cost_val = ammo_data.get("Cost")
		var ammo_val = actor.Que.get_page_ammo(action.ActionKey)
		ammo_display.current_val = ammo_data.get("Clip")
