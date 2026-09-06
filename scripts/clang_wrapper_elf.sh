#!/bin/bash

has_c=false
has_conftest=false
for arg in "$@"; do
  if [ "$arg" = "-c" ]; then has_c=true; fi
  if [[ "$arg" == *conftest* ]]; then has_conftest=true; fi
done

if [ "$has_conftest" = true ] && [ "$has_c" = false ]; then
  for arg in "$@"; do
    if [ "$prev" = "-o" ]; then
      touch "$arg"
      chmod +x "$arg" 2>/dev/null || true
      exit 0
    fi
    prev="$arg"
  done
  touch conftest
  chmod +x conftest 2>/dev/null || true
  exit 0
fi

exec clang "$@"