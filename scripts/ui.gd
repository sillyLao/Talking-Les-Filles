extends Control

@onready var AudioManager = $"../AudioManager"
@onready var voice_woufeuse : AudioStreamPlayer = $"../AudioManager/AudioStreamPlayerW"
@onready var voice_vraisorcier : AudioStreamPlayer = $"../AudioManager/AudioStreamPlayerV"

@onready var threshold : int = AudioManager.threshold

func _ready():
	$SettingsPanel.hide()
	$SettingsPanel/ThresholdSlider.value = threshold
	$SettingsPanel/ThresholdValue.text = str(threshold)

func _process(_delta):
	$SettingsPanel/Debug.text = "[b]Input : [/b]" + str(AudioManager.input_power) + "
[b]Output V : [/b]" + str(AudioManager.output_power_vraisorcier) + "
[b]Output W : [/b]" + str(AudioManager.output_power_woufeuse) + "
[b]Delay : [/b]" + str(AudioManager.delay)

func _input(event : InputEvent):
	if event.is_action_pressed("ESC"):
		$SettingsPanel.hide()

func _on_settings_pressed():
	$SettingsPanel.visible = !$SettingsPanel.visible
	
func _on_threshold_value_changed(value):
	threshold = value
	$SettingsPanel/ThresholdValue.text = str(value)
	AudioManager.threshold = value

func _on_volume_slider_value_changed(value):
	if value >= 1:
		voice_woufeuse.volume_db = value
		voice_vraisorcier.volume_db = value
		$SettingsPanel/VolumeValue.text = str(value)
	else:
		voice_woufeuse.volume_db = value
		voice_vraisorcier.volume_db = value
		$SettingsPanel/VolumeValue.text = str(value)
		if value == -30.0:
			voice_woufeuse.volume_db = -80
		voice_vraisorcier.volume_db = -80
