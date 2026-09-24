class_name ChestActor
extends TrigerableActor

var _spawned_item_icon_path:String

func on_trigger(triggered_by_actor:BaseActor, _game_state:GameStateData):
	var story_flag = "OpenChest:" + self.Id
	var been_opened = StoryState.get_story_flag(story_flag)
	var item_key = null
	var chest_data:Dictionary = CombatRootControl.Instance.combat_map_data.get("LootData", {})
	
	
	if not been_opened:
		var gold_chests = chest_data.get("GoldChestMapping", {})
		item_key = gold_chests.get(self.Id)
	if !item_key:
		var drop_items = chest_data.get("SilverDropItemsSet", {})
		var selected_item = Roll.from_set(drop_items)
		item_key = selected_item
	if not item_key:
		printerr("ChestActor.on_trigger: No Chest Mapping found for '%s'," % [self.Id])
	else:
		var item = ItemLibrary.create_item(item_key, {})
		if item:
			var popup_data = ItemHelper.try_pickup_item(triggered_by_actor, item)
			CombatRootControl.Instance.ui_control.drop_message_control.add_card(
				popup_data['Message'],
				popup_data['Image'],
				popup_data['Background']
			)
			StoryState.set_story_flag(story_flag, true)
			_spawned_item_icon_path = item.get_small_icon_path()
	super(triggered_by_actor, _game_state)
	CombatRootControl.Instance.kill_actor(self)
