class_name PlayerUI
extends Control

@onready var spin_chair_button: Button = $SpinChair
@onready var spin_chair_input: LineEdit = $SpinAmount
@onready var money_label: RichTextLabel = $MoneyLabel

@export var chair: Chair
@export var money_controller: MoneyController


func _process(delta: float) -> void:
	money_label.text = str(money_controller.get_money())


func _on_spin_chair_pressed() -> void:
	if spin_chair_input.text == "":
		chair.spin_chair()
	if spin_chair_input.text != "":
		chair.spin_chair(int(spin_chair_input.text))
