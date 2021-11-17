sources  = files(
    'Application.vala',
    'MainWindow.vala',
    
    'Widgets/HeaderBar.vala',
    'Widgets/Playback.vala',
    'Widgets/SectionHeader.vala',
    'Widgets/ArtistChild.vala',
    'Widgets/TrackChild.vala',
    'Widgets/PlaylistChild.vala',
    'Widgets/AlbumImage.vala',
    'Widgets/SecionHeaderAction.vala',
    'Widgets/BackButton.vala',
    
    'Views/Welcome.vala',
    'Views/Main.vala',
    'Views/Tracks.vala',
    
    'Services/Database.vala',
    'Services/Library.vala',
    'Services/Playback.vala',
    
    'Objects/TracksContainer.vala',
    'Objects/Track.vala',
    'Objects/Album.vala',
    'Objects/Artist.vala'
)

executable(
    meson.project_name(),
    as_resources,
    sources,
    config_header,
    dependencies: [
        dependency('granite', version: '>=6.0.0'),
        dependency('gstreamer-1.0'),
        dependency('gstreamer-tag-1.0'),
        dependency('gstreamer-pbutils-1.0'),
        dependency('gtk+-3.0'),
        dependency('sqlite3'),
        dependency('libhandy-1', version: '>=1.0.0'),
        meson.get_compiler('c').find_library('m', required : false)
    ],
    install: true
)