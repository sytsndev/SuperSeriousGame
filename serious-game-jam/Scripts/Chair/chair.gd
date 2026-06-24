class_name Chair
extends Node3D

@export var qte_controller: QTEController
@export var camera_chake: CameraShake

@export var path: String
@export var child: Node3D
var animation_player: AnimationPlayer

var chair_top: MeshInstance3D

var qte_impulse: float = 1080
var is_qte_active: bool = false

signal spins_complete

#Physics
var angular_velocity: float = 0.0 #current velocity in degrees/s
var is_spinning: bool = false
var accumulated_spins: float = 0.0 #total number of full 360 degree spins


func _ready() -> void:
	chair_top = get_node(path)
	qte_controller.active.connect(qte_active)
	animation_player = child.find_child("AnimationPlayer")


func spin_chair(force_override: float = -1.0):
	var force = force_override if force_override > 0.0 else Global.get_spin_force()
	angular_velocity = force
	accumulated_spins = 0.0
	is_spinning = true
	qte_controller.init_qte()
	var animation = animation_player.get_animation("spin")
	animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play("spin")


func _physics_process(delta: float) -> void:
	rotate_childe()
	if Global.can_spin:
		if Input.is_action_just_pressed("spin") and !is_spinning:
			spin_chair()
		elif Input.is_action_just_pressed("spin") and is_qte_active:
			#print()
			camera_chake.trigger_shake(handle_qte_success() * .01)
	spin(delta)
	
#func spin_duration_for_amount(spin_amount: float) -> float:
	#var base_spin: float = 360.0
	#var base_time: float = 1.2
#
	#var ratio = spin_amount / base_spin
#
	## Try exponents: 0.3, 0.4, 0.5, etc.
	#var exponent = 0.4
	#var duration = base_time * pow(ratio, exponent)
#
	## Optional clamp
	#duration = clamp(duration, base_time * 0.8, base_time * 4.0)
#
	#return duration

func spin(delta: float):
	if not is_spinning:
		return
		
	#speed at end of frame, after friction
	var next_velocity = angular_velocity - Global.get_friction() * delta
		
	#average start and end speed -> exact for constant deceleration
	var step = (angular_velocity + next_velocity) * 0.5 * delta
	chair_top.rotate_y(deg_to_rad(step))
	accumulated_spins += step
	angular_velocity = next_velocity
		
	if angular_velocity <= 0.0:
		angular_velocity = 0.0
		is_spinning = false
		end_spin_actions(accumulated_spins)
		animation_player.stop()


func end_spin_actions(barf: float):
	Global.add_to_barf_tracker(barf)
	Global.add_money()
	spins_complete.emit()


func qte_active(active: bool):
	is_qte_active = active


func handle_qte_success():
	angular_velocity = qte_impulse
	return qte_controller.qte_success()


func rotate_childe():
	child.global_rotation = chair_top.global_rotation 
