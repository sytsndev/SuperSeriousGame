extends Node


var init_spin_rate: float = 1.2
var init_spin_amount: float = 360.0

#MONEY
var base_money_amount: float = 0.25
var money_tracker: float = 0.0


#amount of people in the crowd (money multiplier)
var init_crowd: int = 1

#BARF
var barf_tracker: float = 0.0
var barf_max: float = 36000
var barf_mult: float = 10


#UPGRADES
var up_chair_grease_count: int = 1
var up_delayed_gratification: int = 0

#UPGRADE MULTS
var mult_chair_grease: float = 1.1
var mult_delayed_gratification: float = 2.3



func get_money_for_spin():
	if barf_tracker >= barf_max:
		barf_tracker = 0.0
		return base_money_amount * init_crowd * barf_mult
	return base_money_amount * init_crowd * (mult_chair_grease * up_chair_grease_count)


func add_to_barf_tracker(spins: float):
	barf_tracker += spins
