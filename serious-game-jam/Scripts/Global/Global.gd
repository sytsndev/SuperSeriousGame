extends Node


var init_spin_rate: float = 1.2
var init_spin_amount: float = 360.0
var base_money_amount: float = 0.25
#amount of people in the crowd (money multiplier)
var init_crowd: int = 1
var barf_mult: float = 10

var barf_tracker: float = 0.0
var barf_max: float = 36000



func get_money_for_spin():
	if barf_tracker >= barf_max:
		barf_tracker = 0.0
		return base_money_amount * init_crowd * barf_mult
	return base_money_amount * init_crowd


func add_to_barf_tracker(spins: float):
	barf_tracker += spins
