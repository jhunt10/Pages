class_name DefDataMenu
extends Control

@export var def_box:RichTextLabel
@export var data_box:RichTextLabel

func set_object(thing):
	def_box.text = format_dict_to_string(thing._def)
	data_box.text = format_dict_to_string(thing._data)

func format_dict_to_string(dict:Dictionary)->String:
	var raw_string = str(dict)
	var indent_level = 0
	var in_list = false
	var in_super_list = false
	var out_string = ''
	var last_char = ''
	for char in raw_string:
		if char == '{':
			indent_level += 1
			out_string += char
			out_string += _new_line(indent_level)
		elif char == '}':
			indent_level -= 1
			out_string += _new_line(indent_level)
			out_string += char
		elif char == ',':
			out_string += char
			if not in_list or last_char == '"':
				out_string += _new_line(indent_level)
		elif char == '[':
			out_string += char
			in_list = true
			if last_char == '[':
				in_super_list = true
		elif char == ']':
			out_string += char
			if in_super_list:
				if last_char == ']':
					in_super_list = false
			elif last_char == '"':
				indent_level -= 1
					
			if not in_super_list:
				in_list = false
		elif char == '"' and in_list:
			if last_char == '[':
				indent_level += 1
				out_string += _new_line(indent_level)
				out_string += char
			else:
				out_string += char
			
		else:
			out_string += char
		last_char = char
	return out_string

func _new_line(indents:int)->String:
	var line = "\n"
	for i in range(indents):
		line += "\t"
	return line
			
