install_data(
    meson.project_name() + '.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

icon_sizes = ['24', '48']
foreach i : icon_sizes
    install_data(
        join_paths('icons', i, 'preferences-desktop-add.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'actions')
    )
endforeach

# icons_resources = gnome.compile_resources(
#     'icons-gresource',
#     'icons/icons.gresource.xml',
#     source_dir: 'icons'
# )