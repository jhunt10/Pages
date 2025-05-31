class_name FlashTextController
extends Control

@onready var premade_label:FlashTextNode = $PremadeDamageLabel

@export var normal_damage_color:Color
@export var blocked_damage_color:Color
@export var crit_damage_color:Color
@export var healing_damage_color:Color
@export var dot_damage_color:Color

var text_nodes:Dictionary = {}

func _ready():
	premade_label.hide()
	#label.text = _text
	#label.add_theme_color_override('font_color', _color)
	pass

func _process(delta):
	pass

func add_flash_text(val:String, flash_text_type:VfxHelper.FlashTextType):
	var new_text:FlashTextNode = premade_label.duplicate()
	new_text.id = str(ResourceUID.create_id())
	
	var color = Color.WHITE
	var font_size = 10
	var outline_size = 4
	var text_value = val
	match flash_text_type:
		VfxHelper.FlashTextType.Normal_Dmg:
			color = normal_damage_color
		
		VfxHelper.FlashTextType.Blocked_Dmg:
			color = blocked_damage_color
		
		VfxHelper.FlashTextType.Crit_Dmg:
			color = crit_damage_color
		
		VfxHelper.FlashTextType.Healing_Dmg:
			color = healing_damage_color
			if not text_value.begins_with("+"):
				text_value = "+" + text_value
			
		
		VfxHelper.FlashTextType.DOT_Dmg:
			color = dot_damage_color
			#font_size = font_size - 1
			outline_size = 2
		
		
	new_text.text = text_value
	new_text.add_theme_color_override('font_color', color)
	new_text.add_theme_font_size_override('font_size', font_size)
	new_text.add_theme_constant_override('outline_size', outline_size)
	self.add_child(new_text)
	text_nodes[new_text.id] = new_text
	new_text.finished.connect(_on_node_finish.bind(new_text.id))
	new_text.show()
	new_text.started = true

func _on_node_finish(id:String):
	var node = text_nodes.get(id)
	if node and is_instance_valid(node):
		node.queue_free()
	text_nodes.erase(id)
