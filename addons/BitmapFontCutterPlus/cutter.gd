@tool
extends FontFile

var index = 0
@export var GlyphSize: Vector2 = Vector2(8,8): set = changeGlyphSize
@export var TextureToCut: Texture2D = null: set = changeTexture
@export var StartChar = 48: set = changeStartChar
@export var Spacing: float = 1: set = changeSpacing
@export var Monospaced: bool = true: set = changeMonospaced

func changeStartChar(value):
	StartChar = value
	_update_font()

func changeGlyphSize(value):
	GlyphSize = value
	# 注意：在 Godot 4.x 中，FontFile.height 是只读属性，由字体数据自动计算
	_update_font()
	
func changeTexture(value):
	TextureToCut = value
	index = 0
	if TextureToCut:
		_update_font()
	
func changeSpacing(value):
	Spacing = value
	_update_font()

func changeMonospaced(value):
	Monospaced = value
	_update_font()

func _update_font():
	if TextureToCut != null:
		if GlyphSize.x > 0 and GlyphSize.y > 0:
			
			var w  = TextureToCut.get_width()
			var h  = TextureToCut.get_height()
			var tx = w / GlyphSize.x
			var ty = h / GlyphSize.y

			var font = self
#			var i = 0  #Iterator for char index

			clear_cache()

			#----------------------------------------
			# Godot 4.x 兼容的字体生成方法
			# 在 Godot 4.x 中，需要先设置纹理，然后渲染字形
			
			# 添加纹理到字体缓存
			var cache_index = 0
			var size_vector = Vector2i(int(GlyphSize.x), int(GlyphSize.y))
			
			# 为每个字符渲染字形
			for i in range(tx):
				var glyph_index = StartChar + i
				
				# 使用正确的 render_glyph 方法（只需要3个参数）
				font.render_glyph(cache_index, size_vector, glyph_index)
			
			#----------------------------------------

			#Begin cutting..... so edgy
#			font.add_texture(TextureToCut)
#			font.height = GlyphSize.y
#			for y in range(ty):
#				for x in range(tx+1):
#					var l = 0
#					var character_width = GlyphSize.x
#
#					if !Monospaced:
#						var data = TextureToCut.get_data()
#						data.lock()
#
#						var found = false
#						for xx in range(0,GlyphSize.x):
#							if found: break
#							for yy in range(0,GlyphSize.y):
#								var pixel = data.get_pixel(x*GlyphSize.x + xx, y*GlyphSize.y + yy)
#								if pixel.a != 0:
#									l = xx
#									character_width -= xx
#									found = true
#									break
#
#						found = false
#						for xx in range(0,GlyphSize.x):
#							if found: break
#							for yy in range(0,GlyphSize.y):
#								var pixel = data.get_pixel(x*GlyphSize.x + GlyphSize.x - xx -1, y*GlyphSize.y + yy)
#								if pixel.a != 0:
#									character_width -= xx
#									found = true
#									break
#
#						data.unlock()
#
#					var region = Rect2(x*GlyphSize.x + l,y*GlyphSize.y,character_width, GlyphSize.y)
#					font.add_char(StartChar + i, 0, region, Vector2.ZERO, character_width + Spacing)
#
#					i+=1
			# 在 Godot 4.x 中通知资源已更改
			emit_changed()
	pass #if texture is null
