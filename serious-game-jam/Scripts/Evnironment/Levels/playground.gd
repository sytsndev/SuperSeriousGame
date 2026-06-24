class_name Playground
extends Node3D

@export var crowd_spawn_node: Node3D
@export var child_models: Array[String]
@export var crowd_member: PackedScene

var crowd_spawns: Array[Marker3D]


func _ready() -> void:
	for child in crowd_spawn_node.get_children():
		if child is Marker3D:
			crowd_spawns.append(child)
	setup_crowd()


func setup_crowd():
	Global.crowd_added.connect(spawn_child)
	var i = 0
	while i < Global.crowd:
		spawn_child(i)
		i += 1
		if i == Global.crowd:
			break


func spawn_child(index: int = -1):
	var instance = load(child_models[randi_range(1, child_models.size() - 1)]).instantiate()
	var animation_player: AnimationPlayer = instance.find_child("AnimationPlayer")
	var animation = animation_player.get_animation("idle")
	animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play("idle")
	if index >= 0:
		crowd_spawns[index].add_child(instance)
	else:
		for spawn in crowd_spawns:
			if spawn.get_child_count() == 0:
				spawn.add_child(instance)
