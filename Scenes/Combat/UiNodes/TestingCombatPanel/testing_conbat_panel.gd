extends PanelContainer

@export var refill_ammo_button:Button
@export var spawn_button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refill_ammo_button.pressed.connect(refill_ammo)
	spawn_button.pressed.connect(open_spawn_menu)

func refill_ammo():
	for actor_id in CombatRootControl.Instance.GameState._actors.keys():
		if actor_id == null:
			continue
		var actor = CombatRootControl.Instance.GameState.get_actor(actor_id)
		if actor:
			actor.pages.fill_page_ammo()


func open_spawn_menu():
	var option_menu = CombatRootControl.Instance.ui_control.option_select_menu
	var options = OnQueOptionsData.new("SpawnEnemy", "Spawn Enemy")
	for faction in ActorLibrary.list_factions():
		if faction == "Players":
			continue
		options.append_divider(faction)
		for actor_key in ActorLibrary.list_actor_keys_in_faction(faction):
			var display_name = ActorLibrary.Instance.get_display_name_of_def(actor_key)
			var icon = ActorLibrary.Instance.get_large_icon_of_def(actor_key)
			options.append_option(actor_key, display_name, icon)
	
	var team_options = OnQueOptionsData.new("TeamKey", "Select Team")
	var team_data = CombatRootControl.Instance.GameState.team_data
	for team_key in team_data.keys():
		var display_name = team_data[team_key].get("DisplayName", team_key)
		team_options.append_option(team_key, display_name, null)
	
	option_menu.set_options("SpawnEnemy", [options, team_options], on_option_selected)
	option_menu.show()

func on_option_selected(selection_key:String, options_data:Dictionary):
	var selected_actor_key = options_data[selection_key]
	var new_actor = ActorLibrary.create_actor(selected_actor_key, {})
	new_actor.TeamKey = options_data['TeamKey']
	CombatRootControl.Instance.ui_control.ui_state_controller.set_ui_state(UiStateController.UiStates.SpawnActor,
	{"SpawningActorId":new_actor.Id})
	pass
