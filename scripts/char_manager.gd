extends Node

@onready var Main = $".."
@onready var AudioManager = $"../AudioManager"
@onready var Room = $"../Room 1"

var state : Dictionary = {
	"Woufeuse": "x",
	"Vraisorcier": "x",
	"LifeWoufeuse": 3,
	"LifeVraisorcier": 3,
	"CollisionLimitVWoufeuse": 51779.0,
	"CollisionLimitHWoufeuse": 51779.0,
	"CollisionLimitVVraisorcier": 51779.0,
	"CollisionLimitHVraisorcier": 51779.0
}
var default_x : float
var held_params : Array = []

func _ready():
	default_x = $Woufeuse.position.x

func _physics_process(delta):
	for fille:RigidBody3D in [$Woufeuse, $Vraisorcier]:
		var fname = fille.name
		var fsprite = fille.get_node("Sprite")
		
		match state[fname]:
			"idle":
				if state["Life"+fname] < 3:
					fsprite.play("hurt")
				else:
					fsprite.play("idle")
				if fille.get_node("RagdollReset").is_stopped():
					fille.rotation.x = move_toward(fille.rotation.x, 0, ((fille.rotation.x/10)+5)*delta)
				var rot : Vector3 = fille.rotation
				if abs((rot.x+rot.y+rot.z)/3) < 0.01:
					fille.gravity_scale = 1
					fille.get_node("Collision").disabled = false
			"speak":
				if fname == "Woufeuse":
					if AudioManager.output_power_woufeuse > AudioManager.threshold:
						fsprite.play("speak")
					else:
						fsprite.play("idle")
				if fname == "Vraisorcier":
					if AudioManager.output_power_vraisorcier > AudioManager.threshold:
						fsprite.play("speak")
					else:
						fsprite.play("idle")
			"recover":
				fsprite.play("idle")
				fille.linear_velocity = Vector3.ZERO
				fille.angular_velocity = Vector3.ZERO
				fille.rotation = fille.rotation.move_toward(Vector3.ZERO, 0.03)
				fille.position.x = move_toward(fille.position.x, default_x, 0.026)
				if fille.rotation.z < 0.01:
					state[fname] = "idle"
					fille.gravity_scale = 1
					fille.get_node("Collision").disabled = false
			"grabbed":
				fille.gravity_scale = 1
				fille.get_node("Collision").disabled = false
			"ko":
				fsprite.play("ko")
				fille.angular_velocity.z = clamp(fille.angular_velocity.z, 0, 10)
			"falling":
				if fille.position.y <= Room.LIMIT_VN:
					state[fname] = "idle"
				
		if not state[fname] in ["ko", "recover"]:
			fille.rotation.y = 0
			fille.rotation.z = 0
			fille.position.x = default_x
			fille.position.y = clamp(fille.position.y, Room.LIMIT_VN-(abs(sin(fille.rotation.z)*0.35)), Room.LIMIT_VP)
			fille.position.z = clamp(fille.position.z, Room.LIMIT_HN, Room.LIMIT_HP)
			
		var vel : Vector3 = fille.linear_velocity
		var ang : Vector3 = fille.angular_velocity
		if abs((vel.x+vel.y+vel.z)/3) < 0.01 and abs((ang.x+ang.y+ang.z)/3) < 0.01:
			if not state[fname] in ["ko"]:
				fille.linear_velocity = Vector3.ZERO
				if not state[fname] in ["speak", "grabbed", "held", "recover", "x"]:
					state[fname] = "idle"


func hit(fille : RigidBody3D) -> void:
	if state["Life"+fille.name] > 1:
		state[fille.name] = "hit"
		fille.get_node("Sprite").play("hurt")
		fille.get_node("Animation"+fille.name).play("RESET_"+fille.name)
		fille.get_node("Animation"+fille.name).play("hit_"+fille.name)
		state["Life"+fille.name] += -1
		fille.get_node("HitReset").start()
		AudioManager.get_node("Punch").play()
	else:
		state[fille.name] = "ko"
		state["Life"+fille.name] = 3
		fille.angular_velocity.z = 20*pow(randf(), exp(2))+4
		print(fille.angular_velocity.z)
		fille.get_node("KOReset").start()
		AudioManager.get_node("Punch").play()

func _on_animation_woufeuse_animation_finished(anim_name):
	anim_finished($Woufeuse, anim_name)
func _on_animation_vraisorcier_animation_finished(anim_name):
	anim_finished($Vraisorcier, anim_name)

func anim_finished(fille:RigidBody3D, anim_name:String):
	var hit_anim = "hit_"+fille.name
	match anim_name:
		hit_anim:
			if not state[fille.name] in ["ko"]:
				state[fille.name] = "idle"

func _on_vraisorcier_body_entered(body):
	if body in [Room.FLOOR] and not state["Vraisorcier"] in ["recover", "held", "grabbed", "x"]:
		$Vraisorcier/RagdollReset.start()
func _on_woufeuse_body_entered(body):
	if body in [Room.FLOOR] and not state["Woufeuse"] in ["recover", "held", "grabbed", "x"]:
		$Woufeuse/RagdollReset.start()
func _on_vraisorcier_ragdoll_reset_timeout():
	if not state["Vraisorcier"] in ["grabbed", "falling", "ko"]:
		state["Vraisorcier"] = "recover"
		$Vraisorcier.gravity_scale = 1
		$Vraisorcier/Collision.disabled = false
func _on_woufeuse_ragdoll_reset_timeout():
	if not state["Woufeuse"] in ["grabbed", "falling"]:
		state["Woufeuse"] = "recover"
		$Woufeuse.gravity_scale = 1
		$Woufeuse/Collision.disabled = false

func _on_woufeuse_hit_reset_timeout():
	state["LifeWoufeuse"] = 3
func _on_vraisorcier_hit_reset_timeout():
	state["LifeVraisorcier"] = 3
func _on_woufeuse_ko_reset_timeout():
	state["Woufeuse"] = "recover"
func _on_vraisorcier_ko_reset_timeout():
	state["Vraisorcier"] = "recover"
