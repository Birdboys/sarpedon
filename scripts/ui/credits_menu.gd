extends Control
@onready var leftButton := $HBoxContainer/artDetails/gallery/HBoxContainer/leftButton
@onready var rightButton := $HBoxContainer/artDetails/gallery/HBoxContainer/rightButton
@onready var index = 0
@onready var art_list := ['tapestry','medusa1','medusa2','stheno','euryale','athena1','athena2','athena3','hermes1','hermes2','hermes3','graeae','phorkys','sirens1','maidens1','maidens2','maidens3','maidens4','eye','items1','items2','items3']
@onready var artLabel := $HBoxContainer/artDetails/gallery/HBoxContainer/artLabel
@onready var artImage := $HBoxContainer/artDetails/gallery/MarginContainer/artImage
@onready var current_art : ArtDetails
@onready var artDetails := $HBoxContainer/artDetails
@onready var galleryButton := $HBoxContainer/artDetails/openGallery
@onready var gallery := $HBoxContainer/artDetails/gallery
@onready var creditsText := $HBoxContainer/creditsText

func _ready():
	leftButton.pressed.connect(leftPressed)
	rightButton.pressed.connect(rightPressed)
	artLabel.pressed.connect(artLabelPressed)
	galleryButton.pressed.connect(openGallery)
	creditsText.meta_clicked.connect(openLink)
	loadArt(art_list[index])
	
func open():
	visible = true
	gallery.visible = false
	galleryButton.visible = true
	
func close():
	visible = false

func leftPressed():
	index = wrapi(index-1, 0, len(art_list))
	loadArt(art_list[index])
	AudioHandler.playSound("ui_click")

func rightPressed():
	index = wrapi(index+1, 0, len(art_list))
	loadArt(art_list[index])
	AudioHandler.playSound("ui_click")

func artLabelPressed():
	if current_art: OS.shell_open(current_art.art_link)
	
func loadArt(art):
	current_art = load("res://scripts/resources/art_details/%s.tres" % art)
	print(current_art.art_name)
	artLabel.text = current_art.art_name
	artImage.texture = current_art.art_image
	
func clearArt():
	current_art = null
	artLabel.text = ""
	artImage.texture = null

func openGallery():                                    
	gallery.visible = true
	galleryButton.visible = false

func openLink(link):
	AudioHandler.playSound("ui_click")
	OS.shell_open(str(link))
