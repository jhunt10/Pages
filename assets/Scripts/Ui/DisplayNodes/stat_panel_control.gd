class_name StatPanelControl
extends Control

const StatBarColors:Dictionary = {
	"Health": Color.RED,
	"Mana": Color.DEEP_SKY_BLUE,
	"Stamina": Color.GREEN
}

const BoxPadding:int = 4

@onready var main_container:VBoxContainer = $VBoxContainer
@onready var health_bar:StatBarControl = $VBoxContainer/HBoxContainer/StatBarContainer/HealthStatBar
@onready var bars_container:VBoxContainer = $VBoxContainer/HBoxContainer/StatBarContainer
@onready var effect_icon_box:HBoxContainer = $VBoxContainer/IconBoxContainer
@onready var premade_effect_icon:TextureRect = $VBoxContainer/EffectIcon

var actor:BaseActor
var effect_icons:Dictionary
var _stat_bars:Dictionary = {}
var _resize:bool = true

func _ready() -> void:
	premade_effect_icon.visible = false

func set_actor(act:BaseActor):
	if actor:
		printerr("Actor already set on StatPanel.")
		return
	actor = act
	_stat_bars[StatHolder.HealthKey] = health_bar
	health_bar.set_actor(actor, StatHolder.HealthKey)
	actor.Que.action_que_changed.connect(sync)
	CombatRootControl.Instance.QueController.start_of_round.connect(_on_start_round)
	CombatRootControl.Instance.QueController.end_of_frame.connect(_on_frame_or_turn_end)
	CombatRootControl.Instance.QueController.end_of_turn.connect(_on_frame_or_turn_end)
	CombatRootControl.Instance.QueController.end_of_round.connect(_on_end_round)
	_build_stat_bars()
	_sync_values()
	
func _process(delta: float) -> void:
	if _resize:
		self.size = Vector2i(main_container.size.x + (2*BoxPadding),
							bars_container.size.y + (2*BoxPadding))
		main_container.position = Vector2i(BoxPadding, BoxPadding)
		_resize = false
		sync(false)
	
func sync(_double_sync = true):
	_sync_values()
	_sync_icons()
	_resize = _double_sync

func _sync_values():
	if !actor:
		printerr("No actor found for stat bar")
		return
	for bar:StatBarControl in _stat_bars.values():
		bar._sync()

func _sync_icons():
	for effect:BaseEffect in actor.effects.list_effects():
		if effect_icons.has(effect.Id):
			if true or effect._duration_counter >= 0:
				_set_duration_text(effect.Id, effect.RemainingDuration)
			continue
		var new_icon = premade_effect_icon.duplicate()
		new_icon.texture = effect.get_sprite()
		new_icon.visible = true
		if true or effect._duration_counter >= 0:
			_set_duration_text(effect.Id, effect.RemainingDuration)
		effect_icon_box.add_child(new_icon)
		effect_icons[effect.Id] = new_icon
	for id in effect_icons.keys():
		if !actor.effects._effects.has(id):
			effect_icons[id].queue_free()
			effect_icons.erase(id)

func _set_duration_text(effect_id:String, val:int):
	if effect_icons.keys().has(effect_id):
		effect_icons[effect_id].get_child(0).text = str(val)

func _build_stat_bars():
	for stat_name in _stat_bars.keys():
		if stat_name == StatHolder.HealthKey:
			continue
		var bar = _stat_bars[stat_name]
		bar.que_free()
	_stat_bars.clear()
	_stat_bars[StatHolder.HealthKey] = health_bar
	
	for stat_name in actor.stats.list_bar_stats():
		if stat_name == StatHolder.HealthKey:
			continue
		_create_stat_bar(stat_name)

func _create_stat_bar(stat_name):
	if _stat_bars.has(stat_name):
		return
	var new_bar:StatBarControl = health_bar.duplicate()
	new_bar.set_actor(actor, stat_name)
	bars_container.add_child(new_bar)
	if StatBarColors.keys().has(stat_name):
		new_bar.set_color(StatBarColors[stat_name])
	_stat_bars[stat_name] = new_bar
	
func _on_start_round():
	for bar:StatBarControl in _stat_bars.values():
		bar.set_previewing_mode(false)

func _on_frame_or_turn_end():
	sync()
	
func _on_end_round():
	for bar:StatBarControl in _stat_bars.values():
		bar.set_previewing_mode(true)

func preview_stat_cost(cost_data:Dictionary):
	for stat_name in cost_data.keys():
		if _stat_bars.keys().has(stat_name):
			_stat_bars[stat_name].play_preview_blink(cost_data[stat_name])
		
			
func stop_preview_stat_cost():
	for bar:StatBarControl in _stat_bars.values():
		bar.stop_preview_animation()
