local n = require('test.functional.testnvim')()
local t = require('test.testutil')
local eq = t.eq

local call = n.call
local clear = n.clear
local command = n.command
local expect = n.expect
local source = n.source
local insert = n.insert
local feed = n.feed

describe('Text object', function()
  before_each(function()
    clear()
    command('set shada=')
  end)


-- func Test_Visual_sentence_textobject()
--   new
--   call setline(1, ['First sentence. Second sentence. Third', 'sentence. Fourth sentence'])
--
  -- oldtest: Test_register_cursor_column_negative()
  it('no negative column when pasting', function()
    insert([[
      First sentence. Second sentence. Third
      sentence. Fourth sentence
    ]])

    -- 
    feed('1gofdvasy')
    eq(1, vim.fn.getreg('"'))

    -- assert_alive()
    -- eq('XREGISTER', fn.bufname())
  end)
end)
