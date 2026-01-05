class_name StatPanelControl
extends VBoxContainer

const BoxPadding:int = 4

@export var button:Button
@export var portrait_texture_rect:TextureRect
@export var main_container:VBoxContainer
@export var health_bar:HealthBarControl
@export var bars_container:VBoxContainer
@export var effect_icon_box:HBoxContainer
@export var premade_effect_icon:EffectIconControl
@export var npc_index_label:Label

var actor:BaseActor
var effect_icons:Dictionary
var _stat_bars:Dictionary = {}
var _resize:bool = true

func _ready() -> void:
	premade_effect_icon.visible = false

func set_actor(act:BaseActor):
	if !act:
		return
	#if actor:
		#printerr("Actor already set on StatPanel.")
		#return
	if actor:
		if actor.Que.action_que_changed.is_connected(sync):
			actor.Que.action_que_changed.disconnect(sync)
			actor.effacts_changed.disconnect(_sync_icons)
	actor = act
	npc_index_label.text = actor.get_npc_index_str()
	#_stat_bars[StatHelper.HealthMax] = health_bar
	if health_bar:
		health_bar.set_actor(actor)
	actor.Que.action_que_changed.connect(sync)
	actor.effacts_changed.connect(_sync_icons)
	portrait_texture_rect.texture = actor.sprite.get_portrait_sprite()
	if not CombatRootControl.Instance.QueController.start_of_round.is_connected(_on_start_round):
		CombatRootControl.Instance.QueController.start_of_round.connect(_on_start_round)
		CombatRootControl.Instance.QueController.end_of_frame.connect(_on_frame_or_turn_end)
		CombatRootControl.Instance.QueController.end_of_turn.connect(_on_frame_or_turn_end)
		CombatRootControl.Instance.QueController.after_round.connect(_on_end_round)
	_build_stat_bars()
	if is_node_ready():
		_sync_values()
	
func _process(_delta: float) -> void:
	if _resize:
		self.size = Vector2i(main_container.size.x + (2*BoxPadding),
							bars_container.size.y + (2*BoxPadding))
		main_container.position = Vector2i(BoxPadding, BoxPadding)
		_resize = false
		sync(false)
	
func sync(_double_sync = true):
	if !actor:
		return
	_sync_values()
	_sync_icons()
	_resize = _double_sync

func _sync_values():
	if !actor:
		printerr("No actor found for stat bar")
		return
	#if health_bar:
		#health_bar._sync()
	#for bar in _stat_bars.values():
		#bar._sync()

func _sync_icons():
	for effect:BaseEffect in actor.effects.list_effects():
		if effect_icons.has(effect.Id):
			if effect._duration_counter >= 0:
				effect_icons[effect.Id].set_effect(effect)
			continue
		if not effect.show_in_hud():
			continue
		var new_icon:EffectIconControl = premade_effect_icon.duplicate()
		new_icon.set_effect(effect)
		new_icon.visible = true
		#if effect.show_counter():
			#_set_duration_text(effect.Id, effect.RemainingDuration)
		#else:
			#new_icon.get_child(0).hide()
		effect_icon_box.add_child(new_icon)
		effect_icons[effect.Id] = new_icon
	for id in effect_icons.keys():
		if !actor.effects._effects.has(id):
			effect_icons[id].queue_free()
			effect_icons.erase(id)

func _set_duration_text(effect_id:String, val:int):
	if effect_icons.keys().has(effect_id):
		effect_icons[effect_id].get_child(0).show()
		effect_icons[effect_id].get_child(0).text = str(val)

func _build_stat_bars():
	#for child in bars_container.get_children():
		#if child != health_bar:
			#child.queue_free()
	_stat_bars.clear()
	_stat_bars[StatHelper.HealthMax] = health_bar
	
	#for stat_name in actor.stats.list_bar_stat_names():
		#if stat_name == StatHelper.HealthMax:
			#continue
		#_create_stat_bar(stat_name)

#func _create_stat_bar(stat_name):
	#if _stat_bars.has(stat_name):
		#return
	#var new_bar:StatBarControl = load("res://Scenes/Combat/UiNodes/StatsPanel/stat_bar_control.tscn").instantiate()
	#new_bar.set_actor(actor, stat_name)
	#bars_container.add_child(new_bar)
	#if StatHelper.StatBarColors.keys().has(stat_name):
		#new_bar.set_color(StatHelper.StatBarColors[stat_name])
	#_stat_bars[stat_name] = new_bar
	
func _on_start_round():
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	if ! actor_node:
		return
	##actor_node.path_arrow.hide()
	#for bar:StatBarControl in _stat_bars.values():
		#bar.set_previewing_mode(false)

func _on_frame_or_turn_end():
	sync()
	
func _on_end_round():
	#for bar:StatBarControl in _stat_bars.values():
		#bar.set_previewing_mode(true, true)
	pass

func force_preview_mode():
	#for bar:StatBarControl in _stat_bars.values():
		#bar.set_previewing_mode(true, true)
	pass

func preview_stat_cost(_cost_data:Dictionary):
	#for stat_name in cost_data.keys():
		#if _stat_bars.keys().has(stat_name):
			#var stat_bar:StatBarControl = _stat_bars[stat_name]
			#stat_bar.preview_cost = cost_data[stat_name]
	pass
		
			
func stop_preview_stat_cost():
	#for bar:StatBarControl in _stat_bars.values():
		#bar.preview_cost = 0
	pass
