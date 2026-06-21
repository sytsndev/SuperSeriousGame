class_name ShopItem3D
extends Node3D

enum ItemType { CHAIR_GREASE, OTHER }

@onready var disabled_mat: StandardMaterial3D = preload("res://Shaders/Materials/disabled_item.tres")

@export var item_type: ItemType 
@export var price: float = 5.0
@export var mesh: MeshInstance3D

var orig_mat: StandardMaterial3D
var item_disabled: bool = false

func _ready() -> void:
	orig_mat = mesh.get_active_material(0) as StandardMaterial3D


func _process(delta: float) -> void:
	if Global.money_tracker < price:
		item_disabled = true
		mesh.set_surface_override_material(0, disabled_mat)
	else:
		item_disabled = false
		mesh.set_surface_override_material(0, orig_mat)


func on_click():
	if item_disabled:
		return
	match item_type:
		ItemType.CHAIR_GREASE:
			Global.up_chair_grease_count += 1
			Global.money_tracker -= price
		ItemType.OTHER:
			print("other")
