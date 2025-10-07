extends Node2D

@export var mob_scene: PackedScene
@export var scrap_scene: PackedScene
@export var ufo_scene: PackedScene
@export var boid_spawner_scene: PackedScene

var score

func _ready():
	MusicPlayer.play_game_music()
	new_game()

func game_over():
	$HUD.get_node("ScoreLabel").hide()
	$MobTimer.stop()
	$ScrapTimer.stop()
	$UFOTimer.stop()
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
	$UFOTimer.start()

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
	$astronaut/CollisionShape2D.set_deferred("disabled", true)
	score += 1
	var SpawnLoc = $astronaut.global_position
	boid_spawning(SpawnLoc)
	$HUD.update_score(score)
	$astronaut/CollisionShape2D.set_deferred("disabled", false)

func boid_spawning(SpawnPosition):
	var boid_spawner_instance = boid_spawner_scene.instantiate()
	boid_spawner_instance.position = SpawnPosition
	add_child(boid_spawner_instance)
	boid_spawner_instance.call_deferred("CoinCollect")

func _on_scrap_timer_timeout() -> void:
	var viewport_size = get_viewport_rect().size
	
	var random_x = randf_range(0, viewport_size.x)
	var random_y = randf_range(0, viewport_size.y)
	
	var scrap_instance = scrap_scene.instantiate()
	var boid_spawner_instance = boid_spawner_scene.instantiate()
	
	scrap_instance.position = Vector2(random_x, random_y)
	boid_spawner_instance.position = Vector2(random_x, random_y)
	
	add_child(scrap_instance)

func _on_ufo_ufo_destroyed(expired) -> void:
	if expired:
		score += 5
		$HUD.update_score(score)

func _on_ufo_timer_timeout() -> void:
	var ufo = ufo_scene.instantiate()
	ufo.connect("ufo_destroyed", Callable(self, "_on_ufo_ufo_destroyed"))
	$astronaut.connect("hit_ufo", Callable(ufo, "on_hit"))
	var ufo_spawn_location = $MobPath/MobSpawnLocation
	ufo_spawn_location.progress_ratio = randf()

	ufo.position = ufo_spawn_location.position

	add_child(ufo)
