extends Control

@onready var Main = $".."
@onready var AudioManager = $"../AudioManager"
@onready var CharManager = $"../CharManager"
@onready var voice_woufeuse : AudioStreamPlayer = $"../AudioManager/AudioStreamPlayerW"
@onready var voice_vraisorcier : AudioStreamPlayer = $"../AudioManager/AudioStreamPlayerV"
@onready var bgm : AudioStreamPlayer = $"../AudioManager/BGM"
@onready var input_list : OptionButton = $SettingsPanel/MicrophoneList
@onready var output_list : OptionButton = $SettingsPanel/SpeakerList

@onready var threshold : int = AudioManager.threshold

func _ready():
	$SettingsPanel.hide()
	$SettingsPanel/ThresholdSlider.value = threshold
	$SettingsPanel/ThresholdValue.text = str(threshold)
	for device in AudioServer.get_input_device_list():
		input_list.add_item(device)
	for device in AudioServer.get_output_device_list():
		output_list.add_item(device)

func _process(_delta):
	%Debug.text = "[b]Input : [/b]" + str(AudioManager.input_power) + "
[b]Output V : [/b]" + str(AudioManager.output_power_vraisorcier) + "
[b]Output W : [/b]" + str(AudioManager.output_power_woufeuse) + "
[b]Delay : [/b]" + str(AudioManager.delay) + "
[b]Woufeuse : [/b]" + str(CharManager.state["Woufeuse"]) + "
[b]Vraisorcier : [/b]" + str(CharManager.state["Vraisorcier"])

func _input(event : InputEvent):
	if event.is_action_pressed("ESC"):
		$SettingsPanel.hide()
		Main.settings = false

func _on_settings_pressed():
	$SettingsPanel.visible = !$SettingsPanel.visible
	Main.settings = !Main.settings
	
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

func _on_musique_slider_value_changed(value):
	bgm.volume_db = value
	$"../AudioManager/Punch".volume_db = value
	$SettingsPanel/MusiqueValue.text = str(value)
	if value == -50.0:
		bgm.volume_db = -80
		$"../AudioManager/Punch".volume_db = -80

func _on_microphone_list_item_selected(index):
	AudioServer.set_input_device(input_list.get_item_text(index))
func _on_speaker_list_item_selected(index):
	AudioServer.set_output_device(output_list.get_item_text(index))

func _on_main_menu_pressed():
	$SettingsPanel.hide()
	Main.spawn_main_menu()
