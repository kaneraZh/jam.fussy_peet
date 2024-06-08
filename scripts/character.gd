extends CharacterBody3D
class_name RelativeBody3D

var move_towards:Vector2=Vector2() : get=get_move_towards, set=set_move_towards
func get_move_towards()->Vector2:return move_towards
func set_move_towards(v:Vector2)->void:move_towards = v

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_normal:Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector") : set=set_gravity_normal
func set_gravity_normal(normal:Vector3)->void:
	gravity_normal = normal.normalized() if (normal!=Vector3()) else ProjectSettings.get_setting("physics/3d/default_gravity_vector")
	print(gravity_normal)
var gravity_strength:float = ProjectSettings.get_setting("physics/3d/default_gravity") : set=set_gravity_strength
func set_gravity_strength(strength:float)->void:gravity_strength = strength
@export var relative:Node3D
func get_relative_basis()->Basis:
	var x:Vector3 = gravity_normal.cross(-relative.basis.z)
	var res:Basis = Basis(
		x,
		-gravity_normal,
		gravity_normal.cross(x)
	)
	return res
@export var SPEED = 5.0

const INPUT_MOV_F:StringName= &'mov_forward'
const INPUT_MOV_B:StringName= &'mov_backward'
const INPUT_MOV_L:StringName= &'mov_left'
const INPUT_MOV_R:StringName= &'mov_right'
func get_input_mov()->Vector2:
	return SPEED*Vector2(
		Input.get_action_strength(INPUT_MOV_R)-Input.get_action_strength(INPUT_MOV_L),
		Input.get_action_strength(INPUT_MOV_B)-Input.get_action_strength(INPUT_MOV_F)
	)

func _ready():
	assert(relative!=null, 'relative is null :(')

@export var relative_closest:float
@export var relative_furthest:float
@export var relative_position:Vector3
func _process(delta):
	var direction:Basis = Basis.looking_at(get_position()-relative.get_position(), -gravity_normal)
	relative.basis = direction
func _physics_process(delta):
	var move:Vector2 = get_input_mov()
	velocity+= get_relative_basis() * Vector3(move.x, 0.0, move.y)
	#if(move_towards):
		#velocity.x = move_towards.x * SPEED
		#velocity.z = move_towards.y * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, gravity_strength/SPEED)
		#velocity.z = move_toward(velocity.z, 0, gravity_strength/SPEED)
	velocity+= gravity_normal
	move_and_slide()
	relative.position = get_relative_basis() * relative_position+get_position()
