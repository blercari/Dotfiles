import os
import subprocess
from libqtile import hook

from libqtile.config import Key, Screen, Group, Drag, Click
from libqtile.lazy import lazy
from libqtile import layout, bar, widget

from typing import List  # noqa: F401

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])

##############################################################################

# KEYBINDINGS

mod = "mod4"

keys = [
    # Switch between windows in current stack pane
    Key([mod], "k", lazy.layout.down()),
    Key([mod], "j", lazy.layout.up()),

    # Move windows up or down in current stack
    Key([mod, "control"], "k", lazy.layout.shuffle_down()),
    Key([mod, "control"], "j", lazy.layout.shuffle_up()),

    # Switch window focus to other pane(s) of stack
    Key([mod], "space", lazy.layout.next()),

    # Swap panes of split stack
    Key([mod, "shift"], "space", lazy.layout.rotate()),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split()),
    Key([mod], "Return", lazy.spawn("alacritty")),
    Key([mod], "t", lazy.spawn("alacritty")),
    Key([mod], "b", lazy.spawn("firefox")),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout()),
    Key([mod, "shift"], "Tab", lazy.prev_layout()),
    Key([mod], "w", lazy.window.kill()),

    Key([mod, "control"], "r", lazy.restart()),
    Key([mod, "control"], "q", lazy.shutdown()),
    Key([mod], "r", lazy.spawncmd()),
]

##############################################################################

# GROUPS

group_names = ['WEB', 'DEV', 'FILES', 'MUSIC']
groups = [Group(name, layout='monadtall') for name in group_names]

for g in groups:
    keys.extend([
        # Switch to group with 'mod + goup number'
        Key([mod], str(group_names.index(g.name) + 1),
            lazy.group[g.name].toscreen()),

        # Switch to and move focused window to group
        # with 'mod + shift + group number'
        Key([mod, "shift"], str(group_names.index(g.name) + 1),
            lazy.window.togroup(g.name, switch_group=True)),
        # Or, use below if you prefer not to switch to that group
        # # mod1 + shift + letter of group = move focused window to group
        # Key([mod, "shift"], str(group_names.index(g.name) + 1),
        #     lazy.window.togroup(g.name)),
    ])

##############################################################################

# COLORS

colors = {
    # Adapta theme key colors
    'selection': '#00bcd4',
    'accent': '#4db6ac',
    'suggestion': '#009688',
    'destruction': '#ff5252',

    # Material Design colors
    'cyan300': '#4dd0e1',
    'cyan500': '#00bcd4',
    'teal300': '#4db6ac',
    'teal500': '#009688',
    'grey50': '#fafafa',
    'grey100': '#f5f5f5',
    'grey200': '#eeeeee',
    'grey300': '#e0e0e0',
    'grey400': '#bdbdbd',
    'grey500': '#9e9e9e',
    'grey600': '#757575',
    'grey800': '#424242',
    'grey900': '#212121',
    'blueGrey50': '#eceff1',
    'blueGrey100': '#cfd8dc',
    'blueGrey200': '#b0bec5',
    'blueGrey300': '#90a4ae',
    'blueGrey400': '#78909c',
    'blueGrey500': '#607d8b',
    'blueGrey600': '#546e7a',
    'blueGrey700': '#455a64',
    'blueGrey800': '#37474f',
    'blueGrey900': '#263238',
}

##############################################################################

# LAYOUTS

layouts = [
    layout.MonadTall(
        border_focus=colors['teal300'],
        border_normal=colors['grey600'],
        border_width=1,
        margin=8,
        single_border_width=0,
        single_margin=0,
    ),

    layout.Max(),

    # layout.MonadWide(
    #     border_focus=colors['teal300'],
    #     border_normal=colors['grey600'],
    #     border_width=1,
    #     margin=8
    # ),

    layout.Stack(
        border_focus=colors['teal300'],
        border_normal=colors['grey600'],
        border_width=2,
        margin=8,
    ),
]

##############################################################################

# WIDGETS

widget_defaults = dict(
    font='Noto Sans Medium',
    fontsize=12,
    padding=5,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                # widget.CurrentLayout(foreground=colors['blueGrey100']),

                widget.CurrentLayoutIcon(scale=0.75),

                widget.GroupBox(
                    # Active groups (at least one client open) font color
                    active=colors['blueGrey100'],

                    foreground=colors['blueGrey100'],

                    # Current group highlight color, here,
                    # it is set the same as the bar color
                    highlight_color=[colors['blueGrey900'],
                                     colors['blueGrey900']],

                    highlight_method='line',

                    # Inactive groups font color
                    inactive=colors['blueGrey500'],

                    # Text vertical alignment
                    margin=5,

                    padding=0,

                    # Current group in current screen line color
                    this_current_screen_border=colors['cyan500'],
                ),

                widget.Prompt(foreground=colors['blueGrey100']),

                widget.WindowName(
                    font='Noto Sans Bold',
                    foreground=colors['blueGrey200'],
                ),

                widget.Systray(),

                widget.Spacer(2),

                widget.Volume(
                    step=5,
                    update_interval=0.1,
                    foreground=colors['blueGrey100'],
                ),

                widget.KeyboardLayout(
                    configured_keyboards=['us intl', 'us altgr-intl'],
                    foreground=colors['blueGrey100'],
                ),

                widget.Clock(
                    format='%a %d/%m, %H:%M',
                    foreground=colors['blueGrey100'],
                ),

                widget.QuickExit(
                    default_text='⏻',
                    fontsize=16,
                    foreground=colors['blueGrey100'],
                ),
            ],
            size=24,
            background=colors['blueGrey900'],
            opacity=0.95,
        ),
    ),
]

##############################################################################

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        {'wmclass': 'confirm'},
        {'wmclass': 'dialog'},
        {'wmclass': 'download'},
        {'wmclass': 'error'},
        {'wmclass': 'file_progress'},
        {'wmclass': 'notification'},
        {'wmclass': 'splash'},
        {'wmclass': 'toolbar'},
        {'wmclass': 'confirmreset'},  # gitk
        {'wmclass': 'makebranch'},  # gitk
        {'wmclass': 'maketag'},  # gitk
        {'wname': 'branchdialog'},  # gitk
        {'wname': 'pinentry'},  # GPG key password entry
        {'wmclass': 'ssh-askpass'},  # ssh-askpass
    ],
    border_focus=colors['teal300'],
    border_normal=colors['grey600'],
)
auto_fullscreen = True
focus_on_window_activation = "smart"

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
