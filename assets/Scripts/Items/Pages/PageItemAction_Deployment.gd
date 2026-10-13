class_name PageItemAction_Deployment
extends PageItemAction

########################
##    Icons  Data     ##
########################

func get_qued_icon(turn_index:int, que:ActionQueHolder, override_actor:BaseActor =  null)->Texture2D:
	var deploying_actor_title = ""
	var icon_path = _def_load_path.path_join(get_object_details().get("SmallIcon", ""))
	if self.ActionKey == "BeDeployed_ActionPage":
		if override_actor:
			deploying_actor_title = override_actor.get_title()
	elif self.ActionKey == "Deploy_ActionPage":
		var turn_data = que.get_data_for_turn(turn_index)
		var deploying_actor_id = turn_data.on_que_data.get("DeployingActorId", "")
		var deploying_actor = ActorLibrary.get_actor(deploying_actor_id)
		deploying_actor_title = deploying_actor.get_title()
	if deploying_actor_title:
		icon_path = icon_path.replace("_Icon", "_" + deploying_actor_title + "_Icon")
	return SpriteCache.get_sprite(icon_path)
