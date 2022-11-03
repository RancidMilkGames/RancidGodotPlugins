extends Control

@export var sprite_dimensions = 16
# Called when the node enters the scene tree for the first time.
func _ready():
#	crop_sprite()
	pass # Replace with function body.


func crop_sprite():
	var new_imgs = []
	var sprite_sheet = load("res://Scenes/SpriteCropper/16x16NewTileSet2.png")
	
	var column_count = sprite_sheet.get_width() / sprite_dimensions
	var row_count = sprite_sheet.get_height() / sprite_dimensions
	
	#var as_img = sprite_sheet as Image
	var num_in_row = 0
	var curr_column = 0
	for i in (row_count * column_count):
		var cropped = Image.new().create(sprite_dimensions, sprite_dimensions, false, sprite_sheet.get_image().get_format()) #Image.FORMAT_BPTC_RGBA)
		var rect = Rect2i(Vector2(sprite_dimensions * num_in_row, sprite_dimensions * curr_column), Vector2i(sprite_dimensions, sprite_dimensions))
		cropped.blit_rect(sprite_sheet.get_image(), rect, Vector2i(0, 0))
		new_imgs.append(cropped)
	
		num_in_row += 1
		if num_in_row >= row_count:
			num_in_row = 0
			column_count += 1
	
	var count = 0
	for image in new_imgs:
		image.save_png("res://Scenes/SpriteCropper/1/" + str(count) + ".png")
		count += 1
	#var columns = sprite_sheet.blit_rect()
