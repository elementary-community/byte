# Byte
A music player without the library management. Just toss in your music to the playlist from your meticulously managed music folder.

![Byte Screenshot](https://github.com/alainm23/byte/raw/master/data/screenshot/screenshot-01.png)

## Building and Installation

You'll need the following dependencies:
* libgtk-3-dev
* libgee-0.8-dev
* libgstreamer-plugins-base1.0-dev
* libtagc0-dev
* libsqlite3-dev
* libgranite-dev (>=0.5)
* meson
* valac >= 0.40.3

## Building  

```
meson build && cd build
meson configure -Dprefix=/usr
sudo ninja install
com.github.alainm23.byte
```

## Donations
Stripe is not yet available in my country, If you like Planner and you want to support its development, consider donating via [PayPal](https://www.paypal.me/alainm23)

Made with 💗 in Perú
