class_name ShopItem3D
extends Node3D

enum ItemType { CHAIR_GREASE, 
DELAYED_GRATIFICATION,
CROWD,
OTHER }

@onready var disabled_mat: StandardMaterial3D = preload("res://Shaders/Materials/disabled_item.tres")

@export var item_type: ItemType 
@export var price: float = 5.0
@export var mesh_path: String
@export var init_rot: Vector3 = Vector3(0, 180, 0)
@export var price_increase: float

var blocked_mesh_path = "res://Assets/WIP/Upgrades/Blocked.glb"
var mesh: MeshInstance3D
var orig_mat: StandardMaterial3D
var item_disabled: bool = false
var item_blocked: bool = false

func _ready() -> void:
	var loaded_path = load(mesh_path)
	var instance = loaded_path.instantiate()
	instance.rotation = init_rot
	add_child(instance)
	var mesh_child: MeshInstance3D = null
	for child in instance.get_children():
		if child is MeshInstance3D:
			mesh_child = child

	if mesh_child:
		mesh = mesh_child
		orig_mat = mesh_child.get_active_material(0) as StandardMaterial3D


func _process(delta: float) -> void:
	if check_disabled() and !item_blocked:
		disable()
	else:
		enable()


func on_click():
	if item_disabled:
		return
	match item_type:
		ItemType.CHAIR_GREASE:
			Global.up_chair_grease_count += 1
			Global.money_tracker -= price
		ItemType.DELAYED_GRATIFICATION:
			Global.up_delayed_gratification += 1
			Global.barf_max += Global.mult_barf_increase_delayed_gratification
			Global.money_tracker -= price
		ItemType.CROWD:
			Global.add_crowd()
			Global.money_tracker -= price
		ItemType.OTHER:
			print("other")


func check_disabled():
	if Global.money_tracker < price:
		return true
	match item_type:
		ItemType.CROWD:
			if Global.crowd >= Global.crowd_max:
				block_item()
				return true


func disable():
	item_disabled = true
	for i in range(mesh.get_surface_override_material_count()):
		mesh.set_surface_override_material(i, disabled_mat)


func enable():
	item_disabled = false
	for i in range(mesh.get_surface_override_material_count()):
		mesh.set_surface_override_material(i, orig_mat)


func block_item():
	item_blocked = true
	var loaded_path = load(blocked_mesh_path)
	var instance = loaded_path.instantiate()
	instance.rotate_y(deg_to_rad(90))
	mesh.visible = false
	add_child(instance)
	
