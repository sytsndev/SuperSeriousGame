class_name CameraShake
extends Node3D

@export var shake_strength := 0.15
@export var shake_time := 0.12

var shake_timer := 0.0
var base_pos := Vector3.ZERO

func _ready():
	base_pos = position

func trigger_shake(strength_mult: float):
	if shake_strength <= 0.10:
		shake_strength = strength_mult 
	shake_timer = shake_time

func _process(delta):
	if shake_timer > 0.0:
		shake_timer -= delta
		position = base_pos + Vector3(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		position = base_pos
