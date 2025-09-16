extends StaticBody2D

@export var pulse_speed = 4.0
@export var pulse_amplitude = 0.1

var base_scale: Vector2
var time_passed = 0.0

func _ready() -> void:
	base_scale = scale

func _process(delta: float) -> void:
	time_passed += delta
	var current_pulse = 1.0 + (sin(time_passed * pulse_speed) * pulse_amplitude)
	scale = base_scale * current_pulse
