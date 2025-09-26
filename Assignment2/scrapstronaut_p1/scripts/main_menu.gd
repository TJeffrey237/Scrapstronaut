extends Control

func _ready() -> void:
	MusicPlayer.play_menu_music()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
