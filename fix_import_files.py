#!/usr/bin/env python3
"""
批量修复Godot 4.x中的.import文件
移除 valid=false 并添加正确的路径信息
"""

import os
import re
import glob

def fix_import_file(file_path):
    """修复单个.import文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 检查是否包含 valid=false
        if 'valid=false' not in content:
            return False
        
        # 提取uid
        uid_match = re.search(r'uid="([^"]+)"', content)
        if not uid_match:
            print(f"无法找到uid: {file_path}")
            return False
        
        uid = uid_match.group(1)
        
        # 生成文件名（去掉.import后缀）
        source_file_name = os.path.basename(file_path).replace('.import', '')
        
        # 移除 valid=false 行
        content = re.sub(r'valid=false\n', '', content)
        
        # 添加path和metadata
        path_line = f'path="res://.godot/imported/{source_file_name}-{uid.replace("uid://", "")}.ctex"'
        metadata_lines = 'metadata={\n"vram_texture": false\n}'
        
        # 在uid行后添加path和metadata
        content = re.sub(
            r'(uid="[^"]+")(\n)',
            f'\\1\n{path_line}\n{metadata_lines}\\2',
            content
        )
        
        # 添加dest_files到[deps]部分
        dest_files_line = f'dest_files=["res://.godot/imported/{source_file_name}-{uid.replace("uid://", "")}.ctex"]'
        
        # 在source_file行后添加dest_files
        content = re.sub(
            r'(source_file="[^"]+")(\n)',
            f'\\1\n{dest_files_line}\\2',
            content
        )
        
        # 写回文件
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"已修复: {file_path}")
        return True
        
    except Exception as e:
        print(f"修复失败 {file_path}: {e}")
        return False

def main():
    """主函数"""
    # 查找所有.import文件
    import_files = glob.glob("assets/**/*.import", recursive=True)
    
    fixed_count = 0
    total_count = len(import_files)
    
    print(f"开始修复 {total_count} 个.import文件...")
    
    for file_path in import_files:
        if os.path.exists(file_path):
            if fix_import_file(file_path):
                fixed_count += 1
        else:
            print(f"文件不存在: {file_path}")
    
    print(f"\n修复完成! 共修复了 {fixed_count}/{total_count} 个文件")

if __name__ == "__main__":
    main()