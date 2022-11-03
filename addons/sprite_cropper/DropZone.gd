## Plugin for cropping sprites in editor
##
##

@tool
extends Panel

## LineEdit node that determines the file's name
@onready var file_name: LineEdit = get_node("../FileNameLineEdit")
## LineEdit node that determines the file's path
@onready var des_path: LineEdit = get_node("../FileDestCont/LineEdit2")
## LineEdit to change size of individual sprite
@onready var sprite_dimensions_box: SpinBox = get_node("../HBoxContainer/SpinBox")
### Delay duration between each frame. Default is 1 second
#@onready var delay_num: SpinBox = get_node("../HBoxContainer2/SpinBox")
## TextureRect that will show image to crop
@onready var img: TextureRect = get_node("./Sprite")
## Label instructing the user where to drop file
@onready var instruct: Label = get_node("./Label")

## Size of individual sprite. Default is 16x
var sprite_dimensions = 16
## Bool to to prevent a bunch of unnecessary computing. User must confirm individual sprite is less than 8 pixels
var less_than_eight = false
## Array storing ReferenceRects for visual of sprite slice
var guide_rects = []

var offset = Vector2i.ZERO

var seperation = Vector2i.ZERO

var search_resolutions = [ "8", "16", "32", "64" ]

var editor_script = EditorScript.new() #preload("res://addons/sprite_cropper/crop_editor_script.gd").new()

## Currently not in use. This might be implemented in the future to save preferences
var config = ConfigFile.new()
## Currently not in use. Might be paired with [member config] to save preferences in the future
var settings

func _ready():
	# Double check visibilities are correct
	img.visible = false
	instruct.visible = true
	sprite_dimensions = sprite_dimensions_box.value
	#draw_rects()
	
## Might include saving settings in future update
#	settings = config.load("res://addons/anim_text/settings.cfg")
#
#	if settings == OK:
#		for setting_sec in config.get_sections():
#			if setting_sec == "paths":
#				des_path.text = config.get_value(setting_sec, "anim_destination")
#	else:
#		config.set_value("paths", "anim_destination", "res://")


func _can_drop_data(at_position, data):
	var paths = data["files"]
	if paths[0].ends_with(".png") or paths[0].ends_with(".svg"):
		return true



func _drop_data(at_position, data):
	var dropped = data["files"]
	if dropped[0] and dropped.size() < 2:
		img.texture = load(dropped[0])
		img.visible = true
		instruct.visible = false
		for res in search_resolutions:
			if res in dropped[0]:
				_on_size_value_changed(res.to_int())
				break
		draw_rects()
	
	


func _on_make_text_pressed():
	if img.texture:
		crop_sprite()

		
func crop_sprite():

	var new_imgs = []
	
	var column_count = img.texture.get_width() / sprite_dimensions
	var row_count = img.texture.get_height() / sprite_dimensions

	var curr_row = 0
	var curr_column = 0
	for i in ((row_count) * (column_count)):
		var cropped = Image.new().create(sprite_dimensions, sprite_dimensions, false, img.texture.get_image().get_format())
		var rect = Rect2i(Vector2(sprite_dimensions * curr_column, sprite_dimensions * curr_row), Vector2i(sprite_dimensions, sprite_dimensions))
		cropped.blit_rect(img.texture.get_image(), rect, Vector2i(0, 0))
		if not cropped.is_empty():
			new_imgs.append(cropped)
	
		curr_column += 1
		if curr_column >= column_count:
			curr_column = 0
			curr_row += 1
	
	if not des_path.text.begins_with("res://"):
		des_path.text = "res://" + des_path.text
	if not des_path.text.ends_with("/"):
		des_path.text += "/"
	
	var dir = DirAccess.open(des_path.text)
	if not dir:
		dir.make_dir(des_path.text)
	
	var count = 0
	while true:
		for image in new_imgs:
			if FileAccess.file_exists(des_path.text + file_name.text + str(count) + ".png"):
				file_name.text += "(new)"
				continue
		break
	count = 0
	for image in new_imgs:
		image.save_png(des_path.text + file_name.text + str(count) + ".png")
		count += 1
	
	
	editor_script.get_editor_interface().get_resource_filesystem().scan()
	editor_script.get_editor_interface().get_file_system_dock().navigate_to_path(des_path.text)

func _on_search_dest_butt_pressed():
	var dest = FileDialog.new()
	add_child(dest)
	dest.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dest.connect("dir_selected", set_dest, CONNECT_ONE_SHOT)
	dest.popup_centered(Vector2i(750, 500)) #popup()
#	var rect = get_viewport_rect()
#	dest.size = Vector2(rect.size.x - 200, rect.size.y - 200)
	
func set_dest(dest_str):
	des_path.text = dest_str
	editor_script.get_editor_interface().get_resource_filesystem().scan()
	


func _on_size_value_changed(value):
	sprite_dimensions = value
	sprite_dimensions_box.value = value
	draw_rects()
	
func draw_rects():
	for rect in guide_rects:
		rect.queue_free()
	guide_rects = []
	

	if sprite_dimensions == 0:
		return
	elif sprite_dimensions < 8 and not less_than_eight:
		return
	
	var column_count = img.texture.get_width() / sprite_dimensions
	var row_count = img.texture.get_height() / sprite_dimensions
			
		

	var curr_row = 0
	var curr_column = 0

	var size_diff_x = img.size.x / img.texture.get_size().x
	var size_diff_y = img.size.y / img.texture.get_size().y
	for i in ((row_count) * (column_count)):
		var new_rect = ReferenceRect.new()
		new_rect.border_width = 1
		new_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(new_rect)
		var rect = Rect2i(Vector2(sprite_dimensions * curr_column * size_diff_x, sprite_dimensions * curr_row* size_diff_y), Vector2i(sprite_dimensions, sprite_dimensions))
		guide_rects.append(new_rect)
		new_rect.size = Vector2(rect.size) * Vector2(size_diff_x, size_diff_y)
		new_rect.position = Vector2(rect.position)
	
		curr_column += 1
		if curr_column >= column_count:
			curr_column = 0
			curr_row += 1


func _on_check_box_toggled(button_pressed):
	less_than_eight = button_pressed
