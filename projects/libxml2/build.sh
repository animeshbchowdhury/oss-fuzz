#!/bin/bash -eu
#
# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

set +eu
patch -f < $SRC/patch.diff
set -eu

./autogen.sh
./configure --prefix $SRC/build
make -j$(nproc) clean
make -j$(nproc) all
make install

for fuzzer in libxml2_xml_read_memory_fuzzer libxml2_xml_regexp_compile_fuzzer; do
  $CXX $CXXFLAGS -std=c++11 -Iinclude/ \
      $SRC/$fuzzer.cc -o $OUT/$fuzzer \
      -lFuzzingEngine .libs/libxml2.a
done

cp $SRC/*.dict $SRC/*.options $OUT/
