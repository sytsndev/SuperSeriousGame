class_name GhostKid
extends Node3D


@export var chair: Chair

var orig_pos: Vector3
var orig_rot: Vector3


signal ghost_anim_fin


func _ready() -> void:
	orig_pos = position
	orig_rot = rotation


func play_ghost_save():
	visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	var pos = Vector3(position.x, position.y + 1, position.z)
	var rot = Vector3(rotation.x, position.y + deg_to_rad(-2160.0), position.z)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", pos, 3.0)
	tween.tween_property(self, "rotation", rot, 3.0)
	await tween.finished
	print("allow_ghost_input")
	ghost_anim_fin.emit()
	visible = false
	position = orig_pos
	rotation = orig_rot
