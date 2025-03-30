class_name ZoneTrapNode
extends ZoneNode

@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var base_sprite:Sprite2D = $BaseSprite2D
@onready var glow_sprite:Sprite2D = $BaseSprite2D

func _build_zone_area():
	self.visible = true
	var texture = _zone.get_zone_texture()
	if texture:
		base_sprite.texture = texture
		glow_sprite.texture = texture
	#tile_sprite.hide()
	#area_tile_map.hide()

func start_arm_animation():
	animation_player.play("arm_animation")
	animation_player.queue("idle_animation")
