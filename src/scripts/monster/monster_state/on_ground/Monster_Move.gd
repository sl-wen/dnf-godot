extends "res://src/scripts/monster/monster_state/on_ground/Monster_on_ground.gd"

var move_speed: float = 100.0

func _ready():
	pass

func enter():
	owner.get_node("AnimationPlayer").play("move")
	if owner.status:
		move_speed = owner.status.move_speed

func update(delta):
	# 如果有目标玩家，向玩家移动
	if owner != null and owner.target_player != null:
		var direction = (owner.target_player.global_position - owner.global_position).normalized()
		owner.velocity.x = direction.x * move_speed
		owner.move_and_slide()
		
		# 检查是否到达攻击范围
		var distance = owner.global_position.distance_to(owner.target_player.global_position)
		if distance <= 60.0:  # 攻击范围
			emit_signal("finished", "attack")
	else:
		# 没有目标，返回idle状态
		emit_signal("finished", "idle")
