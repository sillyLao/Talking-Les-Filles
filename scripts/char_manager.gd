extends Node

@onready var Main = $".."
@onready var AudioManager = $"../AudioManager"

var state : Dictionary = {
	"Woufeuse": "idle",
	"Vraisorcier": "idle",
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
				fille.linear_velocity = Vector3.ZERO
				fille.angular_velocity = Vector3.ZERO
				fille.rotation.x = move_toward(fille.rotation.x, 0, ((fille.rotation.x/10)+5)*delta)
				var vel : Vector3 = fille.linear_velocity
				print(vel)
				if vel.y < 0.01:
					state[fname] = "idle"
					fille.gravity_scale = 1
					fille.get_node("Collision").disabled = false
			"grabbed":
				fille.gravity_scale = 1
				fille.get_node("Collision").disabled = false
				
		if not state[fname] == "ko":
			fille.rotation.y = 0
			fille.rotation.z = 0
			fille.position.x = default_x
			fille.position.y = clamp(fille.position.y, 1.35-(abs(sin(fille.rotation.z)*0.35)), 5)
			fille.position.z = clamp(fille.position.z, -1.1, 2.2)
			
		var vel : Vector3 = fille.linear_velocity
		var ang : Vector3 = fille.angular_velocity
		if abs((vel.x+vel.y+vel.z)/3) < 0.01 and abs((ang.x+ang.y+ang.z)/3) < 0.01:
			fille.linear_velocity = Vector3.ZERO
			if not state[fname] in ["speak", "grabbed", "held", "recover"]:
				state[fname] = "idle"


func hit(fille : RigidBody3D) -> void:
	fille.get_node("Animation"+fille.name).play("hit")
	AudioManager.get_node("Punch").play()

func _on_animation_woufeuse_animation_finished(anim_name):
	anim_finished($Woufeuse, anim_name)
func _on_animation_vraisorcier_animation_finished(anim_name):
	anim_finished($Vraisorcier, anim_name)

func anim_finished(fille:RigidBody3D, anim_name:String):
	match anim_name:
		"hit":
			state[fille.name] = "idle"

func _on_vraisorcier_body_entered(body):
	if body in [$"../Floor"] and not state["Vraisorcier"] in ["recover", "held", "grabbed"]:
		$Vraisorcier/RagdollReset.start()
func _on_woufeuse_body_entered(body):
	if body in [$"../Floor"] and not state["Woufeuse"] in ["recover", "held", "grabbed"]:
		$Woufeuse/RagdollReset.start()
func _on_vraisorcier_ragdoll_reset_timeout():
	if not state["Vraisorcier"] in ["grabbed", "falling"]:
		state["Vraisorcier"] = "recover"
		$Vraisorcier.gravity_scale = 0
		$Vraisorcier/Collision.disabled = true
func _on_woufeuse_ragdoll_reset_timeout():
	if not state["Woufeuse"] in ["grabbed", "falling"]:
		state["Woufeuse"] = "recover"
		$Woufeuse.gravity_scale = 0
		$Woufeuse/Collision.disabled = true
