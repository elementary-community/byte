# Translating

Anyone may propose translations for Byte. You can do so by editing the relevant `.po` file for your language above. Translation tools (like POEdit) can help automate this process. When your translation is ready, propose it as a pull request against this project and it will be reviewed. If it looks sane and builds correctly, it will be merged in, and your GitHub account will be credited for the translation in the next release's release notes.

## Adding New Languages

If your language does not appear above, you'll need to add it.

1. Add the language code to the `LINGUAS` file
2. Create a `.po` file for your language from the `.pot` file
3. Create a pull request with your translations

Translation tools (like POEdit) can help automate this process, but require you to clone this repository locally.

## Style Guidelines

When translating you may encounter a situation where you have to decide between several ways of saying the same thing. In these situations we refer to the Ubuntu [general translator guide](https://help.launchpad.net/Translations/Guide), and for language specific issues we follow Ubuntu's [team translation guidelines](https://translations.launchpad.net/+groups/ubuntu-translators). Following these guides ensure uniform translations, while also allowing anyone to contribute.
