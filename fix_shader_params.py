#!/usr/bin/env python3
"""
批量修复Godot 4.x兼容性问题：
1. 将 shader_param/ 替换为 shader_parameter/
2. 将 TileMap format=1 升级为 format=2
3. 将 tile_data 升级为 layer_0/tile_data
4. 将 cell_size 移除（Godot 4.x不再使用）
"""

import os
import re
import glob

def fix_tilemap_format(content):
    """修复TileMap格式"""
    # 替换 format = 1 为 format = 2
    content = re.sub(r'format = 1\b', 'format = 2', content)
    
    # 替换 tile_data 为 layer_0/tile_data
    content = re.sub(r'^tile_data = ', 'layer_0/tile_data = ', content, flags=re.MULTILINE)
    
    # 移除 cell_size 行（Godot 4.x不再使用）
    content = re.sub(r'^cell_size = Vector2\([^)]+\)\n', '', content, flags=re.MULTILINE)
    
    return content

def fix_shader_params(content):
    """修复shader参数"""
    return content.replace('shader_param/', 'shader_parameter/')

def fix_scene_format(content):
    """修复场景文件格式"""
    # 将 format=2 升级为 format=3（如果还没有升级）
    content = re.sub(r'\[gd_scene load_steps=(\d+) format=2\]', r'[gd_scene load_steps=\1 format=3]', content)
    
    # 修复ExtResource格式
    content = re.sub(r'\[ext_resource path="([^"]+)" type="([^"]+)" id=(\d+)\]', 
                    r'[ext_resource type="\2" path="\1" id="\3"]', content)
    
    # 修复SubResource引用格式
    content = re.sub(r'SubResource\( (\d+) \)', r'SubResource("\1")', content)
    content = re.sub(r'ExtResource\( (\d+) \)', r'ExtResource("\1")', content)
    
    return content

def fix_file(file_path):
    """修复单个文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 应用所有修复
        content = fix_shader_params(content)
        content = fix_tilemap_format(content)
        
        # 只对.tscn文件应用场景格式修复
        if file_path.endswith('.tscn'):
            content = fix_scene_format(content)
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"已修复: {file_path}")
            return True
        else:
            print(f"无需修复: {file_path}")
            return False
    except Exception as e:
        print(f"修复失败 {file_path}: {e}")
        return False

def main():
    """主函数"""
    # 查找所有需要修复的文件
    tscn_files = glob.glob("src/**/*.tscn", recursive=True)
    gd_files = glob.glob("src/**/*.gd", recursive=True)
    
    all_files = tscn_files + gd_files
    
    fixed_count = 0
    total_count = len(all_files)
    
    print(f"开始修复 {total_count} 个文件...")
    
    for file_path in all_files:
        if os.path.exists(file_path):
            if fix_file(file_path):
                fixed_count += 1
        else:
            print(f"文件不存在: {file_path}")
    
    print(f"\n修复完成! 共修复了 {fixed_count}/{total_count} 个文件")

if __name__ == "__main__":
    main()