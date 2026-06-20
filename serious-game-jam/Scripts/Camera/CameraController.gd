class_name CameraController
extends Camera3D


@export var chair_cam_pos: Marker3D
@export var shop_cam_pos: Marker3D

var curr_camera: String


func _ready() -> void:
	global_position = chair_cam_pos.global_position
	global_rotation = chair_cam_pos.global_rotation
	curr_camera = "chair"


func swap_camera(camera_pos: String):
	match camera_pos:
		"chair":
			curr_camera = "chair"
			move_camera(chair_cam_pos.global_position, chair_cam_pos.global_rotation)
		"shop":
			curr_camera = "shop"
			move_camera(shop_cam_pos.global_position, shop_cam_pos.global_rotation)



func move_camera(pos: Vector3, rot: Vector3):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_OUT)

	tween.set_parallel(true)
	tween.tween_property(self, "global_position", pos, .5)
	tween.tween_property(self, "global_rotation", rot, .5)
