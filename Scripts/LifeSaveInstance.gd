# Stores info about a saved instance of the world
extends Object
class_name LifeSaveInstance

var name : String
var generation
var camera_position : Vector2

func get_data() -> Dictionary:
	
	var data = {
		"name" : name,
		"camera_pos_x" : camera_position.x,
		"camera_pos_y" : camera_position.y,
		"cells" : generation.get_cells_data()
	}
	
	return data

static func create_from_data(data : Dictionary):
	var save_instance = Internal.new()
	save_instance.name = data.name
	save_instance.camera_position = Vector2(data.camera_pos_x, data.camera_pos_y)
	save_instance.generation = LifeGeneration.new()
	save_instance.generation.load_cells_data(data.cells)
	return save_instance

class Internal:
	var name : String
	var generation
	var camera_position : Vector2
	
