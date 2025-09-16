extends Node2D

@export var mob_scene: PackedScene
@export var scrap_scene: PackedScene

var score

func _ready():
	MusicPlayer.play_game_music()
	new_game()

func game_over():
	$HUD.get_node("ScoreLabel").hide()
	$MobTimer.stop()
	$ScrapTimer.stop()
	$HUD.show_game_over(score)

func new_game():
	get_tree().call_group("scraps", "queue_free")
	get_tree().call_group("asteroids", "queue_free")
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!!")
	$astronaut.start($StartPosition.position)
	$StartTimer.start()
	$ScrapTimer.start()

func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()

	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	mob.position = mob_spawn_location.position

	var direction = mob_spawn_location.rotation + PI / 2

	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	var velocity = Vector2(randf_range(50.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	add_child(mob)

func _on_start_timer_timeout() -> void:
	$HUD.get_node("ScoreLabel").show()
	$MobTimer.start()

func collect_scrap() -> void:
	score += 1
	$HUD.update_score(score)

func _on_scrap_timer_timeout() -> void:
	var viewport_size = get_viewport_rect().size
	
	var random_x = randf_range(0, viewport_size.x)
	var random_y = randf_range(0, viewport_size.y)
	
	var scrap_instance = scrap_scene.instantiate()
	
	scrap_instance.position = Vector2(random_x, random_y)
	
	add_child(scrap_instance)
