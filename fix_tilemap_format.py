#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量移除Godot 4.x中不兼容的TileMap format属性
"""

import os
import re

def fix_tilemap_format(file_path):
    """移除文件中的format = 2属性"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 移除format = 2行
        original_content = content
        content = re.sub(r'^format = 2\s*$', '', content, flags=re.MULTILINE)
        
        # 如果内容有变化，写回文件
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"已修复: {file_path}")
            return True
        return False
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {e}")
        return False

def main():
    """主函数"""
    project_root = os.path.dirname(os.path.abspath(__file__))
    fixed_count = 0
    
    # 遍历所有.tscn文件
    for root, dirs, files in os.walk(project_root):
        for file in files:
            if file.endswith('.tscn'):
                file_path = os.path.join(root, file)
                if fix_tilemap_format(file_path):
                    fixed_count += 1
    
    print(f"\n总共修复了 {fixed_count} 个文件")

if __name__ == "__main__":
    main()