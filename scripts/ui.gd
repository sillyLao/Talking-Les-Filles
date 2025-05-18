extends Control

@onready var AudioManager = $"../AudioManager"

@onready var threshold : int = AudioManager.threshold

func _ready():
	$Threshold.value = threshold
	$ThresholdValue.text = str(threshold)

func _process(_delta):
	$Debug.text = "[b]Input : [/b]" + str(AudioManager.input_power) + "
[b]Output V : [/b]" + str(AudioManager.output_power_vraisorcier) + "
[b]Output W : [/b]" + str(AudioManager.output_power_woufeuse) + "
[b]Delay : [/b]" + str(AudioManager.delay)

func _on_threshold_value_changed(value):
	threshold = value
	$ThresholdValue.text = str(value)
	AudioManager.threshold = value
