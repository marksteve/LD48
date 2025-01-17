extends Camera

const LEVEL_DEPTH = 1000
onready var noise = OpenSimplexNoise.new()
var noise_y = 0
var shake_decay = 0.8
var shake_amount = 0.0
var shake_max_offset = Vector2(3, 3)
var shake_max_roll = 0.1

func shake(amount: float):
	noise_y += 1
	rotation.z = shake_max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	shake_max_offset.x = shake_max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	shake_max_offset.y = shake_max_offset.y * amount * noise.get_noise_2d(noise.seed * 3, noise_y)

func _ready():
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

func _process(delta):
	if shake_amount > 0.0:
		shake(shake_amount)
		shake_amount = max(shake_amount - shake_decay * delta, 0)

func _on_Ship_depth_changed(depth, _velocity):
	if depth < 50:
		shake_amount = 1.0
		self.translation.y = lerp(self.translation.y, -depth, 0.2)
	else:
		self.translation.z = lerp(self.translation.z, 50, 0.2)
		self.translation.y = lerp(self.translation.y, -depth, 0.2)
	self.environment.background_energy = max(1.0 - depth / LEVEL_DEPTH / 10, 0)

func _on_Ship_destroyed():
	shake_amount = 1.0

func _on_UI_screen_changed(screen):
	if screen == "title":
		self.translation.z = 5
		self.translation.y = 20
