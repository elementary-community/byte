project('com.github.alainm23.byte',
        'vala', 'c',
        version: '0.0.1')

gnome = import('gnome')
i18n = import('i18n')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
  '-include', 'config.h'
]

add_project_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language: 'c')
#add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

asresources = gnome.compile_resources (
    'as-resources', 'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

executable(
    meson.project_name(),
    asresources,
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Utils.vala',

    'src/Services/StreamPlayer.vala',
    'src/Services/Signals.vala',
    'src/Services/Database.vala',
    'src/Services/TagManager.vala',

    'src/Widgets/HeaderBar.vala',
    'src/Widgets/ActionBar.vala',
    'src/Widgets/TrackRow.vala',

    'src/Views/Welcome.vala',
    'src/Views/Main.vala',

    'src/Objects/Track.vala',
    dependencies: [
        dependency('gee-0.8'),
        dependency('gobject-2.0'),
        dependency('glib-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('sqlite3'),
        dependency('libsoup-2.4'),
        dependency('json-glib-1.0'),
        dependency('gstreamer-pbutils-1.0'),
        dependency('gstreamer-tag-1.0'),
        meson.get_compiler('c').find_library('m', required : false)
    ],
    install: true
)

subdir('data')
meson.add_install_script('meson/post_install.py')
