class_name SkillTreeNode
extends Control

@export var background_rect:TextureRect
@export var icon_rect:TextureRect
@export var button:Button


@export var is_node_unlocked:bool
@export var can_node_unlock:bool

var _page_id:String
var page_icon_texture:Texture2D
var page_background_texture:Texture2D
var grey_page_icon_texture:Texture2D
var grey_page_background_texture:Texture2D

func _ready() -> void:
	self.button.mouse_entered.connect(on_mouse_enter)
	self.button.mouse_exited.connect(on_mouse_exit)

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
	
	var out_line_rect:TextureRect = $Outline
	out_line_rect.hide()

func set_unlock_state( is_unlocked:bool, can_unlock:bool):
	var _highlight_rect:TextureRect = $Highlight
	var _icon_rect:TextureRect = $Icon
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
		background_rect.texture = grey_page_background_texture
		_icon_rect.texture = grey_page_icon_texture
		_highlight_rect.show()
		_highlight_rect.modulate = Color.SLATE_GRAY
	else:
		is_node_unlocked = false
		can_node_unlock = false 
		background_rect.texture = grey_page_background_texture
		_icon_rect.texture = grey_page_icon_texture
		_highlight_rect.hide()
		_highlight_rect.modulate = Color.WHITE


func on_mouse_enter():
	if can_node_unlock:
		var out_line_rect:TextureRect = $Outline
		out_line_rect.show()
func on_mouse_exit():
	var out_line_rect:TextureRect = $Outline
	out_line_rect.hide()
	

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
