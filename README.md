# Byte
Rediscover your music

Interact with your music and fall in love with your library all over again.
Byte offers a beautiful presentation of your Music Library with loads of powerful features in a minimalistic yet highly customizable UI.

## Handy features:

* Light and Dark themes.
* Add up to 100 items under "Recently Added" for songs.
* Sort individual playlists by album, title, play count or recently added.
* Advanced Media Details and Artist Info.
* Group Playlists, Albums, Artists, Songs, etc.
* Search, add and play your favorite online radio stations.

<p align="center">
  <a href="https://appcenter.elementary.io/com.github.alainm23.byte">
    <img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter">
  </a>
  <a href="https://flathub.org/apps/details/com.github.alainm23.byte"><img height="50" alt="Download on Flathub" src="https://flathub.org/assets/badges/flathub-badge-en.png"/></a>
</p>

![Byte Screenshot](https://github.com/alainm23/byte/raw/master/data/screenshot/screenshot-01.png)

## Building and Installation

You'll need the following dependencies:
* libgtk-3-dev
* libgee-0.8-dev
* libgstreamer-plugins-base1.0-dev
* libtagc0-dev
* libsqlite3-dev
* libsoup2.4-dev
* libgranite-dev (>=0.5)
* meson
* valac >= 0.40.3

## Building  

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.alainm23.byte`

    sudo ninja install
    com.github.alainm23.byte

## Support
If you like Byte and you want to support its development,consider supporting via [Patreon](https://www.patreon.com/alainm23) or [PayPal](https://www.paypal.me/alainm23)

Made with 💗 in Perú
