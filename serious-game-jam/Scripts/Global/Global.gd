extends Node


var init_spin_rate: float = 1.2
var init_spin_amount: float = 360.0

var base_spin_force: float = 1080.0
var base_friction: float = 540.0

#MONEY
var base_money_amount: float = 0.25
var money_tracker: float = 0.0
var gross_money: float = 0.0

## Multiplier
var spin_mutliplier: float = 1.0
var curr_multiplier: float = 0.0

#amount of people in the crowd (money multiplier)
var crowd: int = 1 ## Crowd max should be 10
var crowd_max: int = 10
#BARF
var barf_tracker: float = 0.0
var barf_max: float = 36000
var barf_mult: float = 10


#UPGRADES
var up_chair_grease_count: int = 0 
var up_delayed_gratification: int = 1
var up_multiplier: int = 1
var up_ghost_kid: int = 1

#UPGRADE MULTS
var mult_chair_grease: float = 0.1
var mult_delayed_gratification: float = 2.5 #I want this to make barf meter max 2x higher but then 2.3 times more profit
var mult_multiplier: float = 0.1
var mult_barf_increase_delayed_gratification: float = 36000

#UPGRADE STATS
var ghost_kid_save_chance: float = 0.15

var can_spin: bool = false
var disable_all_shop_items: bool = false

signal put_down_info_item

signal money_added
signal crowd_added
signal chair_grease_added


func add_chair_grease():
	up_chair_grease_count += 1
	chair_grease_added.emit()

func add_money():
	var money_to_add = calc_spin_total()
	Global.gross_money += money_to_add
	Global.money_tracker += money_to_add
	money_added.emit(money_to_add)


func add_crowd():
	crowd += 1
	crowd_added.emit()


func add_mutliplier():
	up_multiplier += 1


func roll_ghost_kid_save() -> bool:
	return randf() < get_ghost_kid_save_chance()

func get_ghost_kid_save_chance() -> float:
	if up_ghost_kid <= 0:
		return 0.0
	# each kid independently rolls 15%; saved if ANY of them hit
	return 1.0 - pow(1.0 - ghost_kid_save_chance, up_ghost_kid)
	
func get_spin_force() -> float:
	var force = base_spin_force
	return force
	
func get_friction() -> float:
	var friction = base_friction
	friction *= pow(0.85, up_chair_grease_count)
	return max(friction, 60.0) 


func get_money_for_spin():
	return base_money_amount * apply_crowd()


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
	if barf_tracker > barf_max:
		curr_multiplier = get_barf_mult()
		print(curr_multiplier)


func apply_chair_grease():
	return up_chair_grease_count * mult_chair_grease


func add_multiplier():
	if curr_multiplier == 0:
		curr_multiplier = spin_mutliplier
	curr_multiplier += get_mult_per_spin()
	print(curr_multiplier)


func get_mult_per_spin():
	var mult: float = 0.0
	if up_multiplier > 0:
		mult += up_multiplier * mult_multiplier
	return mult


func get_barf_mult():
	if barf_tracker >= barf_max:
		if up_delayed_gratification > 0:
			return barf_mult * (up_delayed_gratification * mult_delayed_gratification)
		else:
			return barf_mult

func calc_spin_total():
	return base_money_amount * apply_crowd() * curr_multiplier
