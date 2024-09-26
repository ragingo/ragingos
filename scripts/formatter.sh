#!/bin/bash -e

(git diff --name-only --diff-filter=AM && git diff --name-only --diff-filter=AM --cached) | \
    grep -v "lib/" | \
    grep -E "\.(h|hpp|c|cpp)$" | \
    xargs -i% clang-format -i % -style=file
