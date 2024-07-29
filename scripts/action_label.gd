extends Label

@export_multiline var original_text : String

func _ready():
	DataHandler.translation_updated.connect(updateTranslation)
	text = DataHandler.translate(original_text)

func updateTranslation():
	print("translating")
	text = DataHandler.translate(original_text)
