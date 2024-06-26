extends Control

@onready var itemImage := $inventoryMargin/inventoryPanel/hbox/imageMargin/VBoxContainer/itemImage
@onready var itemName := $inventoryMargin/inventoryPanel/hbox/imageMargin/VBoxContainer/itemName
@onready var itemDesc := $inventoryMargin/inventoryPanel/hbox/vbox/itemDesc
@onready var itemTip := $inventoryMargin/inventoryPanel/hbox/vbox/itemTip
@onready var is_open := false

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = is_open

func openInventory(item := "shield"):
	is_open = true
	visible = true
	loadItem(item)
	
func loadItem(item):
	var item_resource = load("res://scripts/resources/%s.tres" % item)
	itemImage.texture = item_resource.image
	itemName.text = item_resource.name
	itemDesc.text = item_resource.description
	itemTip.text = item_resource.tooltip

func closeInventory():
	is_open = false
	visible = false
	
func _unhandled_input(event):
	pass
