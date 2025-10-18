extends "res://src/scripts/state_machine/state.gd"
var attack1_sound = preload("res://assets/sounds/swordman/sm_atk_01.ogg");
var attack2_sound = preload("res://assets/sounds/swordman/sm_atk_02.ogg");
var attack3_sound = preload("res://assets/sounds/swordman/sm_atk_03.ogg");

#普攻最大连击数
@export var MAX_COMBO_COUNT: int = 3
#当前连击数
var combo_count = 0;
var combo:Array = ["attack1","attack2","attack3"];
#是否继续攻击
var is_combo:bool = false;
#是否可以combo
var can_combo:bool = false;

func enter():
	# 如果不是连击，重置连击数
	if not is_combo:
		combo_count = 0;
	
	# 播放对应的攻击动画
	var anim_name = combo[combo_count] if combo_count < combo.size() else "attack1"
	owner.get_node("AnimationPlayer").play(anim_name)
	combo_count += 1;
	
	# 重置连击窗口
	can_combo = false;
	# 注意：不要在这里重置is_combo，保持连击状态
#	owner.hitbox.knockback_vector

func handle_input(event):
	# 检测技能快捷键输入，实现强制技能触发
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
	
	# 原有的攻击连击逻辑
	if event.is_action_pressed("attack"):
		print("攻击键按下，can_combo: ", can_combo, " is_combo: ", is_combo)
		if can_combo == true:
			print("检测到连击输入，当前连击数: ", combo_count)
			is_combo = true;
			can_combo = false;  # 重置连击窗口，防止重复触发
			print("连击状态已设置，is_combo: ", is_combo)
	return super.handle_input(event)
func _on_animation_finished(anim_name):
	print("攻击动画完成: ", anim_name, " 当前连击数: ", combo_count, " 是否连击: ", is_combo)
	
	# 如果玩家在动画期间按了攻击键，继续连击
	if is_combo and combo_count < MAX_COMBO_COUNT:
		print("执行连击，播放第", combo_count + 1, "击")
		var next_anim = combo[combo_count] if combo_count < combo.size() else "attack1"
		owner.get_node("AnimationPlayer").play(next_anim)
		combo_count += 1;
		is_combo = false;  # 重置连击标记，等待下次输入
		can_combo = false; # 重置连击窗口，等待动画事件开启
	else:
		# 连击结束或达到最大连击数，返回idle状态
		combo_count = 0;
		is_combo = false;
		can_combo = false;
		emit_signal("finished", "idle")

# 启用连击（由动画事件调用）
func enable_combo():
	can_combo = true;
	print("连击窗口开启，当前连击数: ", combo_count)

func attack_sound():
	var soundPlayer = owner.get_node("AudioStreamPlayer");
	if soundPlayer.playing == true:
		soundPlayer.stop();
	var random:int = int(ceil(randf_range(0,3)));
	match random:
		1:
			soundPlayer.stream = attack1_sound;
		2:
			soundPlayer.stream = attack2_sound;
		3:
			soundPlayer.stream = attack3_sound;
			
	soundPlayer.play();

# 触发强制技能（Cancel技能）
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
		# 强制中断当前攻击，切换到技能状态
		print("强制中断攻击，施放技能: ", skill_config.name)
		# 设置要施放的技能信息
		owner.current_skill_id = skill_id
		owner.current_skill_level = skill_level
		emit_signal("finished", "skill")
	else:
		# 普通技能，正常施放
		print("施放技能: ", skill_config.name)
		# 设置要施放的技能信息
		owner.current_skill_id = skill_id
		owner.current_skill_level = skill_level
		emit_signal("finished", "skill")
