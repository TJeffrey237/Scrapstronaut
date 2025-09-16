extends Area2D
signal hit
signal collect

@export var speed = 400 # How fast the player will move.
var screen_size # Size of the game window.

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	# get the directions
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var final_velocity = Vector2.ZERO
	
	if direction:
		final_velocity = direction * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += final_velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	# Slowly rotate (simulating space)
	rotation += 0.05 * delta
	
	if direction.x != 0:
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = direction.x < 0

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("scraps"):
		body.queue_free()
		collect.emit()
	else:
		hide() # Player disappears after being hit.
		hit.emit()
		$CollisionShape2D.set_deferred("disabled", true)
