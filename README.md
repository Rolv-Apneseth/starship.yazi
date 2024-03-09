# starship.yazi

Starship prompt plugin for [yazi](https://github.com/sxyazi/yazi)


https://github.com/Rolv-Apneseth/starship.yazi/assets/69486699/f7314687-5cb1-4d66-8d9d-cca960ba6716


## Installation

### Linux / MacOS

```sh
git clone https://github.com/Rolv-Apneseth/starship.yazi.git ~/.config/yazi/plugins/starship.yazi
```

### Windows

```sh
git clone https://github.com/Rolv-Apneseth/starship.yazi.git %AppData%\yazi\config\plugins\starship.yazi
```

## Usage

Add this to `~/.config/yazi/init.lua`:

```toml
require("starship"):setup()
```

Make sure you have [starship](https://github.com/starship/starship) installed and in your `PATH`.

## Acknowlegements

- [sxyazi](https://github.com/sxyazi) for providing the code for this plugin and the demo video [in this comment](https://github.com/sxyazi/yazi/issues/767#issuecomment-1977082834)
