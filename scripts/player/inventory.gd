extends Control

@onready var itemImage := $inventoryMargin/inventoryBorder/panelMargin/hbox/imagePanel/imageMargin/VBoxContainer/itemImage
@onready var itemName := $inventoryMargin/inventoryBorder/panelMargin/hbox/imagePanel/imageMargin/VBoxContainer/itemName
@onready var itemDesc := $inventoryMargin/inventoryBorder/panelMargin/hbox/vbox/itemDesc
@onready var itemTip := $inventoryMargin/inventoryBorder/panelMargin/hbox/vbox/itemTip
@onready var controlText := $inventoryMargin/inventoryBorder/panelMargin/hbox/imagePanel/imageMargin/VBoxContainer/controlText
@onready var is_open := false
@onready var current_inventory := ["bag", "sword"]
@onready var inventory_index := 0
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = is_open

func openInventory(item = null):
	is_open = true
	visible = true
	if item:
		inventory_index = current_inventory.find(item)
	loadItem(current_inventory[inventory_index])
	
func loadItem(item):
	var item_resource = load("res://scripts/resources/%s.tres" % item)
	itemImage.texture = item_resource.image
	itemName.text = item_resource.name
	itemDesc.text = item_resource.description
	itemTip.text = item_resource.tooltip
	var left_text = "<-A"
	var right_text = "D->"
	if inventory_index == 0:
		controlText.text = "[center]%s|%s[/center]" % ["[color=#ffffff80]"+left_text+"[/color]", right_text]
	elif inventory_index == len(current_inventory)-1:
		controlText.text = "[center]%s|%s[/center]" % [left_text, "[color=#ffffff80]"+right_text+"[/color]"]
	else:
		controlText.text = "[center]%s|%s[/center]" % [left_text, right_text]

func closeInventory():
	is_open = false
	visible = false

func nextItem(right := true):
	inventory_index += 1 if right else -1
	inventory_index = clampi(inventory_index, 0, len(current_inventory)-1)
	loadItem(current_inventory[inventory_index])

func acquireItem(item):
	current_inventory.append(item)
	inventory_index = current_inventory.find(item)
