class_name MoneyController
extends Node

@export var chair: Chair

var curr_money: float = 0.0


func _ready() -> void:
	chair.add_money_signal.connect(add_money)


func get_money():
	return curr_money


func add_money():
	curr_money += snapped(Global.base_money_amount, 0.01) 
