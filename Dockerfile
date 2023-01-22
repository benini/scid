# Use a container to compile the code.
# The follow command would compile the code and create in the current directory
# a scid directory and a lib directory with the tcl/tk library:
# docker run --rm -v ${PWD}:/scid:Z $(docker build -q .)
# After that scid/scid should start the app.

FROM debian:bullseye

WORKDIR /build
CMD apt-get update && apt-get install -qq -y --no-install-recommends \
        ca-certificates git build-essential cmake zlib1g-dev libx11-dev \
    && git clone --depth=1 --branch core-8-6-branch https://github.com/tcltk/tcl.git \
    && git clone --depth=1 --branch core-8-6-branch https://github.com/tcltk/tk.git \
    && git clone --depth=1 https://git.code.sf.net/p/scid/code scid_code \
    && cd /build/tcl && cd unix \
    && ./configure --prefix=/tcltk --disable-shared --enable-threads \
    && make -j && make install \
    && cd /build/tk && cd unix \
    && ./configure --prefix=/tcltk --enable-threads \
    && make -j && make install \
    && cd /build \
    && cmake -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_CXX_FLAGS="-fno-exceptions -fno-rtti" \
             -DCMAKE_INSTALL_PREFIX=/scid \
             -DTCL_INCLUDE_PATH=/tcltk/include \
             -DTCL_LIBRARY=/tcltk/lib/libtcl8.6.a \
             -DCMAKE_CXX_STANDARD_LIBRARIES="-lz -ldl" \
             -DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -static-libgcc" \
             scid_code \
    && make -j && make install \
    && mkdir -p /scid/lib \
    && cp /tcltk/lib/*.so /scid/lib/ \
    && cp -r /tcltk/lib/tcl8 /tcltk/lib/tcl8.6 /tcltk/lib/tk8.6 /scid/lib/

