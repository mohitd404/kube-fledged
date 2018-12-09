#!/usr/bin/env bash

# Copyright 2018 The kube-fledged authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

PROJECT_ROOT=$(dirname "${BASH_SOURCE}")/..
source "${PROJECT_ROOT}/hack/init.sh"

cd "${PROJECT_ROOT}"

# This is required before we run govet for the results to be correct.
# See https://github.com/golang/go/issues/16086 for details.
go install ./cmd/...

# Use eval to preserve embedded quoted strings.
eval "goflags=(${GOFLAGS:-})"

# Filter out arguments that start with "-" and move them to goflags.
targets=()
for arg; do
  if [[ "${arg}" == -* ]]; then
    goflags+=("${arg}")
  else
    targets+=("${arg}")
  fi
done

if [[ ${#targets[@]} -eq 0 ]]; then
  # Do not run on vendor directories or generated client code.
  targets=$(go list -e ./... | egrep -v "/(vendor|clientset_generated)/")
fi

go vet "${goflags[@]:+${goflags[@]}}" ${targets[@]}
