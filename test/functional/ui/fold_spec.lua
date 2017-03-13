local helpers = require('test.functional.helpers')(after_each)
local Screen = require('test.functional.ui.screen')
local clear, feed, eq = helpers.clear, helpers.feed, helpers.eq
local feed_command = helpers.feed_command
local insert = helpers.insert
local meths = helpers.meths

describe("folded lines", function()
  local screen
  before_each(function()
    clear()
    screen = Screen.new(45, 8)
    screen:attach({rgb=true})
    screen:set_default_attr_ids({
      [1] = {bold = true, foreground = Screen.colors.Blue1},
      [2] = {reverse = true},
      [3] = {bold = true, reverse = true},
      [4] = {foreground = Screen.colors.Grey100, background = Screen.colors.Red},
      [5] = {foreground = Screen.colors.DarkBlue, background = Screen.colors.LightGrey},
      [6] = {background = Screen.colors.Yellow},
      [7] = {foreground = Screen.colors.DarkBlue, background = Screen.colors.WebGray},
    })
  end)

  after_each(function()
    screen:detach()
  end)

  it("works with multibyte text", function()
    -- Currently the only allowed value of 'maxcombine'
    eq(6, meths.get_option('maxcombine'))
    eq(true, meths.get_option('arabicshape'))
    insert([[
      å 语 x̨̣̘̫̲͚͎̎͂̀̂͛͛̾͢͟ العَرَبِيَّة
      möre text]])
    screen:expect([[
      å 语 x̎͂̀̂͛͛ ﺎﻠﻋَﺮَﺒِﻳَّﺓ                               |
      möre tex^t                                    |
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
                                                   |
    ]])

    feed('vkzf')
    screen:expect([[
      {5:^+--  2 lines: å 语 x̎͂̀̂͛͛ ﺎﻠﻋَﺮَﺒِﻳَّﺓ·················}|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
                                                   |
    ]])

    feed_command("set noarabicshape")
    screen:expect([[
      {5:^+--  2 lines: å 语 x̎͂̀̂͛͛ العَرَبِيَّة·················}|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
                                                   |
    ]])

    feed_command("set number foldcolumn=2")
    screen:expect([[
      {7:+ }{5:  1 ^+--  2 lines: å 语 x̎͂̀̂͛͛ العَرَبِيَّة···········}|
      {7:  }{1:~                                          }|
      {7:  }{1:~                                          }|
      {7:  }{1:~                                          }|
      {7:  }{1:~                                          }|
      {7:  }{1:~                                          }|
      {7:  }{1:~                                          }|
      :set number foldcolumn=2                     |
    ]])

    -- Note: too much of the folded line gets cut off.This is a vim bug.
    feed_command("set rightleft")
    screen:expect([[
      {5:+--  2 lines: å ······················^·  1 }{7: +}|
      {1:                                          ~}{7:  }|
      {1:                                          ~}{7:  }|
      {1:                                          ~}{7:  }|
      {1:                                          ~}{7:  }|
      {1:                                          ~}{7:  }|
      {1:                                          ~}{7:  }|
      :set rightleft                               |
    ]])

    feed_command("set nonumber foldcolumn=0")
    screen:expect([[
      {5:+--  2 lines: å 语 x̎͂̀̂͛͛ ال·····················^·}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
      :set nonumber foldcolumn=0                   |
    ]])

    feed_command("set arabicshape")
    screen:expect([[
      {5:+--  2 lines: å 语 x̎͂̀̂͛͛ ﺍﻟ·····················^·}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
                                                   |
    ]])

    feed('zo')
    screen:expect([[
                                     ﺔﻴَّﺑِﺮَﻌَ^ﻟﺍ x̎͂̀̂͛͛ 语 å|
                                          txet eröm|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
                                                   |
    ]])

    feed_command('set noarabicshape')
    screen:expect([[
                                     ةيَّبِرَعَ^لا x̎͂̀̂͛͛ 语 å|
                                          txet eröm|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
      {1:                                            ~}|
                                                   |
    ]])

  end)

  it("work in cmdline window", function()
    feed_command("set foldmethod=manual")
    feed_command("let x = 1")
    feed_command("/alpha")
    feed_command("/omega")

    feed("<cr>q:")
    screen:expect([[
                                                   |
      {2:[No Name]                                    }|
      {1::}set foldmethod=manual                       |
      {1::}let x = 1                                   |
      {1::}^                                            |
      {1::~                                           }|
      {3:[Command Line]                               }|
      :                                            |
    ]])

    feed("kzfk")
    screen:expect([[
                                                   |
      {2:[No Name]                                    }|
      {1::}{5:^+--  2 lines: set foldmethod=manual·········}|
      {1::}                                            |
      {1::~                                           }|
      {1::~                                           }|
      {3:[Command Line]                               }|
      :                                            |
    ]])

    feed("<cr>")
    screen:expect([[
      ^                                             |
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      {1:~                                            }|
      :                                            |
    ]])

    feed("/<c-f>")
    screen:expect([[
                                                   |
      {2:[No Name]                                    }|
      {1:/}alpha                                       |
      {1:/}{6:omega}                                       |
      {1:/}^                                            |
      {1:/~                                           }|
      {3:[Command Line]                               }|
      /                                            |
    ]])

    feed("ggzfG")
    screen:expect([[
                                                   |
      {2:[No Name]                                    }|
      {1:/}{5:^+--  3 lines: alpha·························}|
      {1:/~                                           }|
      {1:/~                                           }|
      {1:/~                                           }|
      {3:[Command Line]                               }|
      /                                            |
    ]])

  end)
end)
-- Tests for folding.
local Screen = require('test.functional.ui.screen')

