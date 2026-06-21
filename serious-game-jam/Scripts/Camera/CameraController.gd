class_name CameraController
extends Camera3D


@export var chair_cam_pos: Marker3D
@export var shop_cam_pos: Marker3D

var curr_camera: String
var curr_hover_item: ShopItem3D = null
var last_hover_area: Area3D = null
var original_hover_scale: Vector3 = Vector3.ONE
var start_pos: Vector3
var end_pos: Vector3

@export var hover_offset: float = 0.02
@export var hover_scale: float = 1.01

var ray_length: float = 100.0


func _ready() -> void:
	global_position = chair_cam_pos.global_position
	global_rotation = chair_cam_pos.global_rotation
	
	curr_camera = "chair"


func _input(event):
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		_update_ray_and_check_collision()
	if Input.is_action_just_pressed("action_1"):
		if curr_hover_item:
			curr_hover_item.on_click()


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


func _update_ray_and_check_collision():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = project_ray_origin(mouse_pos)
	var ray_normal = project_ray_normal(mouse_pos)
	var ray_end = ray_origin + ray_normal * ray_length

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)

	query.collide_with_bodies = true	
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	var new_hover_area: Area3D = null

	if not result.is_empty():
		var collider = result.collider
		if collider is Node3D:
			var obj: Node3D = collider
			if obj is Area3D:
				new_hover_area = obj
			elif obj.get_parent() is Area3D:
				new_hover_area = obj.get_parent() as Area3D

	if new_hover_area and new_hover_area != last_hover_area:
		if last_hover_area and curr_hover_item:
			reset_hover_item()

		last_hover_area = new_hover_area
		curr_hover_item = new_hover_area.get_parent()
		if curr_hover_item:
			end_pos = Vector3(curr_hover_item.global_position.x, curr_hover_item.global_position.y + hover_offset, curr_hover_item.global_position.z)
			start_pos = curr_hover_item.global_position
			hover_item()

	elif not new_hover_area and last_hover_area:
		if curr_hover_item:
			reset_hover_item()
		curr_hover_item = null
		last_hover_area = null


func hover_item():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	original_hover_scale = curr_hover_item.scale
	print(end_pos)
	tween.tween_property(curr_hover_item, "global_position", end_pos, 0.1)


func reset_hover_item():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(curr_hover_item, "global_position", start_pos, 0.1)
