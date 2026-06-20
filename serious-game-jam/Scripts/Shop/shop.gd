class_name Shop extends Control


@onready var ship_grid: GridContainer = $Container/ShipContainer/GridContainer
@onready var player_grid: GridContainer = $Container/PlayerContainer/GridContainer
@onready var show_shop: Button = $ShowShop
@onready var container: Control = $Container

@onready var money: Label = $Container/Money
@onready var ship_health: Label = $Container/ShipHealth
@onready var ship_health_max: Label = $Container/ShipMaxHealth

@export var ship_button_paths: Array[String]
@export var player_button_paths: Array[String]
@export var ui_container: Control


func _ready() -> void:
	container.visible = false
	for button_path in ship_button_paths:
		var instance = load(button_path).instantiate()
		ship_grid.add_child(instance)
		
	for button_path in player_button_paths:
		var instance = load(button_path).instantiate()
		player_grid.add_child(instance)


func _process(delta: float) -> void:
	money.text = "$" + str(Global.money_tracker)


func _on_exit_pressed() -> void:
	if ui_container:
		ui_container.visible = true
	container.visible = false
	show_shop.visible = true


func _on_show_shop_pressed() -> void:
	if ui_container:
		ui_container.visible = false
	container.visible = true
	show_shop.visible = false
