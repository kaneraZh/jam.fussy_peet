extends Area3D
class_name AreaGravity3D

@export_enum('keep gravity', 'default gravity') var on_exit:int = 0
func _ready():
	connect("body_entered",Callable(self, &'_on_body_entered'))
	if(on_exit == 1): connect("body_exited", Callable(self, &'_on_body_exited'))

func _on_body_entered(v:Node3D):
	var gravity_vector:Vector3 = get_gravity_direction()*get_transform().basis.inverse() if !is_gravity_a_point() else ( v.get_position()-get_gravity_point_center()+get_position() ).normalized()
	if(v is RelativeBody3D): v.set_gravity_normal( gravity_vector )
func _on_body_exited(v:Node3D):
	if(v is RelativeBody3D): v.set_gravity_normal( Vector3() )
