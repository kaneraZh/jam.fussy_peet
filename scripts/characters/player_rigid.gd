extends RigidBody3D

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

@export_category('Controls')
var controller:Controller : set=set_controller, get=get_controller
func get_controller()->Controller:return controller
func set_controller(v:Controller)->void:
	if(is_instance_valid(controller)):controller.queue_free()
	controller = v
	add_child(controller)
@export var movement:Analog2D : set=set_movement, get=get_movement
func get_movement()->Analog2D:return movement
func set_movement(v:Analog2D)->void:
	movement = v
	movement.connect(&"just_above", Callable(self, &"on_movement_above"))
	movement.connect(&"just_below", Callable(self, &"on_movement_below"))
	controller.add_group(movement)
var movement_dash:bool = false
var movement_stop:bool = false
func on_movement_above(threshold:float):
	movement_dash = threshold==0.3
#	print_debug('dash')
	set_physics_material_override(moving_material)
	set_gravity_scale(moving_gravity_scale)
	set_mass(moving_mass)
func on_movement_below(threshold:float):
	movement_stop = threshold==0.1
#	print_debug('stop')
	set_physics_material_override(stopped_material)
	set_gravity_scale(stopped_gravity_scale)
	set_mass(stopped_mass)
@export var camera:Analog2D : set=set_camera, get=get_camera
func get_camera()->Analog2D:return camera
func set_camera(v:Analog2D)->void:
	camera = v
	controller.add_group(camera)
@export var gdash:Binary : set=set_gdash, get=get_gdash
func get_gdash()->Binary:return gdash
func set_gdash(v:Binary)->void:
	gdash = v
	controller.add_button(gdash)
	gdash.connect("just_pressed", Callable(self, "_on_just_pressed"))
var dash_queue:bool = false
func _on_just_pressed():dash_queue = true
#@export var jump:Binary : set=set_jump, get=get_jump
#func get_jump()->Binary:return jump
#func set_jump(v:Binary)->void:
#	jump = v
#	controller.add_button(jump)
@export var lock:Binary : set=set_lock, get=get_lock
func get_lock()->Binary:return lock
func set_lock(v:Binary)->void:
	lock = v
	controller.add_button(lock)
# lock makes camera stick become dash influence stick?

const SPEED_GDASH:float = 10.0
const MOVEMENT_STOP:float = 0.0
const MOVEMENT_START:float = 20.0
const MOVEMENT_SPEED:float = 20.0
const MOVEMENT_SPEED_LIMIT:float = 15.0
const MOVEMENT_SPEED_LIMIT_SQUARED:float = pow(MOVEMENT_SPEED_LIMIT, 2.0)

const VELOCITY_TERMINAL:float = 20.0
var direction:Vector3 = Vector3.FORWARD
var gravity_direction:Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var gravity_intensity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
var physical_form:Node3D
func set_physical_form(v:Node3D)->void:
	if(is_instance_valid(physical_form)):physical_form.queue_free()
	physical_form = v
func _update_physical_form()->void:
	if(!is_instance_valid(physical_form)):return
#	var b:Basis = get_basis()
#	@warning_ignore("static_called_on_instance")
	physical_form.set_basis( get_basis().looking_at(-direction) )
	physical_form.set_position( get_position() )
var floor:bool = false
func _physics_process(_delta:float):
#	if(!floor):
#		velocity+= gravity_direction*gravity_intensity
	
	var input_analog:Vector2 = movement.press()
	var input_movement:Vector3 = Vector3(input_analog.x, 0.0, input_analog.y)*get_basis()
	
#	transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	var velocity:Vector3 = Vector3()
	if( get_inertia().length_squared()<MOVEMENT_SPEED_LIMIT_SQUARED ):
		if(movement_dash):
			movement_dash = false
			apply_central_impulse(input_movement.normalized()*MOVEMENT_START)
		velocity = input_movement * MOVEMENT_SPEED
#	if( movement_stop ):
#		movement_stop = false
#		apply_impulse()
	
#		self.direction = direction.normalized()
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED_MOVEMENT)
#		velocity.z = move_toward(velocity.z, 0, SPEED_MOVEMENT)
#	if(dash_queue):
#		dash_queue = false
#		velocity+= self.direction.normalized()*SPEED_GDASH
#	move_and_slide()
	apply_force(velocity)
	_update_physical_form()

func _integrate_forces(state: PhysicsDirectBodyState3D):
	pass

func _init():
	set_controller(Controller.new())
