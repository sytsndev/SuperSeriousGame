class_name PlayerUI
extends Control

@onready var spin_chair_button: Button = %SpinChair
@onready var spin_chair_input: LineEdit = %SpinAmount
@onready var money_label: RichTextLabel = %MoneyLabel
@onready var money_added_label: RichTextLabel = %MoneyAdded
@onready var barf_meter: TextureProgressBar = %BarfMeter
@onready var ui_container: Control = %MainUIContainer
@onready var multiplier_label: RichTextLabel = %Multiplier
@onready var enter_shop_button: Button = %EnterShop
@onready var exit_shop_button: Button = %ExitShop


@export var chair: Chair
@export var money_controller: MoneyController
@export var camera_controller: CameraController

var is_spinning: bool = false

func _ready() -> void:
	var root = get_tree().root
	chair.spins_complete.connect(spin_complete)
	exit_shop_button.visible = false
	setup_barf_meter()
	Global.money_added.connect(show_money_added_label)


func _process(delta: float) -> void:
	spin_chair_button.disabled = is_spinning
	money_label.text = str(Global.money_tracker)
	barf_meter.value = Global.barf_tracker
	barf_meter.max_value = Global.barf_max
	multiplier_label.text = "x" + str(Global.apply_upgrades())


func show_money_added_label(amount: float, seconds: float = 2.0) -> void:
	money_added_label.text = "+" + str(amount)
	money_added_label.visible = true
	money_added_label.modulate.a = 1.0

	var label = money_added_label
	var base_y = label.position.y
	var bounce_up = -18.0
	var tween = create_tween()

	# Bounce up
	tween.tween_property(label, "position:y", base_y + bounce_up, 0.25) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)

	# Slow drop back to original + fade out
	tween.tween_property(label, "position:y", base_y, seconds - 0.3) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(label, "modulate:a", 0.0, seconds - 0.3)

	await tween.finished
	label.visible = false
	label.modulate.a = 1.0


func setup_barf_meter():
	barf_meter.max_value = Global.barf_max
	barf_meter.value = Global.barf_tracker


func spin_complete():
	is_spinning = false


func _on_spin_chair_pressed() -> void:
	if spin_chair_input.text == "":
		is_spinning = true
		chair.spin_chair()
	if spin_chair_input.text != "":
		Global.money_tracker += int(spin_chair_input.text)
		is_spinning = true
		chair.spin_chair(int(spin_chair_input.text))


func _on_enter_shop_pressed() -> void:
	enter_shop_button.visible = false
	exit_shop_button.visible = true
	camera_controller.swap_camera("shop")


func _on_exit_shop_pressed() -> void:
	exit_shop_button.visible = false
	enter_shop_button.visible = true
	camera_controller.swap_camera("chair")
