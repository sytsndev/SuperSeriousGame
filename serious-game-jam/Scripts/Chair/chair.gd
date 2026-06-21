class_name Chair
extends Node3D


@export var path: String

var chair_top: MeshInstance3D
signal add_money_signal
signal spins_complete

#Physics
var angular_velocity: float = 0.0 #current velocity in degrees/s
var is_spinning: bool = false
var accumulated_spins: float = 0.0 #total number of full 360 degree spins


func _ready() -> void:
	chair_top = get_node(path)


func spin_chair(force_override: float = -1.0):
	var force = force_override if force_override > 0.0 else Global.get_spin_force()
	angular_velocity = force
	accumulated_spins = 0.0
	is_spinning = true
	
func _physics_process(delta: float) -> void:
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
		print(accumulated_spins)
		
#block-comment
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


func end_spin_actions(barf: float):
	Global.add_to_barf_tracker(barf)
	add_money_signal.emit()
	spins_complete.emit()
