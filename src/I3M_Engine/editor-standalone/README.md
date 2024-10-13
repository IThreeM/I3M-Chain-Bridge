# I3M-Engine-Core (standalone)

**WARNING:** Standalone version of the editor is not supported, use
[project template generator](https://IThreeM.github.io/i3m/beginning/scripting.html) to utilize the full power
of the editor. Standalone version does not support plugins and scripts, it won't be update in next releases!

A standalone version of I3M-Engine-Core - native editor of [IThreeM engine](https://github.com/IThreeM/I3M-Engine-Core). The standalone
version allows you only to create and edit scenes, but **not run your game in the editor**. Please see
[the book](https://IThreeM.github.io/) to learn how to use the editor in different ways.

## How to install and run

To install the latest stable **standalone** version from crates.io use:

```shell
cargo install I3M-Engine-Core
```

After that, you can run the editor by simply calling:

```shell
I3M-Engine-Core
```

If you're on Linux, please make sure that the following dependencies are installed:

```shell
sudo apt install libxcb-shape0-dev libxcb-xfixes0-dev libxcb1-dev libxkbcommon-dev libasound2-dev
```

## Controls

- [Click] - Select
- [W][S][A][D] - Move camera
- [Space][Q]/[E] - Raise/Lower Camera
- [1] - Select interaction mode
- [2] - Move interaction mode
- [3] - Scale interaction mode
- [4] - Rotate interaction mode
- [Ctrl]+[Z] - Undo
- [Ctrl]+[Y] - Redo]()
