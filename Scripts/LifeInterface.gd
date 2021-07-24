# Provides the actual interface to allow users to interact with the game
# TODO: this class is doing too many things now, change that

extends Node2D

const CELL_SCALE = 15
const CELL_SPACING = 5
var life_simulator : LifeSimulator

func _ready():
	life_simulator = LifeSimulator.new()
	$ui/root/speed.text = "Speed " + str(life_simulator.speed_percent * 100) + "%"
	var connected = life_simulator.connect("generation_evolved",self,"on_generation_evolved")
	add_child(life_simulator)
	update()

func on_generation_evolved(generation):
	play_generation_sound(generation)
	update_stats_ui()
	update()

func toggle_cell_at_mouse():
	
	var mouse_position = get_global_mouse_position()
	var cell_x = floor(mouse_position.x / (CELL_SCALE + CELL_SPACING))
	var cell_y =  floor(mouse_position.y / (CELL_SCALE + CELL_SPACING))
	var cell_coord = Vector2(cell_x,cell_y)
	
	if life_simulator.current_generation.has(cell_coord):
		life_simulator.current_generation.erase(cell_coord)
		life_simulator.current_generation.next = null # Since changes to the current alter the evolution result
		update()
		update_stats_ui()
	else:
		life_simulator.current_generation.spawn(cell_coord)
		life_simulator.current_generation.next = null # Since changes to the current alter the evolution result
		update()
		update_stats_ui()

func _on_play_button_pressed():
	toggle_play()

func toggle_play():
	if life_simulator.is_playing:
		pause()
	else:
		play()

func pause():
	life_simulator.stop_simulation()
	$ui/root/play_button.text = "Resume"
	$ui/root/playback_state.text = "Paused"

func play():
	life_simulator.start_simulation()
	$ui/root/play_button.text = "Pause"
	$ui/root/playback_state.text = "Playing"

func _unhandled_input(event):
	
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("left_mouse_button"):
			pause()
			toggle_cell_at_mouse()
	
	if event is InputEventKey:
		
		if event.pressed and event.scancode == KEY_SPACE:
			toggle_play()
		
		if event.pressed and event.scancode == KEY_R:
			reset()

func _draw():
	for cell in life_simulator.current_generation.get_cell_coords():
		var rect_position = cell * (CELL_SCALE + CELL_SPACING)
		var rect_size = Vector2.ONE * CELL_SCALE
		var cell_rect = Rect2(rect_position,rect_size)
		draw_rect(cell_rect,Color.white)
	
	var previous = life_simulator.current_generation.previous
	if previous != null:
		for cell in previous.get_cell_coords():
			
			if life_simulator.current_generation.has(cell):
				continue
			
			var rect_position = cell * (CELL_SCALE + CELL_SPACING)
			var rect_size = Vector2.ONE * CELL_SCALE
			var cell_rect = Rect2(rect_position,rect_size)
			draw_rect(cell_rect,Color.red)
		
		if previous.previous != null:
			for cell in previous.previous.get_cell_coords():
				
				if previous.has(cell) or life_simulator.current_generation.has(cell):
					continue
				
				var rect_position = cell * (CELL_SCALE + CELL_SPACING)
				var rect_size = Vector2.ONE * CELL_SCALE
				var cell_rect = Rect2(rect_position,rect_size)
				draw_rect(cell_rect,Color.darkred)

func update_stats_ui():
	$ui/root/stats.text = "Total Cells: " + str(life_simulator.current_generation.count())
	$ui/root/stats.text += "\nGenerations: " + str(life_simulator.generation_counter)

func play_generation_sound(generation):
	
	if generation.previous != null:
		if generation.previous.count() > generation.count():
			$generate_sound.pitch_scale += 0.1
		elif generation.previous.count() < generation.count():
			if $generate_sound.pitch_scale - 0.1 >= 0:
				$generate_sound.pitch_scale -= 0.1
		elif generation.previous.count() == generation.count():
			$generate_sound.pitch_scale = 1.0
	
	$generate_sound.play()

func _on_speed_slider_value_changed(value):
	var speed_percent = inverse_lerp($ui/root/speed_slider.min_value, $ui/root/speed_slider.max_value, $ui/root/speed_slider.value)
	$ui/root/speed.text = "Speed " + str(speed_percent * 100) + "%"
	life_simulator.speed_percent = speed_percent

func _on_clear_pressed():
	reset()

func reset():
	pause()
	life_simulator.reset()
	update_stats_ui()
	update()

## SAVE UI

func _on_save_pressed():
	$ui/root/save_dialog.show()

func _on_save_cancel_pressed():
	$ui/root/save_dialog.hide()

func _on_save_confirm_pressed():
	
	var save_instance = LifeSaveInstance.new()
	save_instance.name = $ui/root/save_dialog/name_input.text
	save_instance.camera_position = $camera.position
	save_instance.generation = life_simulator.current_generation
	
	$save_manager.save_instance(save_instance)
	$ui/root/save_dialog.hide()

func _on_load_pressed():
	$ui/root/load_dialog.show()
	
	# Load save buttons
	for child in $ui/root/load_dialog/scroll/save_files.get_children():
		child.queue_free()
	
	for save_instance in $save_manager.get_all_instances():
		var button = Button.new()
		button.text = save_instance.name
		button.connect("pressed",self,"_on_load_instance_pressed",[save_instance])
		$ui/root/load_dialog/scroll/save_files.add_child(button)

func _on_load_instance_pressed(save_instance):
	
	$ui/root/load_dialog.hide()
	
	# Apply instance state
	$camera.position = save_instance.camera_position
	life_simulator.current_generation = save_instance.generation
	
	update_stats_ui()
	update()

func _on_load_cancel_pressed():
	$ui/root/load_dialog.hide()

func _on_exit_button_pressed():
	get_tree().quit()

func _on_previous_generation_pressed():
	life_simulator.previous()
	update()
	update_stats_ui()
	pass

func _on_next_generation_pressed():
	life_simulator.next()
	update()
	update_stats_ui()
