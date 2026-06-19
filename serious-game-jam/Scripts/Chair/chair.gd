class_name Chair
extends Node3D


@export var path: String

var chair_top: MeshInstance3D
signal add_money_signal


func _ready() -> void:
	chair_top = get_node(path)


func spin_chair(spin_amount: float = 360.0):
	var spin_rate_mult = spin_duration_for_amount(spin_amount)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(chair_top, "rotation_degrees:y", chair_top.rotation_degrees.y + spin_amount, Global.init_spin_rate * spin_rate_mult)
	add_money_signal.emit(Global.init_spin_rate * spin_rate_mult)


func spin_duration_for_amount(spin_amount: float) -> float:
	var base_spin: float = 360.0
	var base_time: float = 1.2

	var ratio = spin_amount / base_spin

	# Try exponents: 0.3, 0.4, 0.5, etc.
	var exponent = 0.4
	var duration = base_time * pow(ratio, exponent)

	# Optional clamp
	duration = clamp(duration, base_time * 0.8, base_time * 4.0)

	return duration
