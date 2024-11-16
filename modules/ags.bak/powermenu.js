import GLib from "gi://GLib"

const ANCHOR_CENTER = ["top", "bottom", "left", "right"]

const clock = Variable(GLib.DateTime.new_now_local(), {
    poll: [1000, () => GLib.DateTime.new_now_local()],
})

function DateTime() {
    return Widget.Box(
        {
            spacing: 4,
            homogeneous: false,
            vertical: true,
            margin: 8,
            vpack: 'center',
            hpack: 'center',
        },
        // icon
        Widget.Label({
            css: `
                font-size: 72pt;
            `,
            label: clock.bind().as(date => date.format("%H:%M"))
        }),
        Widget.Label({
            css: `
                font-size: 48pt;
            `,
            label: clock.bind().as(date => date.format("%x"))
        }),
    )
}

function Background() {
    return Widget.Box({
        class_name: "wallpaper",
        expand: true,
        vpack: "center",
        hpack: "center",
        css: `
            background-color: rgba(50, 50, 50, 0.95);
            background-size: contain;
            background-repeat: no-repeat;
            transition: 200ms;
            min-width: 700px;
            min-height: 350px;
            border-radius: 30px;
            box-shadow: 25px 25px 30px 0 rgba(0,0,0,0.5);`,
    })
}

function PowerButtons(buttons = [
    ['systemctl poweroff', 'system-shutdown', 'color: crimson;'],
    ['systemctl reboot', 'system-reboot-symbolic'],
    ['bash -c "~/.config/hypr/lock.sh"', 'system-log-out-symbolic'],
]) {
    return buttons.map(btn => {
        let [cmd, iconName, extraCss] = btn;
        let icon = Widget.Icon({
            icon: iconName,
            size: 32,
        });
        if (extraCss && typeof(extraCss) == 'string') {
            icon.setCss(extraCss);
        }
        return Widget.Button({
            child: icon,
            css: `background-color: rgba(0,0,0,0);
                  background-image: none;
                  border: none;`,
            onPrimaryClick: () => Utils.execAsync(cmd),
        });
    });
}

function CloseButton(
    windowName = 'pmenu',
    closeFn = () => App.closeWindow(windowName)
) {
    return Widget.Button({
        vpack: 'center',
        hpack: 'center',
        css: `
            padding-bottom: calc(350px - 20px * 4);
            padding-left: calc(700px - 20px * 4);
            background-color: rgba(0,0,0,0);
            background-image: none;
            border: none;
        `,
        child: Widget.Icon({
            icon: 'window-close',
            size: 32,
            css: 'color: crimson;',
        }),
        onPrimaryClick: closeFn,
    });
}

export function Powermenu(name = 'pmenu', monitor = 0) {
    return Widget.Window({
        name,
        monitor,
        keymode: 'exclusive',
        visible: false,
        layer: 'overlay',
        class_name: "power-menu",
        anchor: ANCHOR_CENTER,
        setup: w => {
            w.keybind("Escape", () => App.closeWindow(name));
        },
        child: Widget.Overlay({
            child: Background(),
            overlays: [
				DateTime(),
                CloseButton(name),
                Widget.Box(
                    {
                        css: `padding-top: calc(350px - 32px - 32px);`,
                        vpack: "center",
                        hpack: "center",
                        spacing: 8,
                        vertical: false,
                        children: [...PowerButtons()],
                    },
                )
            ]
        }),
    })
}
