class_name LoadedOptionButton
extends OptionButton

@export var allways_show_none:bool = false
@export var no_option_text:String = '-None-'
var get_options_func:Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.focus_entered.connect(load_options)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_current_option_text():
	if self.selected >= 0:
		return self.get_item_text(self.selected)
	return ''

func get_index_of_option(val:String):
	for index in range(self.item_count):
		if val == self.get_item_text(index):
			return index
	return -1

func load_options(force_option:String=''):
	var current_option = force_option
	if force_option != '' and current_option == '' and self.selected >= 0:
		current_option = self.get_item_text(self.selected)
	# Reload and rebuild options
	self.clear()
	var selected_index = -1
	
			
	if not get_options_func:
		self.add_item("No Load Func")
		self.select(0)
		self.disabled = true
		return
		
	if allways_show_none:
		self.add_item(no_option_text)
		selected_index = 0
		
	var options = get_options_func.call()
	if options.size() > 0:
		for option in options:
			self.add_item(option)
			if option == current_option:
				selected_index = self.item_count - 1
	self.select(selected_index)
	
