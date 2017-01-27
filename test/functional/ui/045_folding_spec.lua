-- Tests for folding.
local Screen = require('test.functional.ui.screen')

local helpers = require('test.functional.helpers')(after_each)
local nvim_feed, feed, insert, clear, execute, expect =
  helpers.nvim_feed, helpers.feed, helpers.insert, helpers.clear, helpers.execute, helpers.expect

local session = helpers

describe('folding', function()
  local screen

  before_each(function()
    session.clear()

    screen = Screen.new(20, 8)
    screen:attach()
  end)
  after_each(function()
    screen:detach()
  end)

  it(" foldcolum with fillchars and enough nesting ", function()
    -- screen:try_resize(20, 10)
    -- r = [[
    --   aa
    --   "{{{
    --   bb
    --   "{{{
    --   cc
    --   dd
    --   "}}}
    --   ee
    --   ff
    --   "}}}
    --   gg
      -- ]]
    r = [[aa
    {
    {
    {
    bb
    }
    cc
    }
    dd
    ee
    {
    ff
    }
    }
    gg]]


    insert(r)
    -- insert([[
    --     dd {{{
    --     ee {{{ }}}
    --     ff }}}
    --     gg
    --   ]])
    execute('set fdm=marker fdl=1 fdc=2 fmr={,}')

    execute('set fillchars+=foldopen:-,foldsep:│,foldmisc:>,foldclose:▸')
    -- execute('2')

    -- todo test with attr
    screen:expect([[
        {0:  }dd {{{            |
        {0:-▸} ee {{{ }}}        |
        {0:│} ff }}}            |
        {0:  }gg             |
    ]], { 
      [0] = {foreground = Screen.colors.DarkBlue, background = Screen.colors.WebGray}, -- foldcolumn
    } ,
    {{bold = true, foreground = Screen.colors.Blue1}}-- ?
    )
  end)
  -- TODO test with wrap that only the first line gets the 
  -- and test when 
  -- it('Test creation, opening, moving to the end and close', function()
  --   insert([[
  --     1 aa
  --     2 bb
  --     3 cc
  --     last
  --     ]])

  --   -- Basic test if a fold can be created, opened, moving to the end and
  --   -- closed.
  --   execute('1')
  --   feed('zf2j')
  --   execute('call append("$", "manual " . getline(foldclosed(".")))')
  --   feed('zo')
  --   execute('call append("$", foldclosed("."))')
  --   feed(']z')
  --   execute('call append("$", getline("."))')
  --   feed('zc')
  --   execute('call append("$", getline(foldclosed(".")))')

  --   expected = screen:snapshot_util({},true)

  --   expect([[
  --     manual 1 aa
  --     -1
  --     3 cc
  --     1 aa]], true)
  -- end)

  -- it("Test folding with markers", function()

  --   screen:try_resize(20, 10)
  --   insert([[
  --     dd {{{
  --     ee {{{ }}}
  --     ff }}}
  --   ]])
  --   execute('set fdm=marker fdl=1')
  --   execute('2')
  --   execute('call append("$", "line 2 foldlevel=" . foldlevel("."))')
  --   feed('[z')
  --   execute('call append("$", foldlevel("."))')
  --   feed('jo{{ <esc>r{jj') -- writes '{{{' and moves 2 lines bot
  --   execute('call append("$", foldlevel("."))')
  --   feed('kYpj')
  --   execute('call append("$", foldlevel("."))')

  --   screen:expect([[
  --       dd {{{            |
  --       ee {{{ }}}        |
  --     {{{                 |
  --       ff }}}            |
  --       ff }}}            |
  --     ^                    |
  --     line 2 foldlevel=2  |
  --     1                   |
  --     1                   |
  --                         |
  --   ]])

  -- end)

  -- it("Test folding with indent.", function()
  --   screen:try_resize(20, 8)
  --   execute('set fdm=indent sw=2')
  --   insert([[
  --   aa
  --     bb
  --       cc
  --   last
  --   ]])
  --   execute('call append("$", "foldlevel line3=" . foldlevel(3))')
  --   execute('call append("$", foldlevel(2))')
  --   feed('zR')

  --   screen:expect([[
  --     aa                  |
  --       bb                |
  --         cc              |
  --     last                |
  --     ^                    |
  --     foldlevel line3=2   |
  --     1                   |
  --                         |
  --   ]])
  -- end)

  -- it("Test syntax folding", function()
  --   screen:try_resize(35, 15)
  --   insert([[
  --     1 aa
  --     2 bb
  --     3 cc
  --     4 dd {{{
  --     5 ee {{{ }}}
  --     6 ff }}}
  --     7 gg
  --     8 hh
  --     9 ii
  --     a jj
  --     b kk
  --     last]])
  --   execute('set fdm=syntax fdl=0')
  --   execute('syn region Hup start="dd" end="ii" fold contains=Fd1,Fd2,Fd3')
  --   execute('syn region Fd1 start="ee" end="ff" fold contained')
  --   execute('syn region Fd2 start="gg" end="hh" fold contained')
  --   execute('syn region Fd3 start="commentstart" end="commentend" fold contained')
  --   feed('Gzk')
  --   execute('call append("$", "folding " . getline("."))')
  --   feed('k')
  --   execute('call append("$", getline("."))')
  --   feed('jAcommentstart  <esc>Acommentend<esc>')
  --   execute('set fdl=1')
  --   feed('3j')
  --   execute('call append("$", getline("."))')
  --   execute('set fdl=0')
  --   feed('zO<C-L>j') -- <C-L> redraws screen
  --   execute('call append("$", getline("."))')
  --   execute('set fdl=0')
  --   screen:expect([[
  --     folding 9 ii                       |
  --     3 cc                               |
  --     9 ii                               |
  --     a jj                               |]], nil,nil,nil, true)
  -- end)

  -- it("Test expression folding.", function()
  --   insert([[
  --     1 aa
  --     2 bb
  --     3 cc
  --     4 dd {{{
  --     5 ee {{{ }}}
  --     6 ff }}}
  --     7 gg
  --     8 hh
  --     9 ii
  --     a jj
  --     b kk
  --     last ]])

  --   execute([[
  --   fun Flvl()
  --    let l = getline(v:lnum)
  --    if l =~ "bb$"
  --      return 2
  --    elseif l =~ "gg$"
  --      return "s1"
  --    elseif l =~ "ii$"
  --      return ">2"
  --    elseif l =~ "kk$"
  --      return "0"
  --    endif
  --    return "="
  --   endfun
  --   ]])
  --   execute('set fdm=expr fde=Flvl()')
  --   execute('/bb$')
  --   execute('call append("$", "expr " . foldlevel("."))')
  --   execute('/hh$')
  --   execute('call append("$", foldlevel("."))')
  --   execute('/ii$')
  --   execute('call append("$", foldlevel("."))')
  --   execute('/kk$')
  --   execute('call append("$", foldlevel("."))')

  --   expect([[
  --     expr 2
  --     1
  --     2
  --     0]], true)
  -- end)

  -- it('can open after fold after :move', function()

  --   screen:try_resize(35, 8)
  --   r = [[
  --     Test fdm=indent and :move bug END
  --     line2
  --     	Test fdm=indent START
  --     	line3
  --     	line4]]
  --   insert(r)
  --   execute('set noai nosta ')
  --   execute('set fdm=indent')
  --   execute('1m1')
  --   feed('2jzc')
  --   execute('m0')
  --   feed('zR')

  --   expect([[
  --     	Test fdm=indent START
  --     	line3
  --     	line4
  --     Test fdm=indent and :move bug END
  --     line2]], true)
  -- end)
end)

