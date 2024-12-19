class_name PageSlotButton
extends Control

var item_key:String
@export var highlight:TextureRect
@export var icon:TextureRect
@export var button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_key(actor:BaseActor, key):
	if key:
		var page:BasePageItem = ItemLibrary.get_item(key)
		if page:
			if page.get_action_key():
				var action = ActionLibrary.get_action(page.get_action_key())
				if action.use_weapon_icon():
					icon.texture = action.get_large_page_icon(actor)
					actor.equipment_changed.connect(_on_equipment_changed.bind(actor.Id, action.ActionKey))
				else:
					var icon_texture = page.get_large_icon()
					icon.texture = icon_texture
			else:
				var icon_texture = page.get_large_icon()
				icon.texture = icon_texture
		else:
			icon.texture = SpriteCache._get_no_sprite()

func _on_equipment_changed(actor_id, action_key):
	var actor = ActorLibrary.get_actor(actor_id)
	var action = ActionLibrary.get_action(action_key)
	icon.texture = action.get_large_page_icon(actor)

func show_highlight():
	highlight.show()

func hide_highlight():
	highlight.hide()
