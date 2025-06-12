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

@export var selection_display:Control
@export var selection_button:Button

var action_key:String

func set_page(actor:BaseActor, action:PageItemAction):
	selection_display.hide()
	action_key = action.ActionKey
	page_icon_texture.texture = action.get_large_page_icon(actor)
	if !action.has_ammo():
		ammo_display.hide()
	else:
		ammo_display.set_ammo_data(actor, action.ActionKey)
		var ammo_val = actor.Que.get_page_ammo_current_value(action.ActionKey)
		ammo_display.current_val = ammo_val
