class_name Playground
extends Node3D

@export var crowd_spawn_node: Node3D
@export var crowd_member: PackedScene

var crowd_spawns: Array[Marker3D]


func _ready() -> void:
	for child in crowd_spawn_node.get_children():
		if child is Marker3D:
			crowd_spawns.append(child)
	setup_crowd()


func setup_crowd():
	var i = 0
	while i < Global.crowd:
		var instance = crowd_member.instantiate()
		crowd_spawns[i].add_child(instance)
		i += 1
		if i == Global.crowd:
			break
