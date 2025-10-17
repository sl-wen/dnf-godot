#数据
var data:Array = []

func load_json(file_add:String):
	var file := FileAccess.open(file_add, FileAccess.READ)
	if file == null:
		data = []
		return
	var temp := file.get_as_text()
	var parsed: Variant = JSON.parse_string(temp)
	if typeof(parsed) == TYPE_ARRAY:
		data = parsed
	else:
		data = []
