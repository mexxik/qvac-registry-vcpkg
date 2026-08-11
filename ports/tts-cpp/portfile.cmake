# tts-cpp: Resemble Chatterbox + Supertonic + CosyVoice3 + Parler-TTS + Audio8
# in pure C++/ggml, from the engines/tts subfolder of qvac-ext-lib-whisper.cpp;
# consumes the ggml-speech port.
#
# Pinned at 8f6575d7 (QVAC-22775): CosyVoice3 Metal GPU on darwin/ios via the
# Metal-or-OpenCL selection requirement, with per-stage GPU parity gates and
# both review rounds applied.
# PRE-FLIGHT PIN: sourced from the mexxik fork until ext-lib PR merges to
# master; repoint REPO/REF to the tetherto master merge commit before the
# real registry PR. The ggml-speech floor stays at 2026-08-07.

set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH WHISPER_CPP_SRC
    REPO mexxik/qvac-ext-lib-whisper.cpp
    REF 8f6575d77c2b62492e17037ba08227d05d4b8422
    SHA512 d8c862e8832724b666c8871198d0d6ff502d0fb677daac9af82c1a8254e2f248007fc0f0b3a3c89840c8c4253806917fbe5a20bc49e24c196eca1abefd742f3e
    HEAD_REF feat/QVAC-22775-cosyvoice-metal
)

set(SOURCE_PATH "${WHISPER_CPP_SRC}/engines/tts")
if (NOT EXISTS "${SOURCE_PATH}/CMakeLists.txt")
    message(FATAL_ERROR
        "tts-cpp: ${SOURCE_PATH}/CMakeLists.txt missing; the engines/tts/ "
        "subfolder layout in qvac-ext-lib-whisper.cpp may have changed.")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        metal   GGML_METAL
        vulkan  GGML_VULKAN
        cuda    GGML_CUDA
        opencl  GGML_OPENCL
)

set(PLATFORM_OPTIONS)

if(NOT VCPKG_TARGET_IS_OSX)
    list(APPEND PLATFORM_OPTIONS
        -DGGML_BLAS=OFF
        -DGGML_ACCELERATE=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_BLAS=ON
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DTTS_CPP_BUILD_LIBRARY=ON
        -DTTS_CPP_BUILD_SHARED=OFF
        -DTTS_CPP_BUILD_EXECUTABLES=OFF
        -DTTS_CPP_BUILD_TESTS=OFF
        -DTTS_CPP_INSTALL=ON
        -DTTS_CPP_USE_SYSTEM_GGML=ON
        -DBUILD_SHARED_LIBS=OFF
        -DGGML_NATIVE=OFF
        -DGGML_OPENMP=OFF
        -DTTS_CPP_OPENMP=OFF
        -DGGML_CCACHE=OFF
        -DTTS_CPP_CCACHE=OFF
        ${FEATURE_OPTIONS}
        ${PLATFORM_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME tts-cpp CONFIG_PATH share/tts-cpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if (VCPKG_LIBRARY_LINKAGE MATCHES "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
