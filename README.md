# YouTube PiP for Zeron v3

Open a YouTube video in a small player inside Zeron. The player stays open as you switch chats. Drag the grip at the top to move it. Drag the lower-right edge to resize it. The **Load video** and **Change video** buttons switch to icons in the smaller layout. The YouTube player keeps its own playback controls.

## Install the source build

1. Use Zeron v3 desktop with plugin support. This plugin targets the web views in Zeron v0.3.4 on Windows, macOS, and Linux.
2. Download **Source code (zip)** from the [latest release](https://github.com/Master0fFate/zeron-yt-pip/releases/latest). Extract the ZIP and rename the extracted folder to `youtube-pip`. In Zeron, open **Settings → Plugins** and open the plugins folder. Copy `youtube-pip` into it. If version 0.1.0 is already installed, replace its files with the files from this ZIP. `zeron-plugin.json` and `init.luau` go directly inside `youtube-pip`.
3. In **Settings → Plugins**, enable **YouTube PiP** and allow it to add a sidebar page. If Zeron asks for a signature, follow the steps below.
4. Click **YouTube PiP** in the left sidebar, then click **Open player**. Paste a YouTube video link and press **Enter**. Use the pencil button to change the link.

### Sign if Zeron asks

Keep Zeron open. Run the command for your installation, then return to **Settings → Plugins** and enable **YouTube PiP**.

- Windows Command Prompt `start "" /wait "%LOCALAPPDATA%\Programs\Zeron\zeron.exe" plugin sign youtube-pip`
- macOS Terminal `/Applications/Zeron.app/Contents/MacOS/zeron plugin sign youtube-pip`
- Linux terminal `zeron plugin sign youtube-pip`

[Zeron desktop downloads](https://github.com/zeronsh/zeron/releases) · [Zeron plugin guide](https://github.com/zeronsh/zeron/blob/v0.3.4/apps/zgx/docs/plugins.md)

## Playback

The plugin accepts YouTube watch, share, Shorts, live, and embed links. A start time in the link goes to the player. Playback starts when you select Play in the embedded player. YouTube displays its own message for videos that cannot play in an embed.

The plugin uses the desktop web view that comes with Zeron. On Linux this requires WebKitGTK 4.1. YouTube requires a player viewport of at least 200 × 200 pixels, so the player has a minimum size. [YouTube embed documentation](https://developers.google.com/youtube/player_parameters)

## Validation

Luau compilation, supported link formats, start times, embed markup, and compact player geometry were checked. Live YouTube playback and desktop interaction still need verification on Windows, macOS, and Linux.

```sh
luau-compile --null *.luau tests/*.luau
luau tests/youtube.test.luau
```
