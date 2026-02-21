extends Node

# синглтон для спавна игрока

var in_game: bool = false

# заспавнить игрока
func spawn_player(player: PackedScene) -> void:
	in_game = true
	for obj in get_children():
		obj.queue_free()
	var player_instance = player.instantiate()
	player_instance.position = LevelHandler.spawn_position
	add_child(player_instance)

# удалить игрока
func despawn_player() -> void:
	in_game = false
	for obj in get_children():
		obj.queue_free()
