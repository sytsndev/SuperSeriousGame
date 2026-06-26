class_name ShopItem3D
extends Node3D

enum ItemType { CHAIR_GREASE, 
DELAYED_GRATIFICATION,
CROWD,
GHOST_KID,
MULTIPLIER,
PLAY,
EXIT,
SHOP,
OTHER }

@onready var disabled_mat: StandardMaterial3D = preload("res://Shaders/Materials/disabled_item.tres")
@export var name_label: Label3D
@export var camera_controller: CameraController
@export var item_name: String
@export var item_info: String
@export var item_type: ItemType 
@export var price: float = 5.0
@export var max_up: int ## Used to limit the amount of upgrades
@export var mesh_path: String
@export var init_rot: Vector3 = Vector3(0, 180, 0)
@export var price_increase: float
@export var shop_items: Array[ShopItem3D]
@export var menu_buttons: Array[ShopItem3D]
@export var shop_button: ShopItem3D
@export var show_hover_tip: bool
@export var has_info: bool = true
@export var info_pos: Vector3 = Vector3(0.037, 0.348, 0.14)
@export var hover_sound: AudioStreamPlayer3D

var blocked_mesh_path = "res://Assets/WIP/Upgrades/Blocked.glb"
var mesh: MeshInstance3D
var orig_mat: StandardMaterial3D
var item_disabled: bool = false
var item_blocked: bool = false

var shop_rotating: bool
var is_shop: bool = false
var start_game: bool = false
var init_pos: Vector3
var selected_info: bool = false
var hover_disabled: bool = false


func _ready() -> void:
	hover_sound.pitch_scale = 0.7
	if item_type == ItemType.SHOP:
		hover_disabled = true
	Global.put_down_info_item.connect(put_down_info_item)
	init_pos = self.position
	name_label = %DisplayName
	if item_name:
		name_label.text = item_name
	if shop_items.size() > 0:
		for item in shop_items:
			item.item_disabled = true
			item.visible = false
			item.position.y -= 1
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
	set_item_name()
	if item_type == ItemType.PLAY or item_type == ItemType.EXIT:
		name_label.visible = true 
	if Global.disable_all_shop_items:
		selected_info = true
		name_label.visible = false
		shop_button.visible = false
	if !Global.disable_all_shop_items:
		selected_info = false
		if start_game:
			shop_button.visible = true
	if !start_game:
		return
	if check_disabled() and !item_blocked:
		if !Global.disable_all_shop_items:
			disable()
	else:
		enable()


func set_item_name():
	if item_type == ItemType.PLAY or item_type == ItemType.EXIT:
		name_label.text = item_name
	else:
		var name = item_name + " (" + str(Global.get_up_count(item_name)) + ")"
		name_label.text = "%s\n$%s" % [name, price]


func on_click():
	if item_disabled or shop_rotating or item_blocked:
		return
	match item_type:
		ItemType.CHAIR_GREASE:
			Global.add_chair_grease()
			Global.money_tracker -= price
		ItemType.DELAYED_GRATIFICATION:
			Global.up_delayed_gratification += 1
			Global.barf_max += Global.mult_barf_increase_delayed_gratification
			Global.money_tracker -= price
		ItemType.CROWD:
			Global.add_crowd()
			Global.money_tracker -= price
		ItemType.MULTIPLIER:
			Global.add_mutliplier()
			Global.money_tracker -= price
			get_price()
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

func on_left_click():
	if !has_info or Global.disable_all_shop_items or !start_game:
		return
	pickup_info_item()


func pickup_info_item():
	Global.disable_all_shop_items = true
	for i in range(mesh.get_surface_override_material_count()):
		mesh.set_surface_override_material(i, orig_mat)
	camera_controller.player_ui.show_info_label(item_info)
	selected_info = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "position", info_pos, 0.25)


func put_down_info_item():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "position", init_pos, 0.25)
	await tween.finished
	Global.disable_all_shop_items = false
	selected_info = false
	

func check_disabled():
	if Global.money_tracker < price or Global.money_tracker == 0.0:
		return true
	match item_type:
		ItemType.CROWD:
			if Global.crowd >= max_up:
				block_item()
				return true
		ItemType.CHAIR_GREASE:
			if Global.up_chair_grease_count >= max_up:
				block_item()
				return true
		ItemType.DELAYED_GRATIFICATION:
			if Global.up_delayed_gratification >= max_up:
				block_item()
				return true
		ItemType.GHOST_KID:
			if Global.up_delayed_gratification >= max_up:
				block_item()
				return true
		ItemType.MULTIPLIER:
			if Global.up_multiplier >= max_up:
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
		item.position.y += 1
	for button in menu_buttons:
		button.visible = false
		button.item_disabled = true
	shop_button.item_disabled = false
	shop_button.visible = true
	start_game = true
	Global.can_spin = true


func get_price():
		if Global.up_multiplier == 0:
			price = 5.0
		elif Global.up_multiplier == 1:
			price = 100.0
		else:
			price += 50


func play_hover_sound():
	var pitch_change = randi_range(-0.1, 0.1)
	hover_sound.pitch_scale += pitch_change
	hover_sound.play()
