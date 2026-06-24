class_name QTEController
extends Node

var qte_active: bool = false
var qte_timer: float = 0.0
var qte_delay_low: float = 0.5
var qte_delay_high: float = 0.75
var qte_length: float = 0.8
var qte_default_length: float = 1.0
var qte_length_change: float = 0.8
var qte_success_count: int = 0
var qte_restart: bool = false
var qte_cancelled: bool = false

signal active
signal ghost_save


func _ready() -> void:
	qte_length = qte_length_upgrade_applied()
	qte_default_length = qte_length_upgrade_applied()
	Global.chair_grease_added.connect(set_default_qte_length)

func init_qte():
	qte_cancelled = false
	await get_tree().create_timer(qte_delay_low, qte_delay_high).timeout
	if qte_cancelled:
		return
	qte_restart = false
	start_qte()

func start_qte():
	qte_active = true
	qte_timer = qte_length
	active.emit(true)


func _physics_process(delta: float) -> void:
	if qte_active and !qte_restart:
		qte_timer -= delta
		if qte_timer <= 0.0:
			cancel_qte()


func qte_success():
	print(qte_length)
	qte_success_count += 1
	qte_length *= qte_length_change
	qte_restart = true
	active.emit(false)
	init_qte()
	return qte_success_count


func cancel_qte():
	qte_cancelled = true
	
	if Global.roll_ghost_kid_save():
		ghost_save.emit(qte_success())
		return
	qte_active = false
	qte_timer = 0.0
	qte_success_count = 0
	qte_length = qte_default_length
	active.emit(false)


func qte_length_upgrade_applied():
	if Global.up_chair_grease_count > 0:
		return qte_length + Global.apply_chair_grease()
	else:
		return qte_length


func set_default_qte_length():
	qte_default_length = qte_length_upgrade_applied()
