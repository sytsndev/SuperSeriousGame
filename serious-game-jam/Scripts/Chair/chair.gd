class_name Chair
extends Node3D

@export var qte_controller: QTEController
@export var camera_shake: CameraShake
@export var mult_sound: AudioStreamPlayer3D
@export var chair_spin_sound: AudioStreamPlayer3D
@export var ghost_kid: GhostKid

@export var path: String
@export var child: Node3D
var animation_player: AnimationPlayer

var chair_top: MeshInstance3D

var qte_impulse: float = Global.base_spin_force
var is_qte_active: bool = false
var qte_finished: bool = false

var shake_mult: float = 1.0
var ghost_save: bool = false
var allow_ghost_input: bool = false

signal spins_complete
signal sig_ghost_save

#Physics
var angular_velocity: float = 0.0 #current velocity in degrees/s
var is_spinning: bool = false
var accumulated_spins: float = 0.0 #total number of full 360 degree spins
var spin_pitch: float = 1.0

func _ready() -> void:
	chair_top = get_node(path)
	qte_controller.active.connect(qte_active)
	qte_controller.ghost_save.connect(on_ghost_save) 
	animation_player = child.find_child("AnimationPlayer")
	Global.mult_increase.connect(multiplier_increase)
	spin_pitch = 1.0
	ghost_kid.ghost_anim_fin.connect(ghost_kid_anim_fin)
	var animation = animation_player.get_animation("sit")
	animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play("sit")


func spin_chair(force_override: float = -1.0):
	var force = force_override if force_override > 0.0 else Global.get_spin_force()
	angular_velocity = force
	accumulated_spins = 0.0
	is_spinning = true
	qte_finished = false
	qte_controller.init_qte()
	var animation = animation_player.get_animation("spin")
	animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play("spin")


func _physics_process(delta: float) -> void:
	chair_spin_sound.volume_db += Global.get_chair_audio()
	mult_sound.volume_db += Global.get_mult_audio() 
	if qte_finished and !is_spinning:
		qte_finished = false
	rotate_childe()
	if (Global.can_spin and !qte_finished and Input.is_action_just_pressed("spin") and !ghost_save):
		if not is_spinning:
			spin_chair()
		elif is_qte_active:
			camera_shake.trigger_shake(shake_mult * 0.01)
			mult_sound.play()
			handle_qte_success()
		else:
			var ghost_chance = Global.roll_ghost_kid_save()
			if ghost_chance:
				perform_save()
			else:
				handle_qte_failure()  
	elif  ghost_save and allow_ghost_input and Input.is_action_just_pressed("spin"):
		if ghost_save:
			spin_chair()
			ghost_save = false
			sig_ghost_save.emit(false, true)
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

	var next_velocity = angular_velocity - Global.get_friction() * delta
	var step = (angular_velocity + next_velocity) * 0.5 * delta

	chair_top.rotate_y(deg_to_rad(step))
	Global.add_to_barf_tracker(step)
	accumulated_spins += step

	var speed_ratio = clamp(angular_velocity / 360.0, 0.0, 1.0)
	chair_spin_sound.volume_db = lerp(-35.0 + Global.audio_adjust , -20.0 + Global.audio_adjust , speed_ratio)

	if not chair_spin_sound.playing:
		chair_spin_sound.play()

	angular_velocity = next_velocity

	if angular_velocity <= 0.0:
		angular_velocity = 0.0
		is_spinning = false
		if !ghost_save:
			end_spin_actions(accumulated_spins)
		animation_player.stop()


func end_spin_actions(barf: float):
	#Global.add_to_barf_tracker(barf)
	Global.add_money()
	Global.clear_mult()
	shake_mult = 1
	spin_pitch = 1.0
	spins_complete.emit()
	ghost_save = false
	allow_ghost_input = false
	animation_player.play("sit")


func on_ghost_save(success_count: int) -> void:
	angular_velocity = qte_impulse
	camera_shake.trigger_shake(success_count * 0.01)
	
	  
func qte_active(active: bool):
	is_qte_active = active


func handle_qte_failure():
	qte_finished = true   
	return qte_controller.cancel_qte()
	
	
func handle_qte_success():
	angular_velocity = qte_impulse
	Global.add_multiplier()
	return qte_controller.qte_success()


func perform_save():
	qte_controller.cancel_qte()
	ghost_save = true
	allow_ghost_input = false
	ghost_kid.play_ghost_save()


func get_ghost_kid_save_chance() -> float:
	if Global.up_ghost_kid <= 0:
		return 0.0
	return 1.0 - pow(1.0 - (Global.ghost_kid_save_chance / 100.0), Global.up_ghost_kid)


func roll_ghost_kid_save() -> bool:
	return randf() * 100.0 < get_ghost_kid_save_chance() * 100.0


func rotate_childe():
	child.global_rotation = chair_top.global_rotation 


func multiplier_increase():
	shake_mult += 0.01
	spin_pitch += 0.1
	mult_sound.pitch_scale = spin_pitch


func ghost_kid_anim_fin():
	allow_ghost_input = true
	sig_ghost_save.emit(true, true)
