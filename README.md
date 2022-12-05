# plugwatch.nvim

Monitor all your (neo)vim plugins for updates.

## About

Plugin managers for (neo)vim are plentiful and full-featured for the most part,
but the one feature I've noticed is missing from all of them is an indicator
that there are updates available for your plugins.

`plugwatch` ties into your plugin manager of choice, and gives you an indicator
you can add your your statusline to show the number of updates available. It
checks for updates on startup, and after your plugin manager installs updates.

Supported plugin managers are:

  * [packer.nvim](https://github.com/wbthomason/packer.nvim)
  * [vim-plug](https://github.com/junegunn/vim-plug)
  * [Vundle.vim](https://github.com/VundleVim/Vundle.vim)\*
  * [dein.vim](https://github.com/Shougo/dein.vim)\*

\*(Untested, but I think they should work. Let me know if it's not working for
you.)

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
this when update are found:

```
▲ 3
```

When no updates are found, nothing is shown.

Then, in your statusline use the indicator function provided by this repo:

```lua
require('plugwatch').get_statusline_indicator
```

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

## API

If you want more manual control, you can also use some global variables that are
automatically updated on the fly:

```lua
-- a key-value table where:
--   key = name of the plugin
--   value = number of new commits detected
vim.g.plugwatch_updates

-- a number representing the total number of plugins that have at least one new
-- commit available
vim.g.plugwatch_updates_count
```

These are also available in Vimscript:

```vim
g:plugwatch_updates
g:plugwatch_updates_count
```

Additionally, the Lua API has some helper functions available:

```lua
-- The contents of vim.g.plugwatch_updates, but any plugins with 0 new commits
-- are filtered out.
require('plugwatch').plugins_with_updates()

-- manually kick off an update check (this is async; returns immediately).
require('plugwatch').check_for_updates()
```

## Performance concerns

`plugwatch` shouldn't affect your startup time in any significant way, as all
operations are done asynchronously. In fact, `plugwatch` started as a lua
rewrite of a vimscript plugin that accomplishes similar goals, but with the
intention of negating slow startup times that plagued that plugin.

The way `plugwatch` checks for updates is by finding the directories for your
plugins via your plugin manager, and doing a `git fetch` to see if there are any
new upstream commits. It does this fetch on startup, and also whenever has been
configured via the `setup_refresh` function for your plugin manager. As far as I
know, you should't need to worry about rate limits from Github or other upstream
repo hosts. The limits are much higher than what this plugin would be able to
do, even under the most extreme cases.

## Is this available for regular Vim?

No, and I have no plans to add support. Lua is much more pleasant to write with
than Vimscript, and I made this specifically for my usage of Neovim +
packer.nvim.

## Known issues

Semi-frequently, jobs will fail for 1 or 2 plugins in each check. I'm not sure
why this is, and it's not consistent at all, in terms of what commands fail, or
what folder it fails on, or even if it happens at all. If you have an idea, let
me know by submitting an issue.
