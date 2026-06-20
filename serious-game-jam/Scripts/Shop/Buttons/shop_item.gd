class_name ShopItem extends Button

@onready var button: Button = $"."
@export var price: float
var apply_upgrade: Callable


func _ready() -> void:
	apply_upgrade = Callable(self, "_shop_upgrade")


func _shop_upgrade():
	pass


func toggle_disable():
	pass
