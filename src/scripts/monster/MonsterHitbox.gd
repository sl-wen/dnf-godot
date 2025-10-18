extends Area2D

var attackData: AttackData

func _ready():
	# 连接碰撞信号
	area_entered.connect(_on_area_entered)
	monitoring = false  # 默认关闭监测

func _on_area_entered(area):
	# 检查是否碰撞到玩家的受击盒
	if area.name == "HurtBox" and area.get_parent().get_parent().name == "Character":
		var player = area.get_parent().get_parent()
		if player.has_method("take_damage") and attackData:
			print("怪物攻击命中玩家，造成伤害: ", attackData.damage)
			player.take_damage(self, attackData.damage)