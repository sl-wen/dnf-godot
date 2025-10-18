#!/usr/bin/env python3
"""
识别具体哪些 Ogg 文件有注释问题
"""

import os
import subprocess
import tempfile

def test_ogg_file(file_path):
    """测试单个 Ogg 文件是否有问题"""
    # 创建一个临时的 Godot 脚本来测试音频文件
    test_script_content = f'''extends Node

func _ready():
    var audio_stream = load("{file_path.replace(os.sep, "/").replace("d:/source/dnf-godot/", "res://")}")
    if audio_stream:
        print("文件加载成功: {os.path.basename(file_path)}")
    else:
        print("文件加载失败: {os.path.basename(file_path)}")
    get_tree().quit()
'''
    
    # 创建临时脚本文件
    temp_script_path = os.path.join(os.path.dirname(file_path), 'temp_test.gd')
    try:
        with open(temp_script_path, 'w', encoding='utf-8') as f:
            f.write(test_script_content)
        
        # 运行 Godot 测试
        result = subprocess.run([
            r'D:\Program\Godot4\Godot_v4.5-stable_win64.exe',
            '--headless',
            '--script',
            temp_script_path
        ], capture_output=True, text=True, cwd=r'd:\source\dnf-godot')
        
        # 检查是否有 "Invalid comment" 错误
        has_error = "Invalid comment in Ogg Vorbis file" in result.stderr
        return has_error, result.stderr
        
    except Exception as e:
        return False, str(e)
    finally:
        # 清理临时文件
        if os.path.exists(temp_script_path):
            os.remove(temp_script_path)

def main():
    project_root = r'd:\source\dnf-godot'
    
    # 获取所有 Ogg 文件
    ogg_files = []
    for root, dirs, files in os.walk(project_root):
        for file in files:
            if file.lower().endswith('.ogg'):
                ogg_files.append(os.path.join(root, file))
    
    print(f"找到 {len(ogg_files)} 个 Ogg 文件")
    
    # 检查一些可能有问题的文件
    # 基于文件大小和位置进行初步筛选
    suspicious_files = []
    
    # 检查 UI 音效文件
    ui_sound_dir = os.path.join(project_root, 'assets', 'sounds', 'ui')
    if os.path.exists(ui_sound_dir):
        for file in os.listdir(ui_sound_dir):
            if file.endswith('.ogg'):
                file_path = os.path.join(ui_sound_dir, file)
                suspicious_files.append(file_path)
    
    # 检查音乐文件
    music_dir = os.path.join(project_root, 'assets', 'music')
    if os.path.exists(music_dir):
        for file in os.listdir(music_dir):
            if file.endswith('.ogg'):
                file_path = os.path.join(music_dir, file)
                suspicious_files.append(file_path)
    
    print(f"检查 {len(suspicious_files)} 个可疑文件...")
    
    problematic_files = []
    
    for file_path in suspicious_files[:10]:  # 限制检查数量以避免太慢
        print(f"检查: {os.path.basename(file_path)}")
        has_error, error_output = test_ogg_file(file_path)
        if has_error:
            problematic_files.append(file_path)
            print(f"  ❌ 发现问题: {os.path.basename(file_path)}")
        else:
            print(f"  ✅ 正常: {os.path.basename(file_path)}")
    
    if problematic_files:
        print(f"\n发现 {len(problematic_files)} 个有问题的文件:")
        for file_path in problematic_files:
            print(f"  - {os.path.relpath(file_path, project_root)}")
    else:
        print("\n在检查的文件中没有发现问题")

if __name__ == "__main__":
    main()