# Vendored CMake 3.26.4 ExternalProject module with the shinchiro patch
# (GIT_CLONE_FLAGS / GIT_CLONE_POST_COMMAND / GIT_RESET support) already applied.
#
# The previous implementation downloaded CMake's ExternalProject module at
# configure time from gitlab.kitware.com (the 'release' branch archive) — that
# endpoint now returns HTTP 403, and falling back to raw v3.26.4 files left the
# patched ExternalProject.cmake paired with the installed CMake's (4.x)
# gitclone.cmake.in template, breaking every GIT_REPOSITORY download with
# `math cannot parse "1 + "`. Vendoring removes the runtime dependency.
include(${CMAKE_CURRENT_LIST_DIR}/vendored/Modules/ExternalProject.cmake)
