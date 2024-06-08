extends CharacterBody3D

@export_category('Physics Materials')
@export_group('moving', 'moving')
@export var moving_material:PhysicsMaterial = PhysicsMaterial.new()
@export_exp_easing("inout", ) var moving_mass:float = 1.0
@export_range(-128.0, 128.0) var moving_gravity_scale:float = 1.0
@export_group('stopped', 'stopped')
@export var stopped_material:PhysicsMaterial = PhysicsMaterial.new()
@export_exp_easing("inout") var stopped_mass:float = 1.0
@export_range(-128.0, 128.0) var stopped_gravity_scale:float = 1.0
@export_group('aerial', 'aerial')
@export var aerial_material:PhysicsMaterial = PhysicsMaterial.new()
@export_exp_easing("inout") var aerial_mass:float = 1.0
@export_range(-128.0, 128.0) var aerial_gravity_scale:float = 1.0
#@export_group('', '')
#@export var _material:PhysicsMaterial = PhysicsMaterial.new()
#@export_exp_easing("inout") var _mass:float = 1.0
#@export_range(-128.0, 128.0) var _gravity_scale:float = 1.0

#@export_category('Controls')
#var controller:Controller : set=set_controller, get=get_controller
#func get_controller()->Controller:return controller
#func set_controller(v:Controller)->void:
#	if(is_instance_valid(controller)):controller.queue_free()
#	controller = v
#	add_child(controller)
#@export var stick_movement:Analog2D : set=set_stick_movement, get=get_stick_movement
#func get_stick_movement()->Analog2D:return stick_movement
#func set_stick_movement(v:Analog2D)->void:
#	stick_movement = v
#	stick_movement.connect(&"just_above", Callable(self, &"on_movement_above"))
#	stick_movement.connect(&"just_below", Callable(self, &"on_movement_below"))
#	controller.add_group(stick_movement)
var movement_dash:bool = false
var movement_stop:bool = false
#func on_movement_above(threshold:float):
#	movement_dash = threshold==0.3
#	#print_debug('dash')
#	#set_physics_material_override(moving_material)
#	#set_gravity_scale(moving_gravity_scale)
#	#set_mass(moving_mass)
#func on_movement_below(threshold:float):
#	movement_stop = threshold==0.1
#	#print_debug('stop')
#	#set_physics_material_override(stopped_material)
#	#set_gravity_scale(stopped_gravity_scale)
#	#set_mass(stopped_mass)
#@export var stick_camera:Analog2D : set=set_stick_camera, get=get_stick_camera
#func get_stick_camera()->Analog2D:return stick_camera
#func set_stick_camera(v:Analog2D)->void:
#	stick_camera = v
#	controller.add_group(stick_camera)
#@export var btn_gdash:Binary : set=set_btn_gdash, get=get_btn_gdash
#func get_btn_gdash()->Binary:return btn_gdash
#func set_btn_gdash(v:Binary)->void:
#	btn_gdash = v
#	controller.add_button(btn_gdash)
#	btn_gdash.connect("just_pressed", Callable(self, "_on_gdash_just_pressed"))
var dash_queue:bool = false
#func _on_gdash_just_pressed():dash_queue = true
##@export var jump:Binary : set=set_jump, get=get_jump
##func get_jump()->Binary:return jump
##func set_jump(v:Binary)->void:
##	jump = v
##	controller.add_button(jump)
#@export var btn_lock:Binary : set=set_btn_lock, get=get_btn_lock
#func get_btn_lock()->Binary:return btn_lock
#func set_btn_lock(v:Binary)->void:
#	btn_lock = v
#	controller.add_button(btn_lock)
## btn_lock makes camera stick become dash influence stick?

