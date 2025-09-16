extends CanvasLayer

signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over(score):
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Scrap Collected: " + str(score) + "!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$VBoxContainer/StartButton.show()
	$VBoxContainer/MenuButton.show()

func update_score(score):
	$ScoreLabel.text = "Score: " + str(score)

func _on_start_button_pressed():
	$VBoxContainer/StartButton.hide()
	$VBoxContainer/MenuButton.hide()
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
