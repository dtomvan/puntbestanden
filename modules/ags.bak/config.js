import { DateTime } from "./luxon.min.js";
import { NotificationPopups } from "./notificationPopups.js"
import { Powermenu } from "./powermenu.js"

// For "infinite timeouts"
// almost 500 days or 1.36 years in milliseconds
// This is the max value for uint32 for GLib.
const A_REALLY_LONG_TIME = Math.pow(2, 32)-1;

const hyprland = await Service.import("hyprland")
const notifications = await Service.import("notifications")
notifications.popupTimeout = A_REALLY_LONG_TIME;
const mpris = await Service.import("mpris")
const audio = await Service.import("audio")
const battery = await Service.import("battery")
const systemtray = await Service.import("systemtray")

function trim_to_length(len) {
    return (t) => t.length > len ? `${t.substring(0, len)}…` : t
}

const date = Variable("", {
    poll: [1000, () => {
        return DateTime.now()
            .set({millisecond: 0})
            .toISO({includeOffset:false,suppressMilliseconds:true})
    }],
})

const WS = (cmd) => {return () => hyprland.messageAsync(`dispatch workspace ${cmd}`)};
function Workspaces() {
    const activeId = hyprland.active.workspace.bind("id")
    const workspaces = hyprland.bind("workspaces")
        .as(ws => ws
            .filter((x) => x.id > 0 && x.id < 100)
            .toSorted((a, b) => parseInt(a.id)-parseInt(b.id))
            .map(({ id }) => Widget.Button({
                on_clicked: WS(id),
                on_scroll_up: WS("-1"),
                on_scroll_down: WS("+1"),
                child: Widget.Label(`${id}`),
                class_name: activeId.as(i => `${i === id ? "focused" : ""}`),
            })))

    return Widget.Box({
        class_name: "workspaces",
        children: workspaces,
    })
}


function ClientTitle() {
    return Widget.Label({
        class_name: "client-title",
        label: hyprland.active.client.bind("title").as(trim_to_length(40)),
    })
}


function Clock() {
    return Widget.Label({
        class_name: "clock",
        label: date.bind(),
    })
}


// we don't need dunst or any other notification daemon
// because the Notifications module is a notification daemon itself
function Notification() {
    const popups = notifications.bind("popups")
    return Widget.Button({
        on_primary_click: () => notifications.clear(),
        class_name: "bar-notification",
        visible: popups.as(p => p.length > 0),
        child: Widget.Box({children: [
            Widget.Icon({
                icon: "preferences-system-notifications-symbolic",
            }),
            Widget.Label({
                label: popups.as(p => `${p.length}`),
            }),
        ]}),
    })
}

let mprisOldState;
// bodge hell, don't do js at home
function mprisGetPlayerInfo(forceReload = false) {
    if (!forceReload && mpris.players.every(p => p['play-back-status'] != 'Playing') && mprisOldState.label) return {
        busName: mprisOldState.busName,
        label: '󰏤' + mprisOldState.label.substring(1),
    };

    let label = "";
    let busName = "";
    let playing = false;
    for (const player of mpris.players) {
        const { track_artists, track_title, metadata } = player;
        // if (metadata["mpris:trackid"] === "/org/mpris/MediaPlayer2/firefox") continue;
        if (track_title.length < 3) continue;
        if (track_title === 'Unknown title') continue;

        playing = player['play-back-status'] === 'Playing';
        if (label.length > 0 && !playing) continue;

        let icon = playing ? '' : '󰏤';
        label = trim_to_length(50)(`${icon} ${track_artists.join(", ")} - ${track_title}`);
        busName = player['bus-name'];
        if (playing) break;
    }
    let ret = {label, busName};
    mprisOldState = ret;
    return ret;
}

function Media() {
    const meta = Utils.watch(mprisGetPlayerInfo(true), mpris, "player-changed", mprisGetPlayerInfo)
    let label = meta.as(m => m.label);
    // Don't know why I need to bodge, here
    let busName = () => meta.emitter.value.busName;

    const BUS = (func) => {return () => mpris.getPlayer(busName())[func]() };
    return Widget.Button({
        visible: meta.as(m => m.label.length > 0),
        class_name: "media",
        on_primary_click: BUS('playPause'),
        on_secondary_click: () => Utils.execAsync('playerctl -a pause'),
        on_scroll_up: BUS('next'),
        on_scroll_down: BUS('previous'),
        child: Widget.Label({ label }),
    })
}


function Volume() {
    const icons = {
        101: "overamplified",
        67: "high",
        34: "medium",
        1: "low",
        0: "muted",
    }

    function getIcon() {
        const icon = audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find(
            threshold => threshold <= audio.speaker.volume * 100)

        return `audio-volume-${icons[icon]}-symbolic`
    }

    const icon = Widget.Icon({
        icon: Utils.watch(getIcon(), audio.speaker, getIcon),
    })

    const slider = Widget.Slider({
        hexpand: true,
        draw_value: false,
        on_change: ({ value }) => audio.speaker.volume = value,
        setup: self => self.hook(audio.speaker, () => {
            self.value = audio.speaker.volume || 0
        }),
    })

    return Widget.Box({
        class_name: "volume",
        css: "min-width: 180px",
        children: [icon, slider],
    })
}


function SysTray() {
    const items = systemtray.bind("items")
        .as(items => items.map(item => Widget.Button({
            class_name: "systray-btn",
            child: Widget.Icon({ icon: item.bind("icon") }),
            on_primary_click: (_, event) => item.activate(event),
            on_secondary_click: (_, event) => item.openMenu(event),
            tooltip_markup: item.bind("tooltip_markup"),
        })))

    return Widget.Box({
        children: items,
    })
}


// layout of the bar
function Left() {
    return Widget.Box({
        spacing: 8,
        children: [
            Workspaces(),
            ClientTitle(),
        ],
    })
}

function Center() {
    return Widget.Box({
        spacing: 8,
        children: [
            Media(),
            Notification(),
        ],
    })
}

function Right() {
    return Widget.Box({
        hpack: "end",
        spacing: 8,
        children: [
            Volume(),
            // BatteryLabel(),
            Clock(),
            SysTray(),
        ],
    })
}

function Bar(monitor = 0) {
    return Widget.Window({
        name: `bar-${monitor}`, // name has to be unique
        class_name: "bar",
        monitor,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            start_widget: Left(),
            center_widget: Center(),
            end_widget: Right(),
        }),
    })
}

App.config({
    style: App.configDir + "/style.css",
    windows: [
        NotificationPopups(),
        Bar(),
        Powermenu(),
    ],
})
