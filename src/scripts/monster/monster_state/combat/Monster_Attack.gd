extends "res://src/scripts/state_machine/state.gd"

var attack_timer: float = 0.0
var attack_delay: float = 1.5  # 攻击间隔
var is_attacking: bool = false

func _ready():
	pass

func enter():
	print("怪物开始攻击")
	if owner != null:
		owner.get_node("AnimationPlayer").play("attack")
	is_attacking = true
	attack_timer = 0.0
	
	# 设置攻击延迟
	if owner != null and owner.status != null:
		attack_delay = owner.status.attack_delay / 1000.0  # 转换为秒
	
	# 启用攻击碰撞盒
	if owner != null and owner.hitbox != null:
		owner.hitbox.monitoring = true
		# 创建攻击数据
		var attack_data = AttackData.new()
		if owner.status != null:
			attack_data.damage = owner.status.physical_attack
			attack_data.x_offset = 50
		owner.hitbox.attackData = attack_data

func update(delta):
	attack_timer += delta
	
	# 攻击动画结束后的处理
	if attack_timer >= attack_delay:
		is_attacking = false
		# 禁用攻击碰撞盒
		if owner != null and owner.hitbox != null:
			owner.hitbox.monitoring = false
		
		# 检查玩家是否还在攻击范围内
		if owner != null and owner.player_in_attack_range:
			# 继续攻击
			enter()
		elif owner != null and owner.player_in_sight:
			# 玩家在视野内但不在攻击范围，切换到移动状态
			emit_signal("finished", "move")
		else:
			# 玩家不在视野内，切换到idle状态
			emit_signal("finished", "idle")

func exit():
	# 禁用攻击碰撞盒
	if owner != null and owner.hitbox != null:
		owner.hitbox.monitoring = false
	is_attacking = false
