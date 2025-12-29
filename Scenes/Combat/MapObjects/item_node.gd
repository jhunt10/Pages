class_name ItemNode
extends Node2D

@export var item_sprite:Sprite2D

var _item:BaseItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_item(item:BaseItem):
	self._item = item
	if item is BasePageItem:
		item_sprite.texture = SpriteCache.get_sprite("res://ObjectDefs/Items/Supplies/PageItem/PageDropItem_Icon.png")
	else:
		item_sprite.texture = item.get_small_icon()
	#item.map_pos_set.connect(on_map_pos_change)

func on_map_pos_change(map_pos:MapPos):
	if map_pos == null:
		self.queue_free()
