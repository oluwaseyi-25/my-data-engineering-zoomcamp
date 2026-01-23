from pathlib import Path

current_dir = Path.cwd()
this_script_path = Path(__file__).name

print(f'Files in {current_dir}: ')

for file_path in current_dir.iterdir():
    if file_path.name == this_script_path:
        continue
    
    print (f"\t -- {file_path.name}")
    
    if file_path.is_file():
        content = file_path.read_text(encoding='utf-8')
        print(f'    Content: {content}')
    
    
    