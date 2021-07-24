# A Simple class thats in charge of simulating the game of life
# and providing ways for others to know about the simulation state

extends Node
class_name LifeSimulator

# Called when a new generation is evolved
signal generation_evolved(generation)

#TODO: Keep track of previous generations

var is_playing = false
var delay_timer = 0
var speed_percent = 1.0
var generation_counter = 0
var current_generation

func _init():
	current_generation = LifeGeneration.new()

func start_simulation():
	is_playing = true

func stop_simulation():
	is_playing = false

func reset():
	generation_counter = 0
	current_generation = LifeGeneration.new()

func next():
	if current_generation.next != null:
		current_generation = current_generation.next
	else:
		current_generation.evolve()
	
	emit_signal("generation_evolved", current_generation)
	generation_counter += 1

func previous():
	
	if current_generation.previous != null:
		current_generation = current_generation.previous
		generation_counter -= 1
	
	emit_signal("generation_evolved", current_generation)

func _process(delta):
	if is_playing:
		process_simulation(delta)

func process_simulation(delta : float):
	
	delay_timer -= delta
	
	if delay_timer <= 0:
		next()
		delay_timer = inverse_lerp(1,0,speed_percent)
