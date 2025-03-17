class_name VfxData

var VFXKey:String
var load_path:String
var animation_name:String
var sprite_name:String
var sprite_sheet_width:int=1
var sprite_sheet_hight:int=1
var animation_speed:float=1.0
var scale:float=1.0

var random_offset_range:Vector2=Vector2.ZERO
var fixed_offset:Vector2i=Vector2i.ZERO
var match_source_dir:bool=false
var shake_actor:bool

func _init(data:Dictionary, load_path:String) -> void:
	VFXKey = data.get("VfxKey", "")
	if VFXKey == '':
		printerr("VfxData created without VFXKey")
		return
	self.load_path = load_path
	self.animation_name = data.get("AnimationName", "")
	self.sprite_name = data.get("SpriteName", "")
	self.sprite_sheet_width = data.get("SpriteSheetWidth", 1)
	self.sprite_sheet_hight = data.get("SpriteSheetHight", 1)
	self.animation_speed = data.get("AnimationSpeed", 1.0)
	self.scale = data.get("Scale", 1.0)
	var random_offsets = data.get("RandomOffsets", null)
	if random_offsets:
		random_offset_range = Vector2(random_offsets[0], random_offsets[1])
	var offsets = data.get("FixedOffset", null)
	if offsets:
		fixed_offset = Vector2i(offsets[0], offsets[1])
	shake_actor = data.get("ShakeActor", true)
	match_source_dir = data.get("MatchSourceDir", false)
