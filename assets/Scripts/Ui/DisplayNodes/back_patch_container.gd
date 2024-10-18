@tool
class_name BackPatchContainer
extends Container

@export var refresh:bool = false
@export var background:NinePatchRect
@export var inner_container:BoxContainer
@export var fill_x:bool=false
@export var fill_y:bool=false

func get_background()->NinePatchRect:
	if background:
		return background
	printerr("BackPatchContainer '%s': No Background found." % [self.name])
	return null
	
func get_inner_container()->Container:
	if inner_container:
		return inner_container
	printerr("BackPatchContainer '%s': No Inner Container found." % [self.name])
	return null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if refresh:
		refresh = false
		self.custom_minimum_size = Vector2i.ZERO
		resize_self_around_child()
	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		#if not Engine.is_editor_hint():
		resize_self_around_child()
	#super(what)

func resize_self_around_child():
	var background = get_background()
	var inner_container = get_inner_container()
	if not background or not inner_container:
		return
		
	var total_x_margins = background.patch_margin_left + background.patch_margin_right 
	var total_y_margins = background.patch_margin_top + background.patch_margin_bottom
	
	var nat_size = Vector2i(self.size.x - total_x_margins, self.size.y - total_x_margins) 
	if not fill_x:
		nat_size.x = 0
	if not fill_y:
		nat_size.y = 0
	var min_size = inner_container.get_minimum_size()
	var cust_min_size = inner_container.custom_minimum_size
	var base_size = Vector2i(max(min_size.x, cust_min_size.x, nat_size.x), max(min_size.y, cust_min_size.y, nat_size.y))
	var outer_size = Vector2i()
	outer_size.x = base_size.x + total_x_margins
	outer_size.y = base_size.y + total_y_margins
	
	print("BaseSize: %s | OuterSize: %s" %[base_size, outer_size] )
	self.custom_minimum_size = outer_size
	background.custom_minimum_size = outer_size
	background.set_size(outer_size)
	inner_container.position = Vector2i(background.patch_margin_left, background.patch_margin_top)
	inner_container.set_size(base_size)
	
	var child_index = 0
	for child in get_children():
		if child != background and child != inner_container:
			fit_child_in_rect(child, Rect2(Vector2(), outer_size))
		child_index += 1
