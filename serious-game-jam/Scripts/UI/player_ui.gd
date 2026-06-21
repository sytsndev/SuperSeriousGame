class_name PlayerUI
extends Control

@onready var spin_chair_button: Button = %SpinChair
@onready var spin_chair_input: LineEdit = %SpinAmount
@onready var money_label: RichTextLabel = %MoneyLabel
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
	chair.spins_complete.connect(spin_complete)
	exit_shop_button.visible = false
	setup_barf_meter()


func _process(delta: float) -> void:
	spin_chair_button.disabled = is_spinning
	money_label.text = str(Global.money_tracker)
	barf_meter.value = Global.barf_tracker
	multiplier_label.text = "x" + str(Global.apply_upgrades())


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
