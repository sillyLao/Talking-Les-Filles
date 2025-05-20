extends Node

@onready var Main = $".."
@onready var AudioManager = $"../AudioManager"

var state : Dictionary = {
	"Woufeuse": "idle",
	"Vraisorcier": "idle"
}
var default_x : float
var held_params : Array = []

func _ready():
	default_x = $Woufeuse.position.x

func _physics_process(delta):
	for fille:RigidBody3D in [$Woufeuse, $Vraisorcier]:
		fille.rotation.y = 0
		fille.rotation.z = 0
		fille.position.x = default_x
		fille.linear_velocity.x = 0.0
		
		var fname = fille.name
		var fsprite = fille.get_node("Sprite")
		
		match state[fname]:
			"idle":
				fsprite.play("idle")
				if fille.get_node("RagdollReset").is_stopped():
					fille.rotation.x = move_toward(fille.rotation.x, 0, ((fille.rotation.x/10)+5)*delta)
			"speak":
				if AudioManager.output_power_woufeuse > AudioManager.threshold:
					fsprite.play("speak")
				else:
					fsprite.play("idle")
					
		var vel : Vector3 = fille.linear_velocity
		if abs((vel.x+vel.y+vel.z)/3) < 0.0001:
			fille.linear_velocity = Vector3.ZERO
			if not state[fname] in ["speak", "grabbed", "held"]:
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
