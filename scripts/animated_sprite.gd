@tool
extends Node2D

@export_category("Slicing Data")
@export var target_animatedSprite: AnimatedSprite2D
@export var base_anim_name: String
@export var directions: Array[String] = ["up", "left", "down", "right"]
@export var rows: int = 4
@export var cols: int = 4
@export var fps: float = 1.0
@export var sprite_sheet: Texture2D

@export var generate: bool:
	set(value):
		if value:
			add_animations()
		generate = false
	get:
		return generate
			
@export_category("Animation Sync")
# Make sure anim_type is in right order
@export var anim_type: Array[String]
@export var action: String
@export var direction: String
@export var play: bool:
	set(value):
		if value:
			play_animation(anim_type, action, direction)
		play = false
	get:
		return play


@onready var holder: Node2D = $"../holder"

func _ready() -> void:
	pass

func add_animations() -> void:
	if not target_animatedSprite or not sprite_sheet:
		printerr("Missing AnimatedSprite2D or sprite sheet")
		return
	
	var Frames: SpriteFrames = target_animatedSprite.sprite_frames
	var frame_width: float = sprite_sheet.get_width() / cols
	var frame_height: float = sprite_sheet.get_height() / rows
	
	for dir_index in range(rows):
		# Build animation name per direction
		var anim_name = "%s_%s" % [base_anim_name, directions[dir_index]]
		
		# Clear or create animation
		if Frames.has_animation(anim_name):
			Frames.clear(anim_name)
		else:
			Frames.add_animation(anim_name)
		
		# Slice frames horizontally
		for frame_idx in range(cols):
			var region: Rect2 = Rect2(
				Vector2(frame_idx * frame_width, dir_index * frame_height),
				Vector2(frame_width, frame_height)
			)
			
			var frame_texture: AtlasTexture = AtlasTexture.new()
			frame_texture.atlas = sprite_sheet
			frame_texture.region = region
			
			Frames.add_frame(anim_name, frame_texture)
		
		# Set FPS for this animation
		Frames.set_animation_speed(anim_name, fps)
	
	print("Animations generated successfully.")

func play_animation(types: Array[String], action: String, direction: String) -> void:
	# Playing the right animation
	for index: int in range(types.size()):
		var anim_name: String = "%s_%s_%s" % [types[index], action, direction]
		var animPlayer: AnimatedSprite2D = holder.get_child(index)
		animPlayer.play(anim_name)
		
	# Syncing them
	var primary_anim: AnimatedSprite2D = holder.get_child(0)
	if not primary_anim.frame_changed.is_connected(sync_frame):
		primary_anim.frame_changed.connect(sync_frame)
	for i: int in range(1, types.size()):
		var animPlayer: AnimatedSprite2D = holder.get_child(i)
		animPlayer.frame = primary_anim.frame
		
func sync_frame() -> void:
	var primary_anim: AnimatedSprite2D = holder.get_child(0)
	for i: int in range(1, holder.get_child_count()):
		var animPlayer: AnimatedSprite2D = holder.get_child(i)
		animPlayer.frame = primary_anim.frame
		
