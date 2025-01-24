require("plenary.async").tests.add_to_env()
local oil = require("oil")
local test_util = require("tests.test_util")

a.describe("oil select", function()
  after_each(function()
    test_util.reset_editor()
  end)

  a.it("opens file under cursor", function()
    test_util.oil_open()
    -- Go to the bottom, so the cursor is not on a directory
    vim.cmd.normal({ args = { "G" } })
    a.wrap(oil.select, 2)()
    assert.equals(1, #vim.api.nvim_tabpage_list_wins(0))
    assert.not_equals("oil", vim.bo.filetype)
  end)

  a.it("opens file in new tab", function()
    test_util.oil_open()
    local tabpage = vim.api.nvim_get_current_tabpage()
    a.wrap(oil.select, 2)({ tab = true })
    assert.equals(2, #vim.api.nvim_list_tabpages())
    assert.equals(1, #vim.api.nvim_tabpage_list_wins(0))
    assert.not_equals(tabpage, vim.api.nvim_get_current_tabpage())
  end)

  a.it("opens file in new split", function()
    test_util.oil_open()
    local winid = vim.api.nvim_get_current_win()
    a.wrap(oil.select, 2)({ vertical = true })
    assert.equals(1, #vim.api.nvim_list_tabpages())
    assert.equals(2, #vim.api.nvim_tabpage_list_wins(0))
    assert.not_equals(winid, vim.api.nvim_get_current_win())
  end)

  a.it("opens multiple files in new tabs", function()
    test_util.oil_open()
    vim.api.nvim_feedkeys("Vj", "x", true)
    local tabpage = vim.api.nvim_get_current_tabpage()
    a.wrap(oil.select, 2)({ tab = true })
    assert.equals(3, #vim.api.nvim_list_tabpages())
    assert.equals(1, #vim.api.nvim_tabpage_list_wins(0))
    assert.not_equals(tabpage, vim.api.nvim_get_current_tabpage())
  end)

  a.it("opens multiple files in new splits", function()
    test_util.oil_open()
    vim.api.nvim_feedkeys("Vj", "x", true)
    local winid = vim.api.nvim_get_current_win()
    a.wrap(oil.select, 2)({ vertical = true })
    assert.equals(1, #vim.api.nvim_list_tabpages())
    assert.equals(3, #vim.api.nvim_tabpage_list_wins(0))
    assert.not_equals(winid, vim.api.nvim_get_current_win())
  end)

  a.describe("close after open", function()
    a.it("same window", function()
      vim.cmd.edit({ args = { "foo" } })
      local bufnr = vim.api.nvim_get_current_buf()
      test_util.oil_open()
      -- Go to the bottom, so the cursor is not on a directory
      vim.cmd.normal({ args = { "G" } })
      a.wrap(oil.select, 2)({ close = true })
      assert.equals(1, #vim.api.nvim_tabpage_list_wins(0))
      -- This one we actually don't expect the buffer to be the same as the initial buffer, because
      -- we opened a file
      assert.not_equals(bufnr, vim.api.nvim_get_current_buf())
      assert.not_equals("oil", vim.bo.filetype)
    end)

    a.it("split", function()
      vim.cmd.edit({ args = { "foo" } })
      local bufnr = vim.api.nvim_get_current_buf()
      local winid = vim.api.nvim_get_current_win()
      test_util.oil_open()
      a.wrap(oil.select, 2)({ vertical = true, close = true })
      assert.equals(2, #vim.api.nvim_tabpage_list_wins(0))
      assert.equals(bufnr, vim.api.nvim_win_get_buf(winid))
    end)

    a.it("tab", function()
      vim.cmd.edit({ args = { "foo" } })
      local bufnr = vim.api.nvim_get_current_buf()
      local tabpage = vim.api.nvim_get_current_tabpage()
      test_util.oil_open()
      a.wrap(oil.select, 2)({ tab = true, close = true })
      assert.equals(1, #vim.api.nvim_tabpage_list_wins(0))
      assert.equals(2, #vim.api.nvim_list_tabpages())
      vim.api.nvim_set_current_tabpage(tabpage)
      assert.equals(bufnr, vim.api.nvim_get_current_buf())
    end)
  end)
end)
