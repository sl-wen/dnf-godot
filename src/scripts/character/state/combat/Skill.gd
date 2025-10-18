extends "res://src/scripts/state_machine/state.gd"

# 当前施放的技能ID
var current_skill_id: int = 0
# 当前施放的技能等级
var current_skill_level: int = 0

func enter():
	# 获取要施放的技能信息
	if owner.has_method("get_current_skill_info"):
		var skill_info = owner.get_current_skill_info()
		current_skill_id = skill_info.id
		current_skill_level = skill_info.level
	elif owner.has_property("current_skill_id"):
		current_skill_id = owner.current_skill_id
		current_skill_level = owner.current_skill_level
	
	# 连接动画完成信号
	var animation_player = owner.get_node("AnimationPlayer")
	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)
	
	# 根据技能ID播放对应的动画
	play_skill_animation()

func play_skill_animation():
	var animation_player = owner.get_node("AnimationPlayer")
	
	# 根据技能ID确定要播放的动画
	match current_skill_id:
		1003: # 上挑
			animation_player.play("upperslash")
		1004: # 强制 - 上挑
			animation_player.play("upperslash")
		1018: # 鬼斩
			animation_player.play("hardattack")
		1019: # 强制 - 鬼斩
			animation_player.play("hardattack")
		_:
			# 默认动画或者根据技能配置决定
			print("未知技能ID: ", current_skill_id)
			animation_player.play("upperslash")  # 默认使用上挑动画

func handle_input(event):
	# 技能施放过程中可以被其他技能中断（强制技能）
	if event.is_action_pressed("shortcut1"):
		trigger_cancel_skill(0)
		return
	elif event.is_action_pressed("shortcut2"):
		trigger_cancel_skill(1)
		return
	elif event.is_action_pressed("shortcut3"):
		trigger_cancel_skill(2)
		return
	elif event.is_action_pressed("shortcut4"):
		trigger_cancel_skill(3)
		return
	elif event.is_action_pressed("shortcut5"):
		trigger_cancel_skill(4)
		return
	elif event.is_action_pressed("shortcut6"):
		trigger_cancel_skill(5)
		return
	
	return super.handle_input(event)

func trigger_cancel_skill(shortcut_index: int):
	# 获取技能快捷栏数据
	var skill_data = DataManager.skillShortcutData.data[shortcut_index]
	if skill_data == null:
		return
	
	var skill_id = skill_data["id"]
	var skill_level = skill_data["lv"]
	
	# 检查是否是强制技能（Cancel技能）
	var skill_config = ConfigManager.skillConfigProxy.get_skl_by_ID(DataManager.roleData.job_base, skill_id)
	if skill_config == null:
		return
	
	# 检查技能名称是否包含"强制"，确认是Cancel技能
	if skill_config.name.contains("强制"):
		# 强制中断当前技能，切换到新技能
		print("强制中断技能，施放: ", skill_config.name)
		owner.current_skill_id = skill_id
		owner.current_skill_level = skill_level
		# 重新进入技能状态
		enter()

func _on_animation_finished(_anim_name):
	# 技能动画结束，返回idle状态
	emit_signal("finished", "idle")