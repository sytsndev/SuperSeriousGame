extends Node


var init_spin_rate: float = 1.2
var init_spin_amount: float = 360.0

var base_spin_force: float = 1080.0
var base_friction: float = 540.0

#MONEY
var base_money_amount: float = 0.25
var money_tracker: float = 0.0
var gross_money: float = 0.0


#amount of people in the crowd (money multiplier)
var crowd: int = 1 ## Crowd max should be 10
var crowd_max: int = 10
#BARF
var barf_tracker: float = 0.0
var barf_max: float = 36000
var barf_mult: float = 7


#UPGRADES
var up_chair_grease_count: int = 0 
var up_delayed_gratification: int = 0

#UPGRADE MULTS
var mult_chair_grease: float = 0.1
var mult_delayed_gratification: float = 1.3 #I want this to make barf meter max 2x higher but then 2.3 times more profit
var mult_barf_increase_delayed_gratification: float = 36000 

signal money_added
signal crowd_added

func add_money():
	var money_to_add = snapped(Global.get_money_for_spin(), 0.01) 
	Global.gross_money += money_to_add
	Global.money_tracker += money_to_add
	money_added.emit(money_to_add)


func add_crowd():
	crowd += 1
	crowd_added.emit()


func get_spin_force() -> float:
	var force = base_spin_force
	return force
	
func get_friction() -> float:
	var friction = base_friction
	return friction


func get_money_for_spin():
	return base_money_amount * apply_crowd() * apply_upgrades()


func apply_upgrades():
	var mult: float = 1.0
	if up_chair_grease_count > 0:
		var i = 0
		while i < up_chair_grease_count:
			mult += mult_chair_grease
			i += 1
	
	
	if barf_tracker >= barf_max:
		if up_delayed_gratification > 0:
			var i = 0
			while i < up_delayed_gratification:
				mult += mult_delayed_gratification * up_delayed_gratification * barf_mult
				i += 1
		else:
			mult += barf_mult
		barf_tracker = 0.0
	return mult


func apply_crowd():
	return randi_range(1, crowd)


func add_to_barf_tracker(spins: float):
	barf_tracker += spins
