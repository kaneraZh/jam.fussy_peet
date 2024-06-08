extends Node

#var player:PhysicsBody3D : set=set_player, get=get_player
#func get_player()->PhysicsBody3D:return player
#func set_player(v:PhysicsBody3D)->void:
	#player = v
	#player.set_physical_form($Area3D)

#func _ready():
#	set_player($CharacterBody3D)
#
