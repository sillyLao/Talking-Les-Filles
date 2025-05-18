extends Node

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
	print_rich("[b]IN :[/b] " + str(input_power))
	check_volume(input_power)
	output_power_woufeuse = AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index("Woufeuse"), 0)
	print_rich("[b]OUT W :[/b] " + str(output_power_woufeuse))
	output_power_vraisorcier = AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index("Vraisorcier"), 0)
	print_rich("[b]OUT V :[/b] " + str(output_power_vraisorcier))

func start_recording():
	effect.set_recording_active(true)

func stop_recording():
	recording = effect.get_recording()
	effect.set_recording_active(false)
	print(recording)
	print(recording.format)
	print(recording.mix_rate)
	print(recording.stereo)
	var data = recording.get_data()
	print(data.size())
	new_delay()
	voice()

func check_volume(input_power : int) -> void:
	if not effect.is_recording_active():
		if input_power > threshold:
			start_recording()
	else:
		if input_power > threshold:
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
		$AudioStreamPlayerW.play()
	else:
		$AudioStreamPlayerV.play()
	$TimerDelay.start()

func _on_timer_delay_timeout():
	if sign(delay) == 1:
		$AudioStreamPlayerV.play()
	else:
		$AudioStreamPlayerW.play()
