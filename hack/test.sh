#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Gardener contributors
#
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o nounset
set -o pipefail

ENVTEST_K8S_VERSION=${ENVTEST_K8S_VERSION:-"1.22"}

echo "> Installing envtest tools@${ENVTEST_K8S_VERSION} with setup-envtest if necessary"
if ! command -v setup-envtest &> /dev/null ; then
  >&2 echo "setup-envtest not available"
  exit 1
fi

ARCH=
# if using M1 macbook, use amd64 architecture build, as suggested in
# https://github.com/kubernetes-sigs/controller-runtime/issues/1657#issuecomment-988484517
if [[ $(uname) == 'Darwin' && $(uname -m) == 'arm64' ]]; then
  ARCH='--arch=amd64'
fi

# --use-env allows overwriting the envtest tools path via the KUBEBUILDER_ASSETS env var just like it was before
export KUBEBUILDER_ASSETS="$(setup-envtest ${ARCH} use --use-env -p path ${ENVTEST_K8S_VERSION})"
echo "using envtest tools installed at '$KUBEBUILDER_ASSETS'"

echo "> Tests"

if [[ $(uname) == 'Darwin' ]]; then
  SED_BIN="gsed"
else
  SED_BIN="sed"
fi

export KUBEBUILDER_CONTROLPLANE_START_TIMEOUT=2m
export GOMEGA_DEFAULT_EVENTUALLY_TIMEOUT=5s
export GOMEGA_DEFAULT_EVENTUALLY_POLLING_INTERVAL=200ms
GINKGO_COMMON_FLAGS="-r -timeout=1h0m0s --randomize-all --randomize-suites --fail-on-pending --show-node-events"

if ${TEST_COV:-false}; then
  output_dir=test/output
  coverprofile_file=coverprofile.out
  mkdir -p test/output
  ginkgo $GINKGO_COMMON_FLAGS --coverprofile ${coverprofile_file} -covermode=set -outputdir ${output_dir} $@
  ${SED_BIN} -i '/mode: set/d' ${output_dir}/${coverprofile_file}
  {( echo "mode: set"; cat ${output_dir}/${coverprofile_file} )} > ${output_dir}/${coverprofile_file}.temp
  mv ${output_dir}/${coverprofile_file}.temp ${output_dir}/${coverprofile_file}
  go tool cover -func ${output_dir}/${coverprofile_file}
  exit 0
fi

ginkgo -trace $GINKGO_COMMON_FLAGS $@
