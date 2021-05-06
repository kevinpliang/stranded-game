extends KinematicBody2D

# 2D sprite
onready var zee_sprite = $ZeeSprite
var bullet = preload("res://objects/Bullet.tscn")

# player speed and velocity vector
export var speed = 75
var vel = Vector2(0, 0)

# stuff
var fire_rate = 0.5
var can_shoot = true
var dead = false

signal okay

func _ready():
	Global.player = self
	zee_sprite.play("idle")
	
func _exit_tree():
	Global.player = null
 
func _physics_process(delta):
	# calculate velocity
	vel.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	vel.y = (int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))) / float(2)
	
	# set boundaries
	global_position.x = clamp(global_position.x, 60, 317)
	global_position.y = clamp(global_position.y, 35, 150)
	
	# calculate motion (normalized)
	if !dead:
		var motion = vel.normalized() * speed
		move_and_slide(motion)

func _process(delta):
	if vel[0] > 0:
		$ZeeSprite.flip_h = false
		zee_sprite.play("walk")
	elif vel[0] < 0:
		$ZeeSprite.flip_h = true
		zee_sprite.play("walk")
	elif vel[1] < 0:
		zee_sprite.play("walk")
	elif vel[1] > 0:
		zee_sprite.play("walk")
	else:		
		zee_sprite.play("idle")
	
	if can_shoot and !dead and Input.is_action_pressed("left_click") and Global.node_creation_parent != null:
		# print(get_viewport().get_mouse_position())
		Global.instance_node(bullet, global_position, Global.node_creation_parent)
		$fireRate.start()
		can_shoot = false

# for restart
func _input(event):
	if(Input.is_action_pressed("ui_accept")):
		emit_signal("okay")

func _on_fireRate_timeout():
	can_shoot = true
	$fireRate.wait_time = fire_rate
	
# if you die
func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy"):
		dead = true
		visible = false
		Global.save_game()
		yield(self, "okay")
		get_tree().reload_current_scene()