signal just_context
signal just_dashed
const INPUT_CONTEXT:StringName = &'context'
const INPUT_DASH:StringName	= &'dash'
const INPUT_LOCK:StringName	= &'lock'
func _unhandled_input(event:InputEvent):
	if(event.is_action_pressed(INPUT_DASH)):
		if(Input.is_action_just_pressed(INPUT_DASH)):emit_signal('just_dashed')
	if(event.is_action_pressed(INPUT_CONTEXT)):
		if(Input.is_action_just_pressed(INPUT_CONTEXT)):emit_signal('just_context')
const INPUT_MOV_F:StringName= &'mov_foward'
const INPUT_MOV_B:StringName= &'mov_backward'
const INPUT_MOV_L:StringName= &'mov_left'
const INPUT_MOV_R:StringName= &'mov_right'
func get_input_mov()->Vector2:
	return Vector2(
		Input.get_action_strength(INPUT_MOV_R)-Input.get_action_strength(INPUT_MOV_L),
		Input.get_action_strength(INPUT_MOV_F)-Input.get_action_strength(INPUT_MOV_B)
	)
const INPUT_CAM_U:StringName= &'cam_up'
const INPUT_CAM_D:StringName= &'cam_down'
const INPUT_CAM_L:StringName= &'cam_left'
const INPUT_CAM_R:StringName= &'cam_right'
func get_input_cam()->Vector2:
	return Vector2(
		Input.get_action_strength(INPUT_CAM_U)-Input.get_action_strength(INPUT_CAM_D),
		Input.get_action_strength(INPUT_CAM_R)-Input.get_action_strength(INPUT_CAM_L)
	)

const GDASH_SPEED:float = 10.0
const MOVEMENT_STOP:float = 0.0
const MOVEMENT_START:float = 20.0
const MOVEMENT_SPEED:float = 20.0
const MOVEMENT_SPEED_LIMIT:float = 15.0
const MOVEMENT_SPEED_LIMIT_SQUARED:float = pow(MOVEMENT_SPEED_LIMIT, 2.0)

const VELOCITY_TERMINAL:float = 20.0
#var direction:Vector3 = Vector3.FORWARD
var gravity_direction:Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var gravity_intensity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
var physical_form:Node3D : set=set_physical_form
func set_physical_form(v:Node3D)->void:
	if(is_instance_valid(physical_form)):physical_form.queue_free()
	physical_form = v
func _update_physical_form()->void:
	if(!is_instance_valid(physical_form)):return
	#var b:Basis = get_basis()
	#@warning_ignore("static_called_on_instance")
	physical_form.set_basis( get_basis() )
	physical_form.set_position( get_position() )
var camera:Camera3D : set=set_camera
func set_camera(v:Camera3D)->void:
	camera = v
var floor:bool = false
var inertia:Vector3
#func _physics_process(_delta:float):
#	#if(!floor):
#	#	velocity+= gravity_direction*gravity_intensity
#	
#	var input_analog:Vector2 = stick_movement.press()
#	var self_basis:Basis = get_basis()
#	var input_movement:Vector3 = Vector3(input_analog.x, 0.0, input_analog.y)*self_basis
#	if( velocity.length_squared()<MOVEMENT_SPEED_LIMIT_SQUARED ):
#		if(movement_dash):
#			movement_dash = false
#			velocity+= input_movement.normalized()*MOVEMENT_START
#		velocity = input_movement * MOVEMENT_SPEED
#	#if( movement_stop ):
#	#	movement_stop = false
#	#	apply_impulse()
#		set_basis(self_basis.slerp(self_basis.looking_at(input_movement, self_basis.y), 0.7))
#	#	self.direction = direction.normalized()
#	else:
#		velocity = velocity.slerp(Vector3(0.0, velocity.y, 0.0), 0.7)
#	if(dash_queue):
#		dash_queue = false
#		velocity+= self_basis.x*GDASH_SPEED
#	move_and_slide()
#	#apply_force(velocity)
#	_update_physical_form()

func _integrate_forces(state: PhysicsDirectBodyState3D):
	pass

func _init():
	set_controller(Controller.new())
