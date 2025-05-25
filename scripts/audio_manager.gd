extends Node

@onready var CharManager = $"../CharManager"

var effect : AudioEffectRecord
var recording : AudioStreamWAV
var index : int
var threshold : float = -50
var input_power : float
var output_power_woufeuse : float
var output_power_vraisorcier : float
var delay : float = 0.0

func _ready():
	index = AudioServer.get_bus_index("Record2")
	effect = AudioServer.get_bus_effect(index, 0)

func _physics_process(_delta):
	input_power = AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index("Record2"), 0)
	output_power_woufeuse = AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index("Woufeuse"), 0)
	output_power_vraisorcier = AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index("Vraisorcier"), 0)
	check_volume(input_power)
	#print_rich("[b]IN :[/b] " + str(input_power))
	#print_rich("[b]OUT W :[/b] " + str(output_power_woufeuse))
	#print_rich("[b]OUT V :[/b] " + str(output_power_vraisorcier))

func start_recording():
	effect.set_recording_active(true)

func stop_recording():
	recording = effect.get_recording()
	effect.set_recording_active(false)
	#print(recording)
	#print(recording.format)
	#print(recording.mix_rate)
	#print(recording.stereo)
	var _data = recording.get_data()
	#print(data.size())
	new_delay()
	voice()

func check_volume(power : float) -> void:
	if not effect.is_recording_active():
		if power > threshold:
			start_recording()
			$TimerThreshold.start()
	else:
		if power > threshold:
			$TimerThreshold.start()
		else:
			if $TimerThreshold.is_stopped():
				stop_recording()

func new_delay():
	delay = tanh(randf_range(-0.3, 0.3)*4)/3.0
	$TimerDelay.wait_time = abs(delay)

func voice():
	$AudioStreamPlayerW.stream = recording
	$AudioStreamPlayerV.stream = recording
	if sign(delay) == 1:
		woufeuse_speak()
	else:
		vraisorcier_speak()
	$TimerDelay.start()

func woufeuse_speak():
	if CharManager.state["Woufeuse"] in ["idle", "speak"]:
		$AudioStreamPlayerW.play()
		CharManager.state["Woufeuse"] = "speak"
	
func vraisorcier_speak():
	if CharManager.state["Vraisorcier"] in ["idle", "speak"]:
		$AudioStreamPlayerV.play()
		CharManager.state["Vraisorcier"] = "speak"

func _on_timer_delay_timeout():
	if sign(delay) == 1:
		vraisorcier_speak()
	else:
		woufeuse_speak()

func _on_audio_stream_player_w_finished():
	CharManager.state["Woufeuse"] = "idle"
func _on_audio_stream_player_v_finished():
	CharManager.state["Vraisorcier"] = "idle"
