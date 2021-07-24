# Draws a square at the mouse position
extends Node2D

const CELL_SCALE = 15
const CELL_SPACING = 5

func _process(delta):
	update()

func _draw():
	
	var mouse_position = get_global_mouse_position()
	var cell_x = floor(mouse_position.x / (CELL_SCALE + CELL_SPACING))
	var cell_y =  floor(mouse_position.y / (CELL_SCALE + CELL_SPACING))
	var cell = Vector2(cell_x,cell_y)
	
	var rect_position = cell * (CELL_SCALE + CELL_SPACING)
	var rect_size = Vector2.ONE * CELL_SCALE
	var cell_rect = Rect2(rect_position,rect_size)
	draw_rect(cell_rect,Color.orangered,false)

