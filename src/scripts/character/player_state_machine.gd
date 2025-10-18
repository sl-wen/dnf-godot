extends "res://src/scripts/state_machine/state_machine.gd"

@onready var idle = $Idle
@onready var move = $Move
@onready var jump = $Jump
@onready var damage = $Damage
@onready var attack = $Attack
@onready var skill = $Skill

func _ready():
	super._ready()
	# Re-key states_map to lowercase names to match emitted state names
	states_map = {
		"idle": idle,
		"move": move,
		"jump": jump,
		"damage": damage,
		"attack": attack,
		"skill": skill,
	}


func _change_state(state_name):
	# The base state_machine interface this node extends does most of the work.
	if not _active:
		return
	if state_name in ["damage", "jump", "attack", "skill"]:
		states_stack.push_front(states_map[state_name])
	if state_name == "jump" and current_state == move:
		jump.initialize(move.speed, move.velocity)
	super._change_state(state_name)


func _unhandled_input(event):
	# Here we only handle input that can interrupt states, attacking in this case,
	# otherwise we let the state node handle it.
	if event.is_action_pressed("attack"):
		if current_state == damage:
			return
		elif current_state == attack:
			# 如果已经在攻击状态，让攻击状态处理连击输入
			current_state.handle_input(event)
			return
		else:
			_change_state("attack")
			return
	if current_state:
		current_state.handle_input(event)

func attack_can_combo():
	current_state.can_combo = true;

# 启用连击（由动画事件调用）
func enable_combo():
	if current_state != null and current_state.has_method("enable_combo"):
		current_state.enable_combo();
	
func attack_sound():
	current_state.attack_sound();

func _on_animation_finished(anim_name):
	# 将动画完成事件传递给当前状态
	if current_state != null and current_state.has_method("_on_animation_finished"):
		current_state._on_animation_finished(anim_name);
