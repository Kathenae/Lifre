extends Camera2D

var scroll_dir = 0.0

func _process(delta):
	zoom += Vector2.ONE * 10 * scroll_dir * delta
	zoom.x = clamp(zoom.x, 0.5,4)
	zoom.y = clamp(zoom.y, 0.5,4)

func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		
		if Input.is_action_pressed("right_mouse_button"):
			position -= event.relative * 3
	
	if event is InputEventKey:
		scroll_dir = Input.get_action_strength("zoom_in") - Input.get_action_strength("zoom_out")
