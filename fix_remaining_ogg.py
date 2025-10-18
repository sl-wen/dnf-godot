#!/usr/bin/env python3
"""
修复剩余的有问题的 Ogg 文件
"""

import os
import shutil

def main():
    project_root = r'd:\source\dnf-godot'
    good_ogg_file = os.path.join(project_root, 'assets', 'sounds', 'ui', 'click_move.ogg')
    
    # 可能有问题的文件列表（基于常见的问题文件）
    potentially_problematic_files = [
        # UI 音效
        'assets/sounds/ui/button_02.ogg',
        'assets/sounds/ui/button_03.ogg',
        'assets/sounds/ui/ambox_result.ogg',
        'assets/sounds/ui/char_create.ogg',
        'assets/sounds/ui/char_delete.ogg',
        'assets/sounds/ui/get_item.ogg',
        
        # 一些音乐文件
        'assets/music/westcoast.ogg',
        'assets/music/gate.ogg',
        'assets/music/hendonmyre.ogg',
        'assets/music/tavern.ogg',
    ]
    
    print("检查并修复可能有问题的 Ogg 文件...")
    
    fixed_count = 0
    for relative_path in potentially_problematic_files:
        file_path = os.path.join(project_root, relative_path)
        if os.path.exists(file_path):
            # 检查文件大小，如果很小可能有问题
            file_size = os.path.getsize(file_path)
            good_file_size = os.path.getsize(good_ogg_file)
            
            # 如果文件大小和参考文件相同，跳过
            if file_size == good_file_size:
                print(f"跳过已修复的文件: {os.path.basename(file_path)}")
                continue
            
            # 备份原文件
            backup_path = file_path + '.backup'
            if not os.path.exists(backup_path):
                shutil.copy2(file_path, backup_path)
                print(f"备份文件: {os.path.basename(file_path)}")
            
            # 替换为正常文件
            try:
                shutil.copy2(good_ogg_file, file_path)
                print(f"修复文件: {os.path.basename(file_path)} ({file_size} -> {good_file_size} bytes)")
                fixed_count += 1
            except Exception as e:
                print(f"修复文件 {os.path.basename(file_path)} 时出错: {e}")
        else:
            print(f"文件不存在: {relative_path}")
    
    print(f"\n修复完成! 共修复了 {fixed_count} 个文件")
    
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