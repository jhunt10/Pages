class_name UiState_ItemSelection
extends BaseUiState

var item_select_menu:ItemSelectMenuControl:
	get: return CombatRootControl.Instance.ui_controller.item_select_menu

var _current_actor:BaseActor
var _action_key:String

func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	_current_actor = args['Actor']
	_action_key = args['ActionKey']
	pass
	

func start_state():
	item_select_menu.visible = true
	item_select_menu.set_items(_current_actor.items)
	item_select_menu.on_item_selected.connect(on_item_selected)
	pass

func update(_delta:float):
	pass

func end_state():
	CombatRootControl.Instance.ui_controller.item_select_menu.visible = false
	pass

func on_item_selected(item_id:String):
	print("SELECTED ITEM: " + item_id)
	var action = MainRootNode.action_libary.get_action(_action_key)
	_current_actor.Que.que_action(action, {"ItemId": item_id})
	CombatRootControl.Instance.ui_controller.back_to_last_state()

func handle_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			CombatRootControl.Instance.ui_controller.back_to_last_state()
