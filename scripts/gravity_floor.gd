extends StaticBody3D


class _Planes:
	var normal:Vector3
	var edges:PackedVector3Array
func _ready():
	var shape:CollisionShape3D = $CollisionShape3D.get_shape()
	match shape.get_class():
		"ConcavePolygonShape3D":
			shape.get_faces()
			# load faces as as little planes as possible
		#"BoxShape3D"			:pass
		#"CapsuleShape3D"		:pass
		#"ConvexPolygonShape3D"	:pass
		#"CylinderShape3D"		:pass
		#"HeightMapShape3D"		:pass
		#"SeparationRayShape3D"	:pass
		#"SphereShape3D"		:pass
		#"WorldBoundaryShape3D"	:pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# func raycast from spot to valid planes
# valid planes has 2 filters:
## bounding box from spot, this bounding box is generousley big
## distance from planes is determined by closest spot between the 2 closest vectors of that plane
# valid plane distance has to be less than X, where X is a ProjectSettings
# per plane, the raycast is to the middle of closest 3 vectors
# + return raycasts that have no terrain collision between the spot and the plane
