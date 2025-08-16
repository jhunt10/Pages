extends BoxContainer


func set_stat_name(stat_name:String):
	var icon = StatHelper.get_stat_icon(stat_name)
	if icon:
		var icon_rect = $IconRect
		icon_rect.texture = icon
	
