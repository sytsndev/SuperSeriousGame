extends ShopItem

var repairHealthAmt: float = 250


func _ready() -> void:
	button.text = "Buy Chair Grease (" + str(Global.up_chair_grease_count) + ")"


func _process(delta: float) -> void:
	toggle_disable()
	button.text = "Buy Chair Grease (" + str(Global.up_chair_grease_count) + ")"


func _shop_upgrade():
	Global.up_chair_grease_count += 1
	Global.money_tracker -= price


func toggle_disable():
	if Global.money_tracker < price:
		disabled = true
	else:
		disabled = false


func _pressed() -> void:
	_shop_upgrade()
