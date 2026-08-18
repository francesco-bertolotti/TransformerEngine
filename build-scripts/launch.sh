#!/bin/bash
set -euo pipefail

ROOT="$(realpath "$(dirname "$0")/..")"
cd $ROOT

mkdir -p $ROOT/logs
for d in build dist; do
    [[ -d $d ]] || continue
    read -rp "remove $d/ ($(du -sh --apparent-size "$d" | cut -f1), $(find "$d" -type f | wc -l) files)? [y/N] " ans || ans=n
    if [[ $ans == [yY] ]]; then rm -rf "$d"; else echo "keeping $d/"; fi
done

srun \
    --job-name=te-build \
    --account=$ACCOUNT \
    --partition=$PARTITION \
    --qos=$QOS \
    --nodes=1 \
    --gres=gpu:1 \
    --cpus-per-task=32 \
    --time=00:30:00 \
    --pty bash $ROOT/build-scripts/build.sh

uv pip install --python .venv/bin/python dist/*.whl

srun \
    --job-name=te-tests \
    --account=$ACCOUNT \
    --partition=$PARTITION \
    --qos=$QOS \
    --nodes=1 \
    --gres=gpu:1 \
    --cpus-per-task=32 \
    --time=00:30:00 \
    --pty bash $ROOT/build-scripts/test.sh
