class_name SkillTreeNode
extends Control

enum SkillNodeStates {
	Disabled, # Can not be unlocked  
	Avalible, # Could be unlocked
	Active, # Is unlocked
	
	}
	
signal node_button_down(skill_node_key:String, args:Dictionary)
signal node_button_up(skill_node_key:String, args:Dictionary)

@export var background_rect:TextureRect
@export var icon_rect:TextureRect
@export var button:Button
@export var invalid_icon:TextureRect

@export var is_node_unlocked:bool
@export var can_node_unlock:bool

@export var disabled_texture:Texture2D
@export var avalible_texture:Texture2D
@export var disabled_clipped_texture:Texture2D
@export var avalible_clipped_texture:Texture2D

@export var soldier_background:Texture2D
@export var rogue_background:Texture2D
@export var priest_background:Texture2D
@export var mage_background:Texture2D

var _skill_node_key:String
var _index_data:Dictionary
var _page_id:String
var page_icon_texture:Texture2D
var page_background_texture:Texture2D
var grey_page_icon_texture:Texture2D
var grey_page_background_texture:Texture2D
var is_passive:bool

func _ready() -> void:
	self.button.mouse_entered.connect(on_mouse_enter)
	self.button.mouse_exited.connect(on_mouse_exit)
	self.button.button_down.connect(on_button_down)
	self.button.button_up.connect(on_button_up)

func set_skill_node_data(node_data:Dictionary, index_data:Dictionary={}):
	_skill_node_key = node_data.get("SkillNodeKey")
	_index_data = index_data
	if node_data.has("PageKey"):
		_page_id = node_data.get("PageKey")
	if node_data.has("Pages"):
		var index = index_data.get("Index", 0)
		_page_id = node_data.get("Pages", [])[index]
	var page = ItemLibrary.get_item(_page_id)
	if !page:
		printerr("SkillNode: Failed to find Page with ItemId '%s'." %[_page_id])
		return
	is_passive = page is PageItemPassive
	page_icon_texture = page.get_large_icon()
	page_background_texture = page.get_rarity_background()
	grey_page_icon_texture = get_black_and_white_texture(page_icon_texture)
	grey_page_background_texture = get_black_and_white_texture(page_background_texture)

func set_page(page_id:String):
	self._page_id = page_id
	var page = ItemLibrary.get_item(page_id)
	if !page:
		printerr("SkillNode: Failed to find Page with ItemId '%s'." %[page_id])
		return
	page_icon_texture = page.get_large_icon()
	page_background_texture = page.get_rarity_background()
	grey_page_icon_texture = get_black_and_white_texture(page_icon_texture)
	grey_page_background_texture = get_black_and_white_texture(page_background_texture)
	
	var out_line_rect:TextureRect = $Control/Outline
	if out_line_rect:
		out_line_rect.hide()

func set_unlock_state( is_unlocked:bool, can_unlock:bool):
	var _highlight_rect:TextureRect = $Control/Highlight
	var _icon_rect:TextureRect = $Control/Icon
	if is_unlocked:
		is_node_unlocked = true
		can_node_unlock = false 
		background_rect.texture = page_background_texture
		_icon_rect.texture = page_icon_texture
		_highlight_rect.hide()
		_highlight_rect.modulate = Color.WEB_GREEN
	elif can_unlock:
		is_node_unlocked = false
		can_node_unlock = true 
		if is_passive:
			background_rect.texture = avalible_clipped_texture
		else:
			background_rect.texture = avalible_texture
		_icon_rect.texture = page_icon_texture
		#_highlight_rect.show()
		#_highlight_rect.modulate = Color.WEB_GREEN
	else:
		is_node_unlocked = false
		can_node_unlock = false 
		if is_passive:
			background_rect.texture = disabled_clipped_texture
		else:
			background_rect.texture = disabled_texture
		_icon_rect.texture = grey_page_icon_texture
		_highlight_rect.hide()
		_highlight_rect.modulate = Color.WHITE


func on_mouse_enter():
	if can_node_unlock:
		var out_line_rect:TextureRect = $Control/Outline
		out_line_rect.show()
func on_mouse_exit():
	var out_line_rect:TextureRect = $Control/Outline
	out_line_rect.hide()

func on_button_down():
	node_button_down.emit(_skill_node_key, _index_data)

func on_button_up():
	node_button_up.emit(_skill_node_key, _index_data)

func get_black_and_white_texture(org_texture:Texture2D)->Texture2D:
	var org_image = org_texture.get_image()
	var new_image = Image.create(org_image.get_width(), org_image.get_height(), false, org_image.get_format())
	new_image.decompress()
	for y in org_image.get_size().y:
		for x in org_image.get_size().x:
			var color = org_image.get_pixel(x, y)
			#var max_val = max(color.r, color.b, color.g)
			#var min_val = min(color.r, color.b, color.g)
			var value = (color.r + color.b + color.g) / 3.0
			var new_color = Color(value, value, value, color.a)
			new_image.set_pixel(x, y, new_color)
	var new_port = ImageTexture.create_from_image(new_image)
	return new_port
