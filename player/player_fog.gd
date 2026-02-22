class_name PlayerFog
extends FogVolume

func _process(_delta: float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	var to_camera: Vector3 = camera.global_position - global_position
	if to_camera.length_squared() <= 0.000001:
		return

	var y_axis: Vector3 = to_camera.normalized()
	var reference_axis: Vector3 = Vector3.FORWARD
	if abs(y_axis.dot(reference_axis)) > 0.99:
		reference_axis = Vector3.RIGHT

	var x_axis: Vector3 = reference_axis.cross(y_axis).normalized()
	var z_axis: Vector3 = x_axis.cross(y_axis).normalized()
	global_basis = Basis(x_axis, y_axis, z_axis)
