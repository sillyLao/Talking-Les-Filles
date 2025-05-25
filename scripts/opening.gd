extends Control

func _ready():
	$Up/Logo/AnimationPlayer.play("logo")

func _process(_delta):
	var x = ($Up/Logo/Timer.time_left/$Up/Logo/Timer.wait_time)*2*PI
	$Up/Logo.rotation_degrees = 10*sin(x)

func _on_button_pressed():
	$Up/Play/AnimationPlayer.play("clicked")

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"clicked":
			$AnimationPlayer.play("open")
		"open":
			get_tree().current_scene.main_menu_opened()
			queue_free()
		"logo":
			$Up/Logo/AnimationPlayer.play("logo")
