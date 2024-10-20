# ragingos (ragingo + os)

自分の学習用自作OS (MikanOS ベース)

# 開発環境

- C++ 23
- Windows 11 WSL2 Ubuntu 24.04
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