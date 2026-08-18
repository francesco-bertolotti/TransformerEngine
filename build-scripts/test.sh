#!/bin/bash
# Run an upstream qa suite against the source tree. Needs a GPU:
#   srun -A $ACCOUNT -p $PARTITION --gres=gpu:1 -t 08:00:00 bash build-scripts/test.sh
#   srun ... bash build-scripts/test.sh L0_pytorch_debug_unittest
# Suite defaults to L0_pytorch_unittest; see qa/ for the rest.
set -uo pipefail

ROOT="$(realpath "$(dirname "$0")/..")"
cd "$ROOT"
SP=$ROOT/.venv/lib/python3.13/site-packages

module purge
module load gcc/12.2.0     # libstdc++ with GLIBCXX_3.4.29, needed by libtransformer_engine.so
module load cuda/12.2

# The venv's nvidia/* libs MUST come first: torch here is cu126, and cuda/12.2's older libcudart
# would win otherwise -> ImportError: undefined symbol: cudaGetDriverEntryPointByVersion.
export LD_LIBRARY_PATH=$SP/nvidia/cuda_runtime/lib:$SP/nvidia/cudnn/lib:${LD_LIBRARY_PATH:-}
export PYTHONUTF8=1                 # torch/_inductor opens a UTF-8 template with no encoding=
export TE_PATH=$ROOT
export XML_LOG_DIR=$ROOT/logs       # qa default is /logs, not writable here
export NVIDIA_TF32_OVERRIDE=0       # A100 TF32 makes fp32 numerics tests flaky

# avoid pip3 download
export PATH=$ROOT/.venv/bin:$PATH
export -f pip3

exec bash qa/L0_pytorch_unittest/test.sh
exec bash qa/L0_pytorch_debug_unittest/test.sh
exec bash qa/L0_pytorch_unittest/test.sh
exec bash qa/L0_pytorch_wheel/test.sh
exec bash qa/L1_pytorch_distributed_unittest/test.sh
exec bash qa/L1_pytorch_hybrid_distributed_unittest/test.sh
exec bash qa/L1_pytorch_mcore_fsdp_integration/test.sh
exec bash qa/L1_pytorch_mcore_integration/test.sh
exec bash qa/L1_pytorch_onnx_unittest/test.sh
exec bash qa/L3_pytorch_FA_versions_test/test.sh
