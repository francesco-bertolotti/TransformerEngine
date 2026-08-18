#!/bin/bash
set -euo pipefail

ROOT="$(realpath "$(dirname "$0")/..")"
cd "$ROOT"

module purge
module load gcc/12.2.0
module load cuda/12.2
module load nccl


export LD_LIBRARY_PATH=$ROOT/.venv/lib/python3.13/site-packages/nvidia/cudnn/lib:${LD_LIBRARY_PATH:-}
export CPATH=$ROOT/.venv/lib/python3.13/site-packages/nvidia/cudnn/include:${CPATH:-}
export NVTE_CUDA_ARCHS=80
export NVTE_FRAMEWORK=pytorch
export MAX_JOBS="${SLURM_CPUS_PER_TASK:-1}"
export NVTE_BUILD_THREADS_PER_JOB=1

uv build --wheel -vvv --no-build-isolation --out-dir dist/

