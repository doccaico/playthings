import json
import os
import shutil
import subprocess

download_dir = f'{os.getenv('USERPROFILE')}\\Downloads'
os.chdir(download_dir)
print(f'Changed directory => {download_dir}')

cmd = ['curl', '-sS', 'https://ziglang.org/download/index.json']
res = subprocess.run(cmd, shell=True, capture_output=True)
json_data = json.loads(res.stdout)
url = json_data['master']['x86_64-windows']['tarball']
print(f'Download URL => {url}')

cmd = ['curl', '-sSOL', url]
subprocess.run(cmd, shell=True)
print('Download is done')

filename = os.path.basename(url)
# -bso0 は、標準出力（stdout）を無効にして、-bsp0 は、進捗情報の出力を無効にする
cmd = ['7za', 'x', '-aoa', filename, '-bso0', '-bsp0']
res = subprocess.run(cmd, shell=True)
print('Extraction is done')

zig_dir = 'C:\\Langs\\zig'
if os.path.exists(zig_dir):
    shutil.rmtree(zig_dir)

new_zig_dir = filename.replace('.zip', '', 1)
new_path = shutil.move(new_zig_dir, zig_dir)

os.remove(filename)
