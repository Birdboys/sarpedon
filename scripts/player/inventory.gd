extends Control

@onready var itemImage := $inventoryMargin/inventoryBorder/panelMargin/hbox/imagePanel/imageMargin/VBoxContainer/itemImage
@onready var itemName := $inventoryMargin/inventoryBorder/panelMargin/hbox/imagePanel/imageMargin/VBoxContainer/itemName
@onready var itemDesc := $inventoryMargin/inventoryBorder/panelMargin/hbox/vbox/itemDesc
@onready var itemTip := $inventoryMargin/inventoryBorder/panelMargin/hbox/vbox/itemTip
@onready var is_open := false
@onready var current_inventory := ["bag", "sword", "shield"]
@onready var inventory_index := 0
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

func nextItem(right := true):
	inventory_index += 1 if right else -1
	inventory_index = wrapi(inventory_index, 0, len(current_inventory))
	loadItem(current_inventory[inventory_index])
