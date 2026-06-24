class_name ShopItem3D
extends Node3D

enum ItemType { CHAIR_GREASE, 
DELAYED_GRATIFICATION,
CROWD,
GHOST_KID,
PLAY,
EXIT,
SHOP,
OTHER }

@onready var disabled_mat: StandardMaterial3D = preload("res://Shaders/Materials/disabled_item.tres")

@export var camera_controller: CameraController
@export var item_type: ItemType 
@export var price: float = 5.0
@export var mesh_path: String
@export var init_rot: Vector3 = Vector3(0, 180, 0)
@export var price_increase: float
@export var shop_items: Array[ShopItem3D]
@export var menu_buttons: Array[ShopItem3D]
@export var shop_button: ShopItem3D

var blocked_mesh_path = "res://Assets/WIP/Upgrades/Blocked.glb"
var mesh: MeshInstance3D
var orig_mat: StandardMaterial3D
var item_disabled: bool = false
var item_blocked: bool = false

var shop_rotating: bool
var is_shop: bool = false
var start_game: bool = false

func _ready() -> void:
	if shop_items.size() > 0:
		for item in shop_items:
			item.item_disabled = true
			item.visible = false
			print(item)
	if shop_button:
		shop_button.item_disabled = true
		shop_button.visible = false
		print(shop_button)
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
	if !start_game:
		return
	if check_disabled() and !item_blocked:
		disable()
	else:
		enable()


func on_click():
	if item_disabled or shop_rotating or item_blocked:
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
		ItemType.GHOST_KID:
			Global.up_ghost_kid += 1
		ItemType.PLAY:
			play_game()
		ItemType.EXIT:
			get_tree().quit()
		ItemType.SHOP:
			toggle_shop_arrow()
			if is_shop:
				camera_controller.swap_camera("shop")
			else:
				camera_controller.swap_camera("chair")
		ItemType.OTHER:
			print("other")


func check_disabled():
	if Global.money_tracker < price or Global.money_tracker == 0.0:
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


func toggle_shop_arrow():
	is_shop = !is_shop
	shop_rotating = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_OUT)
	var rot = shop_button.rotation + Vector3(0,deg_to_rad(180),0)
	tween.tween_property(shop_button, "rotation", rot, .25)
	await tween.finished
	shop_rotating = false


func play_game():
	camera_controller.swap_camera("chair")
	await get_tree().create_timer(0.5).timeout
	for item in shop_items:
		item.visible = true
		item.start_game = true
	for button in menu_buttons:
		button.visible = false
		button.item_disabled = true
	shop_button.item_disabled = false
	shop_button.visible = true
	start_game = true
	Global.can_spin = true
