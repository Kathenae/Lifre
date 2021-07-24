# Represents an entire generation of the game of life
# responsible for keeping track of live cells and is able to evolve into a new generation

extends Reference
class_name LifeGeneration

var __me : InternalLifeGeneration

var previous : InternalLifeGeneration setget , _get_previous_generation
var next : InternalLifeGeneration setget , _get_next_generation

func _init():
	__me = InternalLifeGeneration.new()

func evolve():
	__me.evolve()

func is_equal(other_generation : InternalLifeGeneration) -> bool:
	return __me.is_equal(other_generation)

func get_cell_coords():
	return __me.get_cell_coords()

func has(cell : Vector2) -> bool:
	return __me.has(cell)

func count() -> int :
	return __me.count()

func spawn(cell : Vector2) -> void:
	__me.spawn(cell)

func erase(cell : Vector2) -> bool:
	return __me.erase(cell)

func duplicate() -> InternalLifeGeneration:
	return __me.duplicate()

func get_cells_data() -> String:
	return __me.get_cells_data()

func load_cells_data(cells_str : String) -> void:
	__me.load_cells_data(cells_str)

func _get_previous_generation():
	return __me.previous

func _get_next_generation():
	return __me.next

# This is only used to allow us to some level of encapsulation
class InternalLifeGeneration:
	var cells = {}
	
	# NOTE: These are not used when evolving, created just so we have some type of "timeline"
	var previous : InternalLifeGeneration
	var next : InternalLifeGeneration
	
	func evolve():
		
		previous =  self.duplicate()
		
		var surviving_cells = {}
		var dead_cells = {}
		
		for cell in self.get_cell_coords():
			
			var count = 0
			
			# Loop through our neighbours
			for x in [-1,0,1]:
				for y in [-1,0,1]:
					
					if x == 0 and y == 0:
						continue
					
					var neighbour = Vector2(cell.x + x,cell.y + y)
					
					var is_neighbour_alive = self.has(neighbour)
					
					if is_neighbour_alive:
						count += 1
					
					if is_neighbour_alive == false:
						
						if dead_cells.has(str(neighbour)) == false:
							dead_cells[str(neighbour)] = {"coord" : neighbour, "count" : 0}
						
						dead_cells[str(neighbour)].count += 1
			
			# check if the "live cells with two or three neighbours survives" rule applies
			if count == 3 or count == 2:
				surviving_cells[str(cell)] = cell
			
		for cell in dead_cells.values():
			#  check if the "A dead cell with three live neighbours is re-born" rule applies
			if cell.count == 3:
				surviving_cells[str(cell.coord)] = cell.coord
		
		self.cells = surviving_cells
		
		previous.next = self.duplicate()

	# Checks if the given generation has the exact same "pattern" as this one
	func is_equal(other_generation : InternalLifeGeneration) -> bool:
		
		if other_generation == null:
			return false
		
		for cell_in_other in other_generation.get_coords():
			if self.has(cell_in_other) == false:
				return false
		
		return true

	func get_cell_coords():
		return cells.values()

	func has(cell : Vector2) -> bool:
		return cells.has(str(cell))

	func spawn(cell : Vector2) -> void:
		cells[str(cell)] = cell

	func erase(cell : Vector2) -> bool:
		return cells.erase(str(cell))

	func count() -> int:
		return cells.size()

	func duplicate() -> InternalLifeGeneration:
		var duplicate_generation = InternalLifeGeneration.new()
		duplicate_generation.cells = self.cells.duplicate()
		duplicate_generation.previous = self.previous
		duplicate_generation.next = self.next
		return duplicate_generation
	
	func get_cells_data() -> String:
		return var2str(cells)
	
	func load_cells_data(cells_str : String) -> void:
		self.cells = str2var(cells_str)
	
