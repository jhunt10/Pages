class_name StoryStages

static func get_stage_data(index:int)->Dictionary:
	if index >= 0 and index < stages.size():
		return stages[index]
	return {}

static var stages:Array = [
		{
			"StageKey": "TutorialCombat",
			"Location": "Abandoned Cabin",
			"MapScene": "res://Scenes/Maps/StoryMaps/1_StartingMap/starting_map.tscn",
			"DialogScript": "res://Scenes/Maps/StoryMaps/1_StartingMap/start_game_dialog_script.json",
			# Go to next scene when finished, otherwise go to camp and wait for Quest (Default false)
			"AutoTransition": true
		},
		{
			"StageKey": "TutorialCamp",
			"Location": "Abandoned Cabin",
			"MapScene": null,
			"DialogScript": "res://Scenes/Maps/StoryMaps/1_StartingMap/camp_tutotial_dialog_script.json"
		},
		{
			"StageKey": "CrossRoadsCombat",
			"Location": "The Crossroad",
			"MapScene": "res://Scenes/Maps/StoryMaps/2_Cross_Road/crossroad_dialog_map.tscn",
			"DialogScript":"res://Scenes/Maps/StoryMaps/2_Cross_Road/crossroad_dialog_script.json"
		}
	]
