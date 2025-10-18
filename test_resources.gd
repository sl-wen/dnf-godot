extends Node

func _ready():
	print("开始测试资源加载...")
	
	# 测试角色贴图
	var body_texture = load("res://assets/images/character/swordman/body/sm_body0000.png")
	if body_texture:
		print("✓ sm_body0000.png 加载成功")
	else:
		print("✗ sm_body0000.png 加载失败")
	
	# 测试着色器
	var shadow_shader = load("res://assets/shader/shadow_shader.gdshader")
	if shadow_shader:
		print("✓ shadow_shader.gdshader 加载成功")
	else:
		print("✗ shadow_shader.gdshader 加载失败")
	
	var outline_shader = load("res://assets/shader/outline_shader.gdshader")
	if outline_shader:
		print("✓ outline_shader.gdshader 加载成功")
	else:
		print("✗ outline_shader.gdshader 加载失败")
	
	var gray_shader = load("res://assets/shader/gray.gdshader")
	if gray_shader:
		print("✓ gray.gdshader 加载成功")
	else:
		print("✗ gray.gdshader 加载失败")
	
	print("资源测试完成")
	get_tree().quit()