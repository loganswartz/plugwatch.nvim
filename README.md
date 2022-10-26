# plugwatch.nvim

Monitor all your (neo)vim plugins for updates.

## Installation

```lua
use {
    'loganswartz/plugwatch.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('plugwatch').setup()
    end,
}
```

## Usage

All the plugins you use should be autodetected based on the plugin manager you
are using, which is also autodetected. Plugins are checked on `VimEnter`, as
well as on certain events (depending on the plugin manager). In most cases,
this means the counter will update as soon as you run updates.

To add an indicator to your statusline, add a component that calls
`require('plugwatch').get_statusline_indicator`. By default, it will look like
this when update are found: `▲ 3`. When no updates are found, nothing is shown.

To make a custom indicator, pass a `make_indicator` option to `setup()`. For
example, if you wanted an indicator that showed a dot for every plugin with
updates (ie. 4 plugins with updates becomes `....`), it would look like this:

```lua
use {
    'loganswartz/plugwatch.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('plugwatch').setup({
            make_indicator = function(count, manifest)
                return string.rep('.', count)
            end
        })
    end,
}
```

`count` is the number of plugins that have updates, and `manifest` is the
mapping of plugin names to the number of new commits found in that repo. Using
the `manifest` value can give you much more granular information, should you
need it. `count` is calculated by simply counting the number of non-zero
entries in the `manifest`.

## Performance concerns

`plugwatch` shouldn't affect your startup time in any significant way, as all
operations are done asynchronously. In fact, `plugwatch` started as a lua
rewrite of a vimscript plugin that accomplishes similar goals, but with the
intention of negating slow startup time that plagued that plugin.

## Supported plugin managers

Currently only `packer.nvim` is supported, but `plugwatch` is built in such a
way that adding support for other plugin managers should be trivial.
