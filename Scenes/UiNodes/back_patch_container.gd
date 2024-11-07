@tool
class_name BackPatchContainer
extends Container

static var global_refresh_list:Array = []

const LOGGING = false

@export var global_refresh:bool = false
@export var refresh:bool = false
@export var background:NinePatchRect
@export var inner_container:BoxContainer
@export var margin_override:int = -1

@export var force_fill_x:bool = false
@export var force_fill_y:bool = false
@export var force_dimintions:Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if refresh:
		resize_self_around_child()
		refresh = false
	
	if global_refresh:
		global_refresh_list.clear()
		global_refresh = false
	if !global_refresh_list.has(self.name):
		resize_self_around_child()
		global_refresh_list.append(self.name)
	pass

func _notification(what: int) -> void:
	#var ignore_list = [17]
	#if not ignore_list.has(what):
		#print("%s: notification: %s" % [self.name, what])
	if what == NOTIFICATION_PRE_SORT_CHILDREN:
		self.custom_minimum_size = Vector2i.ZERO
	if what == NOTIFICATION_SORT_CHILDREN or what == NOTIFICATION_RESIZED:
		#if not Engine.is_editor_hint():
		resize_self_around_child()

func _is_in_container():
	var parent = get_parent_control()
	if parent:
		return true
	return false

func resize_self_around_child():
	if LOGGING: print("--------------- Begin %s Resize ---------------" % [self.name])
	if not background or not inner_container:
		return
	
	var margin_val:int = background.patch_margin_top
	if margin_override >= 0:
		margin_val = margin_override
	
	var fit_to_current_x = false
	var fit_to_current_y = false
	if _is_in_container():
		if LOGGING: print("Horz:%s | Vert:%s" % [size_flags_horizontal, size_flags_vertical])
		if size_flags_horizontal == SIZE_EXPAND_FILL or force_fill_x:# or size_flags_horizontal == SIZE_FILL:
			fit_to_current_x = true
		if size_flags_vertical == SIZE_EXPAND_FILL or force_fill_y:# or size_flags_horizontal == SIZE_FILL:
			fit_to_current_y = true
	else:
		if LOGGING: print("No Container")
	
	var min_inner_size = inner_container.get_minimum_size()
	if LOGGING: print("Min Inner Size: %s | Cust Min Inner Size: %s" % [min_inner_size, inner_container.custom_minimum_size])
	min_inner_size.x = max(inner_container.custom_minimum_size.x, min_inner_size.x)
	min_inner_size.y = max(inner_container.custom_minimum_size.y, min_inner_size.y)
	
	var self_size = self.size
	var self_custom_min = Vector2(margin_val * 2, margin_val * 2)
	if LOGGING: print("Self Size: " + str(self_size))
	var inner_size = min_inner_size
	if fit_to_current_x:
		if LOGGING: print("Fit X")
		inner_size.x = self.size.x - (2 * margin_val)
	else:
		self_custom_min.x = min_inner_size.x + (2 * margin_val)
		self_size.x = self_custom_min.x
	if fit_to_current_y:
		if LOGGING: print("Fit Y")
		inner_size.y = self.size.y - (2 * margin_val)
	else:
		self_custom_min.y = min_inner_size.y + (2 * margin_val)
		self_size.y = self_custom_min.y
	
	if force_dimintions != Vector2i.ZERO:
		if force_dimintions.x > 0:
			self_size.x = force_dimintions.x
			self_custom_min.x = force_dimintions.x
			inner_size.x = force_dimintions.x - (2 * margin_val)
		if force_dimintions.y > 0:
			self_size.y = force_dimintions.y
			self_custom_min.y = force_dimintions.y
			inner_size.y = force_dimintions.y - (2 * margin_val)
	
	self.set_size(self_size)
	self.custom_minimum_size = self_custom_min
	background.size = self.size
	inner_container.set_size(inner_size)
	inner_container.position = Vector2(margin_val, margin_val)
	if LOGGING: print("SelfSize: %s | InnerSize: %s" % [self_size, inner_size])
	if LOGGING: print("----------------------- DONE -----------------------")
	
	var child_index = 0
	for child in get_children():
		if child is Control and child != background and child != inner_container:
			fit_child_in_rect(child, Rect2(Vector2(), self.size))
		child_index += 1
