class_name MoneyController
extends Node

@export var chair: Chair

var curr_money: float = 0.0


func _ready() -> void:
	chair.add_money_signal.connect(add_money)


func get_money():
	return curr_money


func add_money():
	var money_to_add = snapped(Global.get_money_for_spin(), 0.01) 
	curr_money += money_to_add
	Global.gross_money += money_to_add
	Global.money_tracker = curr_money
