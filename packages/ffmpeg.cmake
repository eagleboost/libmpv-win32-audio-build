# Audio-only FFmpeg (LGPL) for the VoyTrace libmpv build.
# Source config follows current shinchiro/mpv-winbuild-cmake (master + sparse
# checkout, no patch series); configure flags restore the media-kit audio-only
# trim so libmpv-2.dll stays small (--disable-gpl keeps the build LGPL).
ExternalProject_Add(ffmpeg
    DEPENDS
        bzip2
        lame
        libpng
        libsoxr
        libmysofa
        harfbuzz
        opus
        speex
        vorbis
        libxml2
        mbedtls
    GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--sparse --filter=tree:0"
    GIT_CLONE_POST_COMMAND "sparse-checkout set --no-cone /* !tests/ref/fate"
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} CONF=1 <SOURCE_DIR>/configure
        --cross-prefix=${TARGET_ARCH}-
        --prefix=${MINGW_INSTALL_PREFIX}
        --arch=${TARGET_CPU}
        --target-os=mingw32
        --pkg-config-flags=--static
        --enable-cross-compile
        --enable-runtime-cpudetect

        --disable-gpl
        --disable-nonfree
        --enable-version3
        --enable-static
        --disable-shared
        --disable-vulkan
        --disable-iconv
        --enable-stripping

        --disable-muxers
        --disable-decoders
        --disable-encoders
        --disable-demuxers
        --disable-parsers
        --disable-protocols
        --disable-filters
        --disable-doc
        --disable-postproc
        --disable-programs
        --disable-gray
        --disable-swscale-alpha

        --enable-bsfs

        --disable-amf
        --disable-cuda
        --disable-nvdec
        --disable-nvenc
        --disable-cuvid
        --disable-dxva2
        --disable-libmfx
        --disable-d3d11va
        --disable-vaapi
        --disable-vdpau
        --disable-bzlib
        --disable-libuavs3d
        --disable-ffnvcodec
        --disable-linux-perf
        --disable-videotoolbox
        --disable-audiotoolbox

        --enable-small
        --enable-hwaccels
        --enable-optimizations

        --enable-mbedtls

        --disable-libjxl
        --disable-libplacebo

        --enable-avutil
        --enable-avcodec
        --enable-avfilter
        --enable-avformat
        --enable-avdevice
        --enable-swscale
        --enable-swresample

        --enable-decoder=aac*
        --enable-decoder=ac3
        --enable-decoder=alac
        --enable-decoder=als
        --enable-decoder=ape
        --enable-decoder=atrac*
        --enable-decoder=eac3
        --enable-decoder=flac
        --enable-decoder=gsm*
        --enable-decoder=mp1*
        --enable-decoder=mp2*
        --enable-decoder=mp3*
        --enable-decoder=mpc*
        --enable-decoder=opus
        --enable-decoder=ra*
        --enable-decoder=ralf
        --enable-decoder=shorten
        --enable-decoder=tak
        --enable-decoder=tta
        --enable-decoder=vorbis
        --enable-decoder=wavpack
        --enable-decoder=wma*
        --enable-decoder=pcm*
        --enable-decoder=dsd*
        --enable-decoder=dca

        # embedded-cover decoders (album art in tags/containers)
        --enable-decoder=mjpeg
        --enable-decoder=ljpeg
        --enable-decoder=jpegls
        --enable-decoder=jpeg2000
        --enable-decoder=png
        --enable-decoder=gif
        --enable-decoder=bmp
        --enable-decoder=tiff
        --enable-decoder=webp

        --enable-demuxer=aac
        --enable-demuxer=ac3
        --enable-demuxer=aiff
        --enable-demuxer=ape
        --enable-demuxer=asf
        --enable-demuxer=au
        --enable-demuxer=avi
        --enable-demuxer=flac
        --enable-demuxer=flv
        --enable-demuxer=matroska
        --enable-demuxer=mov
        --enable-demuxer=m4v
        --enable-demuxer=mp3
        --enable-demuxer=mpc*
        --enable-demuxer=ogg
        --enable-demuxer=pcm*
        --enable-demuxer=rm
        --enable-demuxer=shorten
        --enable-demuxer=tak
        --enable-demuxer=tta
        --enable-demuxer=wav
        --enable-demuxer=wv
        --enable-demuxer=xwma
        --enable-demuxer=dsf
        --enable-demuxer=dts
        --enable-demuxer=truehd
        --enable-demuxer=dtshd

        --enable-parser=aac*
        --enable-parser=ac3
        --enable-parser=cook
        --enable-parser=flac
        --enable-parser=gsm
        --enable-parser=mpegaudio
        --enable-parser=tak
        --enable-parser=vorbis
        --enable-parser=dca

        --enable-filter=overlay
        --enable-filter=equalizer

        --enable-protocol=async
        --enable-protocol=cache
        --enable-protocol=crypto
        --enable-protocol=data
        --enable-protocol=ffrtmphttp
        --enable-protocol=file
        --enable-protocol=ftp
        --enable-protocol=hls
        --enable-protocol=http
        --enable-protocol=httpproxy
        --enable-protocol=https
        --enable-protocol=pipe
        --enable-protocol=rtmp
        --enable-protocol=rtmps
        --enable-protocol=rtmpt
        --enable-protocol=rtmpts
        --enable-protocol=rtp
        --enable-protocol=subfile
        --enable-protocol=tcp
        --enable-protocol=tls
        --enable-protocol=srt

        --enable-encoder=mjpeg
        --enable-encoder=ljpeg
        --enable-encoder=jpegls
        --enable-encoder=jpeg2000
        --enable-encoder=png

        --enable-network

        ${ffmpeg_lto}
        --extra-cflags='-Wno-error=int-conversion'
        "--extra-libs='${ffmpeg_extra_libs}'"
    BUILD_COMMAND ${MAKE}
    INSTALL_COMMAND ${MAKE} install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(ffmpeg)
cleanup(ffmpeg install)