local helpers = require('test.functional.helpers')(after_each)
local feed, insert, execute, expect_any, command =
  helpers.feed, helpers.insert, helpers.execute, helpers.expect_any,
  helpers.command

describe('foldchars', function()
  local screen

  before_each(function()
    helpers.clear()

    screen = Screen.new(20, 11)
    screen:attach()
    screen:set_default_attr_ids({
      [1] = {foreground = Screen.colors.DarkBlue, background = Screen.colors.WebGray},
      [2] = {foreground = Screen.colors.DarkBlue, background = Screen.colors.LightGrey},
      [3] = {bold = true, foreground = Screen.colors.Blue1}
    })
  end)
  after_each(function()
    screen:detach()
  end)

  it('api', function()
    insert([[
      1
      2
      3
      4
      5
      6
      7
      8
      last
      ]])
    execute("set foldcolumn=2")


    -- TODO check
	-- :highlight Folded guibg=grey guifg=blue
	-- :highlight FoldColumn guibg=darkgrey guifg=white
    -- set foldminlines just tells about which folds to close, unrelated to their size :s
    -- test with minimum size of folds 
    command("call nvim_fold_create(nvim_get_current_win(), 1, 4)")
    command("call nvim_fold_create(nvim_get_current_win(), 1, 3)")
    command("call nvim_fold_create(nvim_get_current_win(), 1, 2)")
    command("%foldopen!")
    command("call nvim_fold_create(nvim_get_current_win(), 6, line('$'))")
    command("call nvim_fold_create(nvim_get_current_win(), 7, line('$'))")
    feed("gg")

    local expected = [[
      {1:--}^1                 |
      {1:|^}2                 |
      {1:|^}3                 |
      {1:^ }4                 |
      {1:  }5                 |
      {1:+ }{2:+--  5 lines: 6---}|
      {1:  }{3:~                 }|
      {1:  }{3:~                 }|
      {1:  }{3:~                 }|
      {1:  }{3:~                 }|
      :set foldcolumn=2   |
    ]]
    screen:expect(expected)
      -- 1 => FoldColumn


    command("set fillchars+=foldopen:▾,foldsep:│,foldclose:▸,foldend:^")
    -- screen:snapshot_util()
    -- foldchars = {
    -- 'open': '▾'
    -- '|': '│'
    -- '-': 
    -- }
    screen:expect([[
      {1:▾▾}^1                 |
      {1:│^}2                 |
      {1:│^}3                 |
      {1:^ }4                 |
      {1:  }5                 |
      {1:▸ }{2:+--  5 lines: 6---}|
      {1:  }{3:~                 }|
      {1:  }{3:~                 }|
      {1:  }{3:~                 }|
      {1:  }{3:~                 }|
      :set foldcolumn=2   |
    ]])

  end)

  -- TODO
  -- test single column
  --
  it("set foldminlines", function()
    insert([[
      1
      2
      3
      4
      5
      6
      7
      8
      last
      ]])
      local limit = 4
      local i = 0
      command("set foldminlines="..limit)
      -- TODO echo that one nvim_get_current_win(),

      command("call nvim_fold_create(nvim_get_current_win(), 1, 4)")
      while i < limit + 2 do
        command("")
        local ret = command("echo foldclosed(1)")
        if i < limit then
          assert.is_true()
        else
          assert.is_false()
        end
      end
    screen:try_resize(20, 10)
  end)

  -- TODO test fdc=-1
  --
  -- it("fdc=-1 (adaptive width)", function()
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

  --   helpers.wait()
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

  -- it("foldmethod=syntax", function()
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
  --   expect_any([[
  --     folding 9 ii
  --     3 cc
  --     9 ii
  --     a jj]])
  -- end)

  -- it("foldmethod=expression", function()
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

  --   expect_any([[
  --     expr 2
  --     1
  --     2
  --     0]])
  -- end)

  -- it('can be opened after :move', function()
  --   -- luacheck: ignore
  --   screen:try_resize(35, 8)
  --   insert([[
  --     Test fdm=indent and :move bug END
  --     line2
  --     	Test fdm=indent START
  --     	line3
  --     	line4]])
  --   execute('set noai nosta ')
  --   execute('set fdm=indent')
  --   execute('1m1')
  --   feed('2jzc')
  --   execute('m0')
  --   feed('zR')

  --   expect_any([[
  --     	Test fdm=indent START
  --     	line3
  --     	line4
  --     Test fdm=indent and :move bug END
  --     line2]])
  -- end)
end)
