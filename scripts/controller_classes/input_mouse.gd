extends Resource
class_name InputMouse

#@export var action:StringName : set=set_action
#func set_action(a:StringName):
#	assert(InputMap.has_action(a), "<InputMap> has no action called %s"%a)
#	action = a
@export_flags('active') var active:int = 1
func set_active(a:bool):active = int(a)
func get_active()->bool:return bool(active)
var check_every_frame:bool = false
func set_check_every_frame(v:bool)->void:check_every_frame = v
func get_check_every_frame()->bool:return check_every_frame

@export var thresholds:Array[ThresholdAbs] : get = get_thresholds, set = set_thresholds
func set_thresholds(t:Array[ThresholdAbs]):
	for td in t:
		if(td==null): td = ThresholdAbs.new()
		td.connect(&"just_above", Callable(self, &"emit_signal").bind(&"just_above", td.value))
		td.connect(&"just_below", Callable(self, &"emit_signal").bind(&"just_below", td.value))
	thresholds = t
	set_check_every_frame(!t.is_empty())
func get_thresholds()->Array:return thresholds
func append_thresholds(t:Array[ThresholdAbs]):
	var res:Array[ThresholdAbs] = get_thresholds()
	res.append_array(t)
	set_thresholds(res)
@warning_ignore("shadowed_variable")
func set_threshold_active(id:int, active:int):
	assert(id<thresholds.size() && id>0)
	thresholds[id].set_active(active)
signal just_above
signal just_below

@export var deadzone_in:int = 0 : set=set_deadzone_in, get=get_deadzone_in
@export var deadzone_out:int = 1 : set=set_deadzone_out, get=get_deadzone_out
func get_deadzone_in()->int:return deadzone_in
func set_deadzone_in(dz:int)->void:deadzone_in = dz if (dz<deadzone_out) else deadzone_in
func get_deadzone_out()->int:return deadzone_out
func set_deadzone_out(dz:int)->void:deadzone_out = dz if (dz>deadzone_in) else deadzone_out

var last:Vector2i = Vector2i()

func press()->Vector2i:
	var res:Vector2i = DisplayServer.mouse_get_position()
#	DisplayServer.warp_mouse()
#	var res:float = (clamp(Input.get_action_strength(action)-deadzone_in, 0.0, deadzone_out) / deadzone_out) * active
#	if(res==last): return res
#	for t in thresholds:
#		if(t.get_active()):t.test(res)
#	last = res
	return res
