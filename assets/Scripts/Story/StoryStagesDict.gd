class_name StatcStoryStages

static func get_stage_data(index:int)->Dictionary:
	if index >= 0 and index < stages.size():
		return stages[index]
	return {}

static var stages:Array = [
		#{
			#"StageKey": "TutorialCombat",
			#"Location": "Abandoned Cabin",
			#"MapScene": "res://Scenes/Maps/StoryMaps/1_StartingMap/starting_map.tscn",
			#"DialogScript": "res://Scenes/Maps/StoryMaps/1_StartingMap/start_game_dialog_script.json",
			## Go to next scene when finished, otherwise go to camp and wait for Quest (Default false)
			#"AutoTransition": true
		#},
		#{
			#"StageKey": "TutorialCamp",
			#"Location": "Abandoned Cabin",
			#"MapScene": null,
			#"DialogScript": "res://Scenes/Maps/StoryMaps/1_StartingMap/camp_tutotial_dialog_script.json"
		#},
		{
			"StageKey": "LeavingCabin",
			"Location": "Abandoned Cabin",
			"MapScene": null,
			"DialogScript": "res://Scenes/Maps/StoryMaps/1_StartingMap/leaving_camp_dialog_script.json"
		},
		{
			"StageKey": "CrossRoads_Combat",
			"Location": "The Crossroad",
			"MapScene": "res://Scenes/Maps/StoryMaps/2_Cross_Road/crossroad_dialog_map.tscn",
			"DialogScript":"res://Scenes/Maps/StoryMaps/2_Cross_Road/crossroad_dialog_script.json"
		},
		{
			"StageKey": "CrossRoads_PostCombat",
			"Location": "The Crossroad",
			"MapScene": "res://Scenes/Maps/StoryMaps/2_Cross_Road/crossroad_after_combat_map.tscn",
			"DialogScript":"res://Scenes/Maps/StoryMaps/2_Cross_Road/fish_intro_dialog_script.json"
		},
		{
			"StageKey": "CrossRoads_FishDialog1",
			"Location": "The Crossroad",
			"MapScene": null,
			"DialogScript":"res://Scenes/Maps/StoryMaps/2_Cross_Road/fish_camp_dialog_script.json"
		},
		{
			"StageKey": "CrossRoads_Leaving",
			"Location": "The Crossroad",
			"MapScene": null,
			"DialogScript":"res://Scenes/Maps/StoryMaps/2_Cross_Road/back_to_fish_dialog_script.json"
		}
	]
