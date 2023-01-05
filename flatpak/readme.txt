Contributed by Roland Lötscher

This flatpak manifest creates a flatpak for scid.
The engines Stockfish and Lc0 (Leela chess) are bundled as well.
When running the flatpak they are found in the folder /app/engines/stockfish
and /app/engines/lc0, respectively.

Here is how to build the flatpak (c.f. https://docs.flatpak.org/en/latest/first-build.html):
First install flatpak and add the flathub repo as described in https://flatpak.org/setup/
(if you do not use flatpaks yet) and then install the freedesktop runtime (which
contains all the build tools among other things)

    flatpak install flathub org.freedesktop.Platform//22.08 org.freedesktop.Sdk//22.08

This has to be done only once.
Then in order to build the flatpak and create a user installation of it run

    flatpak-builder --user --install --force-clean build-dir com.github.benini.scid.yml

from inside the repository root folder (containing the flatpak manifest).
Here build-dir is the name of a temporary build folder and can be changed if wanted.
This will take a while, but should run without issues.

If everything goes well, you can run the flatpak via

    flatpak run com.github.benini.scid

According to my tests, both engines run fine and using FICS works fine as well.
