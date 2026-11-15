#!/usr/bin/env python3
"""Inject audio_metrics (FFT / PCM tap) into an mpv source tree — meson build.

Port of eagleboost/libmpv-android-audio-build buildscripts/inject_audio_metrics.py
(waf → meson). Called from packages/mpv.cmake as the ExternalProject
UPDATE_COMMAND (runs on every build, idempotent):

    python3 scripts/inject_audio_metrics.py <mpv-source-dir>

Differences from the Android (waf) version:
  * Sources are registered in the ROOT meson.build `sources = files(...)` list
    (modern mpv has no per-directory audio/meson.build).
  * Symbols are exported via AM_EXPORT (__declspec(dllexport) on Windows,
    default visibility elsewhere) in audio_metrics.h — the meson build links
    libmpv with gnu_symbol_visibility:'hidden' and does not use libmpv/mpv.def,
    so the Android fork's mpv.def append would be a no-op here.
  * ao.c includes "../audio_metrics.h" (meson only sets up ./include + the
    file's own directory for includes, not the tree root).
"""
import os
import re
import sys

SRC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'audio_metrics')


def inject(mpv_dir: str) -> None:
    # 1) Copy audio_metrics.c/.h into mpv/audio/.
    for f in ('audio_metrics.h', 'audio_metrics.c'):
        with open(os.path.join(SRC_DIR, f)) as fh:
            content = fh.read()
        dst = os.path.join(mpv_dir, 'audio', f)
        with open(dst, 'w') as fh:
            fh.write(content)
        print(f"[audio_metrics] Copied audio/{f}")

    # 2) Register the source in the root meson.build `sources = files(...)` list.
    root_meson = os.path.join(mpv_dir, 'meson.build')
    with open(root_meson) as fh:
        content = fh.read()
    if 'audio_metrics.c' not in content:
        marker = "    'audio/aframe.c',"
        if marker not in content:
            raise SystemExit(
                "[audio_metrics] ERROR: could not find audio source list marker "
                "in root meson.build — upstream layout changed?"
            )
        content = content.replace(
            marker, "    'audio/audio_metrics.c',\n" + marker, 1)
        with open(root_meson, 'w') as fh:
            fh.write(content)
        print("[audio_metrics] Patched meson.build (sources)")

    # 3) Hook ao_post_process_data() — feeds every audio buffer played by any
    #    audio output into the FFT / PCM tap pipeline.
    ao = os.path.join(mpv_dir, 'audio', 'out', 'ao.c')
    with open(ao) as fh:
        content = fh.read()
    if 'audio_metrics' not in content:
        content = content.replace(
            '#include <stdio.h>',
            '#include <stdio.h>\n#include "../audio_metrics.h"',
            1,
        )
        hook = (
            '\n'
            '    if (data && data[0] && num_samples > 0) {\n'
            '        audio_metrics_feed(data[0], num_samples, ao->channels.num,\n'
            '                          af_fmt_to_bytes(af_fmt_from_planar(ao->format)),\n'
            '                          ao->samplerate);\n'
            '    }\n'
        )
        pattern = (r'void\s+ao_post_process_data\s*\(\s*struct\s+ao\s+\*ao\s*,'
                   r'\s*void\s*\*\*\s*data\s*,\s*int\s+num_samples\s*\)\s*\{')
        patched, n = re.subn(pattern, lambda m: m.group(0) + hook, content, count=1)
        if n != 1:
            raise SystemExit(
                "[audio_metrics] ERROR: could not find ao_post_process_data "
                "in audio/out/ao.c — upstream signature changed?"
            )
        with open(ao, 'w') as fh:
            fh.write(patched)
        print("[audio_metrics] Patched audio/out/ao.c")

    print("[audio_metrics] Injection complete.")


if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    mpv = os.path.abspath(sys.argv[1])
    if not os.path.isdir(mpv):
        raise SystemExit(f"[audio_metrics] ERROR: {mpv} not found")
    inject(mpv)
