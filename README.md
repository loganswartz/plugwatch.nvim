# plugwatch.nvim

Monitor all your (neo)vim plugins for updates.

## About

Plugin managers for (neo)vim are plentiful and full-featured for the most part,
but the one feature I've noticed is missing from all of them is an indicator
that there are updates available for your plugins.

`plugwatch` ties into your plugin manager of choice, and gives you an indicator
you can add your your statusline to show the number of updates available. It
checks for updates on startup, and after your plugin manager installs updates.

(All supported plugin managers are listed at the end of this README.)

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

The way `plugwatch` checks for updates is by finding the directories for your
plugins via your plugin manager, and doing a `git fetch` to see if there are any
new upstream commits. It does this fetch on startup, and also whenever has been
configured via the `setup_refresh` function for your plugin manager. As far as I
know, you don't need to worry about rate limits from Github or other upstream
repo hosts.

## Is this available for regular Vim?

No, and I have no plans to add support. Lua is much more pleasant to write with
than Vimscript, and I made this specifically for my usage of Neovim +
packer.nvim.

## Supported plugin managers

  * [packer.nvim](https://github.com/wbthomason/packer.nvim)
  * [vim-plug](https://github.com/junegunn/vim-plug)
  * [Vundle.vim](https://github.com/VundleVim/Vundle.vim)\*
  * [dein.vim](https://github.com/Shougo/dein.vim)\*

\*(Untested, but I think they should work. Let me know if it's not working for
you.)
