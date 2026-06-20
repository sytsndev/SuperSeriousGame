extends Node


var init_spin_rate: float = 1.2
var init_spin_amount: float = 360.0

#MONEY
var base_money_amount: float = 0.25
var money_tracker: float = 0.0
var gross_money: float = 0.0


#amount of people in the crowd (money multiplier)
var init_crowd: int = 4

#BARF
var barf_tracker: float = 0.0
var barf_max: float = 36000
var barf_mult: float = 7


#UPGRADES
var up_chair_grease_count: int = 1
var up_delayed_gratification: int = 0

#UPGRADE MULTS
var mult_chair_grease: float = 0.1
var mult_delayed_gratification: float = 1.3 #I want this to make barf meter max 2x higher but then 2.3 times more profit



func get_money_for_spin():
	return base_money_amount * apply_crowd() * apply_upgrades()


func apply_upgrades():
	var mult: float = 1.0
	if up_chair_grease_count > 0:
		var i = 0
		while i < up_chair_grease_count:
			mult += mult_chair_grease
			i += 1
	
	if up_delayed_gratification > 0:
		var i = 0
		while i < up_delayed_gratification:
			mult += mult_delayed_gratification
			i += 1
	
	if barf_tracker >= barf_max:
		barf_tracker = 0.0
		mult += barf_mult
	
	return mult


func apply_crowd():
	return randi_range(1, init_crowd)


func add_to_barf_tracker(spins: float):
	barf_tracker += spins
