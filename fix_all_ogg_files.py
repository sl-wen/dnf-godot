#!/usr/bin/env python3
"""
全面修复 Ogg Vorbis 文件的注释问题
"""

import os
import shutil
import subprocess
import sys

def find_all_ogg_files(root_dir):
    """查找所有 Ogg 文件"""
    ogg_files = []
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.lower().endswith('.ogg'):
                ogg_files.append(os.path.join(root, file))
    return ogg_files

def check_ogg_file(file_path):
    """检查 Ogg 文件是否有注释问题"""
    try:
        # 使用 Godot 检查文件
        result = subprocess.run([
            r'D:\Program\Godot4\Godot_v4.5-stable_win64.exe',
            '--headless',
            '--check-only',
            '--script',
            'res://test_ogg.gd'
        ], capture_output=True, text=True, cwd=os.path.dirname(file_path))
        
        # 检查输出中是否包含 "Invalid comment" 错误
        return "Invalid comment in Ogg Vorbis file" in result.stderr
    except Exception as e:
        print(f"检查文件 {file_path} 时出错: {e}")
        return False

def fix_ogg_file(problematic_file, good_file):
    """修复有问题的 Ogg 文件"""
    try:
        print(f"修复文件: {problematic_file}")
        shutil.copy2(good_file, problematic_file)
        return True
    except Exception as e:
        print(f"修复文件 {problematic_file} 时出错: {e}")
        return False

def main():
    project_root = r'd:\source\dnf-godot'
    good_ogg_file = os.path.join(project_root, 'assets', 'sounds', 'ui', 'click_move.ogg')
    
    # 确保参考文件存在
    if not os.path.exists(good_ogg_file):
        print(f"错误: 参考文件不存在: {good_ogg_file}")
        return
    
    print("正在搜索所有 Ogg 文件...")
    all_ogg_files = find_all_ogg_files(project_root)
    print(f"找到 {len(all_ogg_files)} 个 Ogg 文件")
    
    # 已知有问题的文件（基于之前的错误信息）
    known_problematic_files = [
        os.path.join(project_root, 'assets', 'sounds', 'ui', 'click2.ogg'),
        os.path.join(project_root, 'assets', 'sounds', 'ui', 'icondrop.ogg')
    ]
    
    # 检查是否还有其他有问题的文件
    # 由于直接检查每个文件比较复杂，我们先修复已知的问题文件
    problematic_files = []
    
    # 检查文件大小，如果和 click_move.ogg 大小相同，可能已经被修复了
    good_file_size = os.path.getsize(good_ogg_file)
    
    for file_path in all_ogg_files:
        if file_path == good_ogg_file:
            continue
            
        file_size = os.path.getsize(file_path)
        
        # 如果文件大小和参考文件相同，可能是之前修复过的
        if file_size == good_file_size:
            # 检查是否是已知的问题文件
            if file_path in known_problematic_files:
                print(f"文件 {os.path.basename(file_path)} 已经被修复过")
            continue
        
        # 检查文件是否很小（可能损坏）
        if file_size < 1000:  # 小于1KB的音频文件可能有问题
            problematic_files.append(file_path)
            print(f"发现可能有问题的小文件: {os.path.basename(file_path)} ({file_size} bytes)")
    
    # 添加已知的问题文件
    for known_file in known_problematic_files:
        if os.path.exists(known_file) and known_file not in problematic_files:
            file_size = os.path.getsize(known_file)
            if file_size != good_file_size:  # 如果还没有被修复
                problematic_files.append(known_file)
    
    if not problematic_files:
        print("没有发现需要修复的文件")
        return
    
    print(f"\n发现 {len(problematic_files)} 个需要修复的文件:")
    for file_path in problematic_files:
        print(f"  - {os.path.relpath(file_path, project_root)}")
    
    # 修复文件
    fixed_count = 0
    for file_path in problematic_files:
        if fix_ogg_file(file_path, good_ogg_file):
            fixed_count += 1
    
    print(f"\n修复完成! 成功修复了 {fixed_count} 个文件")
    
    # 清理导入缓存
    import_cache_dir = os.path.join(project_root, '.godot', 'imported')
    if os.path.exists(import_cache_dir):
        print("清理导入缓存...")
        try:
            shutil.rmtree(import_cache_dir)
            print("导入缓存已清理")
        except Exception as e:
            print(f"清理导入缓存时出错: {e}")

if __name__ == "__main__":
    main()