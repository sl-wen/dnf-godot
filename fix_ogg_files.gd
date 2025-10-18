@tool
extends EditorScript

# 修复项目中有问题的 Ogg Vorbis 文件
func _run():
	print("开始检查和修复 Ogg Vorbis 文件...")
	
	var problematic_files = [
		"res://assets/sounds/ui/icondrop.ogg",
		"res://assets/sounds/ui/click2.ogg"
	]
	
	for file_path in problematic_files:
		fix_ogg_file(file_path)
	
	print("Ogg Vorbis 文件修复完成！")

func fix_ogg_file(file_path: String):
	print("正在修复文件: ", file_path)
	
	# 加载原始音频流
	var original_stream = load(file_path) as AudioStreamOggVorbis
	if original_stream == null:
		print("无法加载文件: ", file_path)
		return
	
	# 创建新的音频流
	var new_stream = AudioStreamOggVorbis.new()
	
	# 获取原始数据
	var packet_sequence = original_stream.packet_sequence
	if packet_sequence == null:
		print("无法获取音频数据: ", file_path)
		return
	
	# 创建新的包序列，这会清除有问题的注释
	var new_packet_sequence = OggPacketSequence.new()
	
	# 复制音频数据但不包含有问题的注释
	var granule_positions = packet_sequence.granule_positions
	var sampling_rate = packet_sequence.sampling_rate
	
	new_packet_sequence.sampling_rate = sampling_rate
	new_packet_sequence.granule_positions = granule_positions
	
	# 复制数据包，但跳过注释包
	for i in range(packet_sequence.get_length()):
		var packet_data = packet_sequence.get_packet_data(i)
		if packet_data.size() > 0:
			# 检查是否是注释包（通常以特定字节开头）
			if packet_data[0] != 3:  # 3 表示注释包
				new_packet_sequence.push_packet(packet_data)
	
	# 设置新的包序列
	new_stream.packet_sequence = new_packet_sequence
	new_stream.loop = original_stream.loop
	new_stream.loop_offset = original_stream.loop_offset
	
	# 保存修复后的文件
	var result = ResourceSaver.save(new_stream, file_path)
	if result == OK:
		print("成功修复文件: ", file_path)
	else:
		print("修复文件失败: ", file_path, " 错误代码: ", result)