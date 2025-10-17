#!/usr/bin/env python3
"""
修复Godot 4.x中的GDScript警告语法
将 # warning-ignore: 替换为 @warning_ignore()
"""

import os
import re
import glob

def fix_warning_syntax(content):
    """修复警告语法"""
    # 将 # warning-ignore:warning_name 替换为 @warning_ignore("warning_name")
    content = re.sub(
        r'# warning-ignore:([a-zA-Z_]+)',
        r'@warning_ignore("\1")',
        content
    )
    return content

def fix_file(file_path):
    """修复单个文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 修复警告语法
        content = fix_warning_syntax(content)
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"已修复: {file_path}")
            return True
        else:
            return False
    except Exception as e:
        print(f"修复失败 {file_path}: {e}")
        return False

def main():
    """主函数"""
    # 查找所有.gd文件
    gd_files = glob.glob("src/**/*.gd", recursive=True)
    
    fixed_count = 0
    total_count = len(gd_files)
    
    print(f"开始修复 {total_count} 个GDScript文件...")
    
    for file_path in gd_files:
        if os.path.exists(file_path):
            if fix_file(file_path):
                fixed_count += 1
        else:
            print(f"文件不存在: {file_path}")
    
    print(f"\n修复完成! 共修复了 {fixed_count}/{total_count} 个文件")

if __name__ == "__main__":
    main()