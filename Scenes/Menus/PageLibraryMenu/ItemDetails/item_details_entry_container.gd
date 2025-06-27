@tool
class_name ItemDetailsEntryContainer
extends BaseObjectDetailsEntryContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

## Load the top level details displayed while entry is minimized
func _load_mini_details():
		super()

## Load full details displayed when entry is exspanded
func _load_full_details():
	super()
