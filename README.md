# ragingos (ragingo + os)

みかん本に沿って開発。  
一通り終わったら改造する予定。

# 開発環境

- C++ 17
- Windows 11 WSL2 Ubuntu 20.04
- VSCode

# ツール

## pre-commit

https://pre-commit.com/

```sh
# セットアップ
sudo apt install -y python3.12-venv
python3 -m venv venv
source ./venv/bin/activate
pip install pre-commit
pre-commit install

# 実行
pre-commit run
```