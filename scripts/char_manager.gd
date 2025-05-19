extends Node

@onready var AudioManager = $"../AudioManager"
@onready var woufeuse = $Woufeuse
@onready var vraisorcier = $Vraisorcier

var state_woufeuse = "idle"
var state_vraisorcier = "idle"

func _physics_process(_delta):
	if state_woufeuse == "speak":
		if AudioManager.output_power_woufeuse > AudioManager.threshold:
			woufeuse.play("speak")
		else:
			woufeuse.play("idle")
	else:
		woufeuse.play("idle")
	if state_vraisorcier == "speak":
		if AudioManager.output_power_vraisorcier > AudioManager.threshold:
			vraisorcier.play("speak")
		else:
			vraisorcier.play("idle")
	else:
		vraisorcier.play("idle")
