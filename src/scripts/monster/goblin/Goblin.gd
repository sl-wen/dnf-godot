extends "res://src/scripts/monster/Monster.gd"

signal monster_died

func _ready():
	status = MonsterStatus.new();
	status.id = 1;
	status.init_data();
	
	# 连接到父场景的怪物管理器
	var parent_stage = get_parent().get_parent()
	if parent_stage != null and parent_stage.has_method("register_monster"):
		parent_stage.register_monster(self)

#受到伤害
func _on_HurtBox_area_entered(area):
	var attackData:AttackData = area.attackData;
	var direction:bool = get_direction();
	var dir:int = 1 if direction == true else -1;
	knockback = Vector2.RIGHT * attackData.x_offset * dir;
	status.hp -= attackData.damage;
	if status.hp <= 0:
		status.hp = 0;
		die();
	GlobalManager.main.monsterHP.show_hp(type,status);

# 怪物死亡处理
func die():
	print("哥布林死亡")
	# 播放死亡动画
	$AnimationPlayer.play("down")
	# 禁用碰撞
	$CollisionShape2D.set_deferred("disabled", true)
	$BodyPivot/Offset/HurtBox/CollisionShape2D.set_deferred("disabled", true)
	
	# 通知父场景怪物死亡
	var parent_stage = get_parent().get_parent()
	if parent_stage != null and parent_stage.has_method("on_monster_died"):
		parent_stage.on_monster_died(self)
	
	# 延迟移除怪物
	await get_tree().create_timer(2.0).timeout
	queue_free()
