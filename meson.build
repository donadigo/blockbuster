project ('com.github.donadigo.blockbuster', ['vala', 'c'])

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')
add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                    language: 'vala')

i18n = import('i18n')
gnome = import('gnome')

conf = configuration_data()
conf.set('GETTEXT_PACKAGE', meson.project_name())

css_resources = gnome.compile_resources(
    'css-resources', 'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

c_args = [
    '-DWNCK_I_KNOW_THIS_IS_UNSTABLE'
]

posix_dep = meson.get_compiler('vala').find_library('posix')

plugin_deps = [
    dependency ('granite'),
    dependency ('clutter-1.0'),
    dependency ('gala'),
    dependency ('libbamf3'),
    dependency ('libwnck-3.0')
]

exec_deps = [
    dependency ('granite'),
    posix_dep
]

subdir ('data')
subdir ('po')

plugin_path = join_paths (get_option('libdir'), 'gala', 'plugins')
plugin = shared_library ('blockbuster',
                    'plugin/Main.vala',
                    'plugin/Utils.vala',
                    'plugin/WindowMovementTracker.vala',
                    'plugin/Interfaces.vala',
                    'common/AppConfig.vala',
                    'common/PluginSettings.vala',
                    c_args: c_args,
                    dependencies: plugin_deps,
                    install: true,
                    install_dir: plugin_path)

conf.set('PLUGIN_PATH', join_paths (plugin_path, 'libblockbuster.so'))

config_file = configure_file(
    input: 'src/config.vala.in',
    output: 'config.vala',
    configuration: conf
)

app = executable (meson.project_name (),
                'src/Application.vala',
                'src/MainWindow.vala',
                'src/WorkspaceButton.vala',
                'src/WorkspaceBox.vala',
                'src/ConfigurationView.vala',
                'src/WorkspaceView.vala',
                'src/IconContainer.vala',
                'src/AppChooser.vala',
                'src/AppChooserRow.vala',
                'src/AppRow.vala',
                'common/AppConfig.vala',
                'common/PluginSettings.vala',
                config_file,
                css_resources,
                dependencies: exec_deps,
                install: true)

meson.add_install_script('meson/post_install.py')

