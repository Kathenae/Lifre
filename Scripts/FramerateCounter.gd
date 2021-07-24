extends Label

func _ready():
	self.set_counter()

func _physics_process(_delta: float):
	self.set_counter()

func set_counter():
	text = str(Engine.get_frames_per_second()) + " FPS"
