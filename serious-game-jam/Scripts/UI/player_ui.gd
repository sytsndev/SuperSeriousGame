class_name PlayerUI
extends Control

@onready var spin_chair_button: Button = %SpinChair
@onready var spin_chair_input: LineEdit = %SpinAmount
@onready var money_label: RichTextLabel = %MoneyLabel
@onready var money_added_label: RichTextLabel = %MoneyAdded
@onready var barf_meter: TextureProgressBar = %BarfMeter
@onready var ui_container: Control = %MainUIContainer
@onready var multiplier_label: RichTextLabel = %Multiplier
@onready var spacebar_prompt: TextureRect = %SpacebarRect
@onready var shop_hover_tip: TextureRect = %ShopHoverTip
@onready var info_container: Control = %InfoContainer
@onready var info_label: RichTextLabel = %InfoLabel
@onready var barf_percentage: RichTextLabel = %BarfPerc


@export var chair: Chair
@export var money_controller: MoneyController
@export var camera_controller: CameraController
@export var qte_controller: QTEController

var is_spinning: bool = false
var mult_flip := false


func _ready() -> void:
	var root = get_tree().root
	chair.spins_complete.connect(spin_complete)
	qte_controller.active.connect(toggle_spacebar_prompt)
	chair.sig_ghost_save.connect(toggle_spacebar_prompt)
	setup_barf_meter()
	Global.money_added.connect(show_money_added_label)
	Global.mult_increase.connect(mult_juice)
	Global.reset_multiplier.connect(reset_mult_juice)


func _process(delta: float) -> void:
	if Global.can_spin or Global.disable_all_shop_items:
		visible = true
	else:
		visible = false
	spin_chair_button.disabled = is_spinning
	money_label.text = "$" + "%.2f" % Global.money_tracker
	barf_meter.value = Global.barf_tracker
	barf_meter.max_value = Global.barf_max
	barf_percentage.text = str(int(Global.get_barf_percentage())) + "%"
	multiplier_label.text = "x" + str(Global.curr_multiplier)
	


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


func toggle_spacebar_prompt(show: bool, is_ghost: bool = false):
	spacebar_prompt.visible = show
	if is_ghost:
		%GhostSave.visible = show


func show_info_label(text: String):
	info_container.visible = true
	info_label.text = text
	shop_hover_tip.visible = false


func hide_info_label():
	Global.put_down_info_item.emit()
	info_container.visible = false


func mult_juice():
	mult_flip = !mult_flip
	var target_angle = deg_to_rad(12.0 if mult_flip else -12.0)

	var t = create_tween()
	t.tween_property(multiplier_label, "rotation", target_angle, 0.06)
	t.tween_property(multiplier_label, "rotation", 0.0, 0.08)

	var current_size = multiplier_label.get_theme_font_size("normal_font_size")
	multiplier_label.add_theme_font_size_override("normal_font_size", current_size + 8)

	var current_outline = multiplier_label.get_theme_constant("outline_size")
	multiplier_label.add_theme_constant_override("outline_size", current_outline + 2)


func reset_mult_juice():
	mult_flip = !mult_flip
	var target_angle = deg_to_rad(12.0 if mult_flip else -12.0)

	var t = create_tween()
	t.tween_property(multiplier_label, "rotation", target_angle, 0.06)
	t.tween_property(multiplier_label, "rotation", 0.0, 0.08)
	
	multiplier_label.add_theme_font_size_override("normal_font_size", 32)
	multiplier_label.add_theme_constant_override("outline_size", 8)
