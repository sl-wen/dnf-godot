extends Node

func _ready():
	print("开始测试角色脚本...")
	
	# 测试加载 Old_Character 脚本
	var old_character_script = load("res://src/scripts/character/Old_Character.gd")
	if old_character_script:
		print("✅ Old_Character.gd 脚本加载成功")
	else:
		print("❌ Old_Character.gd 脚本加载失败")
	
	# 测试加载 Old_Swordman 脚本
	var old_swordman_script = load("res://src/scripts/character/Old_Swordman.gd")
	if old_swordman_script:
		print("✅ Old_Swordman.gd 脚本加载成功")
	else:
		print("❌ Old_Swordman.gd 脚本加载失败")
	
	# 测试 DataManager 是否可访问
	if DataManager:
		print("✅ DataManager 可访问")
		if DataManager.roleData:
			print("✅ DataManager.roleData 存在")
		else:
			print("❌ DataManager.roleData 不存在")
	else:
		print("❌ DataManager 不可访问")
	
	print("测试完成，退出...")
	get_tree().quit()