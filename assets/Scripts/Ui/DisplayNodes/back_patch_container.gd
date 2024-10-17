@tool
class_name BackPatchContainer
extends Container

@export var refresh:bool = false
@export var left_margins_offset:int = 0
@export var right_margins_offset:int = 0
@export var top_margins_offset:int = 0
@export var bot_margins_offset:int = 0
@export var background_index:int = 0
@export var inner_container_index:int = 1

func get_background()->NinePatchRect:
	var child = get_child(background_index)
	if child is NinePatchRect:
		return child
	printerr("BackPatchContainer: No Background found.")
	return null
	
func get_inner_container()->Container:
	var child = get_child(inner_container_index)
	if child is Container:
		return child
	printerr("BackPatchContainer: No Inner Container found.")
	return null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if refresh:
		self.custom_minimum_size = Vector2i.ZERO
		resize_self_around_child()
		refresh = false
	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		resize_self_around_child()
	#super(what)

func resize_self_around_child():
	var background = get_background()
	var inner_container = get_inner_container()
	if not background or not inner_container:
		return
	var base_size = inner_container.get_minimum_size()
	var outer_size = Vector2i()
	outer_size.x = base_size.x + background.patch_margin_left + background.patch_margin_right + left_margins_offset + right_margins_offset
	outer_size.y = base_size.y + background.patch_margin_top + background.patch_margin_bottom + top_margins_offset + bot_margins_offset
	
	print("BaseSize: %s | OuterSize: %s" %[base_size, outer_size] )
	self.custom_minimum_size = outer_size
	background.custom_minimum_size = outer_size
	background.set_size(outer_size)
	inner_container.position = Vector2i(background.patch_margin_left, background.patch_margin_top)
	inner_container.set_size(base_size)
	
	var child_index = 0
	for child in get_children():
		if child_index != background_index and child_index != inner_container_index:
			fit_child_in_rect(child, Rect2(Vector2(), outer_size))
		child_index += 1
