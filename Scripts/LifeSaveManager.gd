extends Node2D

var save_instances_data = {}

func _ready():
	load_data()

func save_instance(save_instance : LifeSaveInstance):
	save_instances_data[save_instance.name] = to_json(save_instance.get_data())
	save_data()

func load_instance(save_name : String) -> LifeSaveInstance:
	
	load_data()
	
	if save_instances_data.has(save_name) == false:
		return null
	
	var data = save_instances_data[save_name]
	var save_instance = parse_save_instance(data)
	
	return save_instance

func get_all_instances() -> Array:
	
	load_data()
	
	var save_instances = []
	
	for data in save_instances_data.values():
		var instance = parse_save_instance(data)
		save_instances.append(instance)
	
	return save_instances

func parse_save_instance(data : String) -> LifeSaveInstance:
	return LifeSaveInstance.create_from_data(parse_json(data))

func save_data():
	var file = File.new()
	file.open("user://save.data",File.WRITE)
	file.store_string(to_json(save_instances_data))
	file.close()

func load_data():
	var file = File.new()
	file.open("user://save.data",File.READ)
	save_instances_data = parse_json(file.get_line())
	file.close()
