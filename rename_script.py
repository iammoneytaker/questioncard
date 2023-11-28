import os
import unidecode

def romanize_filename(directory):
    for filename in os.listdir(directory):
        if filename.endswith(".png"):  # 확장자가 .png인 파일만 처리
            romanized_name = unidecode.unidecode(filename.split('.')[0]) + '.png'
            original_path = os.path.join(directory, filename)
            new_path = os.path.join(directory, romanized_name)
            os.rename(original_path, new_path)
            print(f"Renamed {filename} to {romanized_name}")

# 사용 예시
directory_path = 'assets/images/persongame/rapper'  # 이미지가 있는 디렉토리 경로
romanize_filename(directory_path)
