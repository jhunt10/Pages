class_name DamageEffectNode
extends Node2D

const MAX_OFFSET = 12

static var veffects_sprites:Dictionary = {
	"Slash": {
		"Sprite":"res://assets/Sprites/VEffects/SlashEffect.png",
		"MaxOffset": 0
		},
	"Shot": {
		"Sprite":"res://assets/Sprites/VEffects/ShotEffect.png",
		"MaxOffset": 12
		},
	"Slam": {
		"Sprite":"res://assets/Sprites/VEffects/SlamEffect.png",
		"MaxOffset": 0
		},
	"Fire": {
		"Sprite":"res://assets/Sprites/VEffects/FireEffect.png",
		"MaxOffset": 0
		},
}

@onready var sprite:Sprite2D = $Sprite
@onready var animation:AnimationPlayer = $Sprite/AnimationPlayer

var flash_number:int = -1
var actor_node:ActorNode
var veffect_key:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var effect_data = veffects_sprites.get(veffect_key, null)
	if effect_data:
		sprite.texture = load(effect_data["Sprite"])
		if effect_data["MaxOffset"] > 0:
			var x = MAX_OFFSET - (randi() % (effect_data["MaxOffset"] * 2))
			var y = MAX_OFFSET - (randi() % (effect_data["MaxOffset"] * 2))
			sprite.position = Vector2i(x, y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not animation.is_playing():
		self.queue_free()
		#actor_node.play_shake()
		if self.flash_number > -1:
			CombatRootControl.Instance.create_flash_text(actor_node.Actor, "-"+str(flash_number), Color.RED)
	pass

func set_props(veffect_key:String, actor:ActorNode, flash_number:int = -1, max_offset=MAX_OFFSET):
	self.flash_number = flash_number
	self.actor_node = actor
	self.veffect_key = veffect_key
	
