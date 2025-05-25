extends Node3D

@onready var AudioManager = $AudioManager
@onready var CharManager = $CharManager
@export var opening_scene : PackedScene

var settings = true

var mouse_pos : Vector2
var grabbed_object : RigidBody3D
var grab_position : Vector2
var offset = Vector3.ZERO

func spawn_main_menu():
	settings = true
	CharManager.state["Woufeuse"] = "x"
	CharManager.state["Vraisorcier"] = "x"
	get_tree().root.add_child.call_deferred(opening_scene.instantiate())
	$AudioManager/AudioStreamPlayerW.stop()
	$AudioManager/AudioStreamPlayerV.stop()

func main_menu_opened():
	settings = false
	CharManager.state["Woufeuse"] = "idle"
	CharManager.state["Vraisorcier"] = "idle"

func _ready():
	spawn_main_menu()

func _physics_process(_delta: float):
	if grabbed_object:
		grabbed_object.position = get_grab_position()
		grabbed_object.linear_velocity = Vector3.ZERO
		grabbed_object.angular_velocity = Vector3.ZERO

func _input(event: InputEvent) -> void:
	if not settings:
		if event is InputEventMouseMotion:
			mouse_pos = event.position
			if grabbed_object:
				if grab_position != mouse_pos:
					CharManager.state[grabbed_object.name] = "grabbed"
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				if not grabbed_object:
					grab(get_intersect(mouse_pos))
			elif event.button_index == MOUSE_BUTTON_LEFT:
				if grabbed_object:
					offset = Vector3.ZERO
					if CharManager.state[grabbed_object.name] == "grabbed":
						CharManager.state[grabbed_object.name] = "falling"
					elif CharManager.state[grabbed_object.name] == "held":
						CharManager.hit(grabbed_object)
					grabbed_object = null

func get_intersect(mouse : Vector2) -> Node:
	var space = get_world_3d().direct_space_state
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse, 1000)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	var result = space.intersect_ray(params)
	if not result.is_empty():
		return result.collider
	else:
		return self

func grab(object : Node):
	if object.get_parent() == $CharManager:
		if not CharManager.state[object.name] in ["ko", "hit", "recover"]:
			grabbed_object = object
			CharManager.state[grabbed_object.name] = "held"
			grab_position = mouse_pos

func get_grab_position():
	var pos = get_viewport().get_camera_3d().project_position(mouse_pos, $Camera3D.position.x - CharManager.default_x)
	if offset == Vector3.ZERO:
		offset = pos - grabbed_object.position
	pos = pos-offset
	return pos
