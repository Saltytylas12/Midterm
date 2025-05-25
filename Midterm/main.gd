extends Node

@export var mob_scene: PackedScene
var score = 0
var game_active = false

func _ready():
	new_game()

func game_over():
	game_active = false
	
	$ScoreTimer.stop()
	$MobTimer.stop()
	$StartTimer.stop()
	
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	
	get_tree().call_group("mobs", "queue_free")
	$Player.hide()
	$Player.set_process(false)
	$Player.set_physics_process(false)
	$Player.set_collision_layer(0)
	$Player.set_collision_mask(0)

func new_game():
	score = 0
	game_active = true
	
	get_tree().call_group("mobs", "queue_free")
	
	$Player.show()
	$Player.set_process(true)
	$Player.set_physics_process(true)
	$Player.set_collision_layer(1)
	$Player.set_collision_mask(1)

	$Player.start($StartPosition.position)
	
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()

func _on_score_timer_timeout():
	if game_active:
		score += 1
		$HUD.update_score(score)

func _on_start_timer_timeout():
	if game_active:
		$MobTimer.start()
		$ScoreTimer.start()

func _on_mob_timer_timeout():
	if not game_active:
		return

	var mob = mob_scene.instantiate()

	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	var direction = mob_spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)

	mob.position = mob_spawn_location.position
	mob.rotation = direction
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	add_child(mob)
	mob.add_to_group("mobs")
