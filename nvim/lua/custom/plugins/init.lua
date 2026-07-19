-- All plugins consolidated in one file
-- Snacks global is set by snacks.nvim at runtime
---@diagnostic disable: undefined-global

return {

  -- Detect tabstop and shiftwidth automatically
  'NMAC427/guess-indent.nvim',

  -- Git signs in the gutter
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buf = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions (visual mode)
        map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [r]eset hunk' })

        -- Actions (normal mode)
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function() gitsigns.diffthis '@' end, { desc = 'git [D]iff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
      end,
    },
  },

  -- Which-key for pending keybinds
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>c', group = '[C]opilot', mode = { 'n', 'v' } },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- Snacks.nvim - picker, explorer, notifications, and more
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    init = function()
      vim.api.nvim_create_autocmd('WinClosed', {
        group = vim.api.nvim_create_augroup('custom-snacks-explorer-quit', { clear = true }),
        desc = 'Quit Neovim when only Snacks explorer windows remain',
        callback = function()
          vim.schedule(function()
            local snacks = rawget(_G, 'Snacks')
            if not snacks or not snacks.picker then return end
            if #snacks.picker.get { source = 'explorer' } == 0 then return end

            for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
              for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
                local buf = vim.api.nvim_win_get_buf(win)
                if not vim.bo[buf].filetype:match '^snacks_' then return end
              end
            end

            vim.cmd 'confirm quitall'
          end)
        end,
      })
    end,
    opts = {
      bigfile = { enabled = true },
      explorer = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            auto_close = false,
            jump = { close = false, reuse_win = true },
            win = {
              list = {
                keys = {
                  ['S'] = 'edit_split',
                  ['s'] = 'edit_vsplit',
                  ['t'] = { 'tab', mode = { 'n', 'i' } },
                },
              },
            },
            actions = {
              confirm = function(picker, item, action)
                local previous_buf
                if item and not item.dir and not picker.input.filter.meta.searching and picker.main and vim.api.nvim_win_is_valid(picker.main) then
                  previous_buf = vim.api.nvim_win_get_buf(picker.main)
                end

                require('snacks.explorer.actions').actions.confirm(picker, item, action)

                vim.schedule(function()
                  if not previous_buf or not vim.api.nvim_buf_is_valid(previous_buf) then return end
                  if previous_buf == vim.api.nvim_get_current_buf() or #vim.fn.win_findbuf(previous_buf) > 0 then return end
                  if vim.bo[previous_buf].buftype ~= '' or not vim.bo[previous_buf].buflisted then return end
                  Snacks.bufdelete { buf = previous_buf }
                end)
              end,
              explorer_paste = function(picker)
                local Tree = require 'snacks.explorer.tree'
                local files = vim.split(vim.fn.getreg(vim.v.register or '+') or '', '\n', { plain = true })
                files = vim.tbl_filter(function(file) return file ~= '' and (vim.fn.filereadable(file) == 1 or vim.fn.isdirectory(file) == 1) end, files)

                if #files == 0 then return Snacks.notify.warn(('The `%s` register does not contain any files'):format(vim.v.register or '+')) end

                local dir = picker:dir()
                for _, src in ipairs(files) do
                  local name = vim.fn.fnamemodify(src, ':t')
                  local dest = dir .. '/' .. name
                  -- Auto-rename if destination exists
                  local copy_num = 1
                  while vim.fn.filereadable(dest) == 1 or vim.fn.isdirectory(dest) == 1 do
                    local ext = vim.fn.fnamemodify(name, ':e')
                    local base = vim.fn.fnamemodify(name, ':r')
                    if ext ~= '' then
                      dest = dir .. '/' .. base .. ' (copy ' .. copy_num .. ').' .. ext
                    else
                      dest = dir .. '/' .. name .. ' (copy ' .. copy_num .. ')'
                    end
                    copy_num = copy_num + 1
                  end
                  vim.fn.system { 'cp', '-r', src, dest }
                end
                Tree:refresh(dir)
                Tree:open(dir)
              end,
            },
          },
        },
      },
      quickfile = { enabled = false },
      words = { enabled = true },
    },
    keys = {
      -- Picker
      {
        '<leader><space>',
        function() Snacks.picker.smart() end,
        desc = 'Smart Find Files',
      },
      {
        '<leader>,',
        function() Snacks.picker.buffers() end,
        desc = 'Buffers',
      },
      {
        '<leader>/',
        function() Snacks.picker.grep() end,
        desc = 'Grep',
      },
      {
        '<leader>:',
        function() Snacks.picker.command_history() end,
        desc = 'Command History',
      },
      {
        '<leader>sf',
        function() Snacks.picker.files() end,
        desc = '[S]earch [F]iles',
      },
      {
        '<leader>sg',
        function() Snacks.picker.grep() end,
        desc = '[S]earch by [G]rep',
      },
      {
        '<leader>sw',
        function() Snacks.picker.grep_word() end,
        desc = '[S]earch current [W]ord',
      },
      {
        '<leader>sh',
        function() Snacks.picker.help() end,
        desc = '[S]earch [H]elp',
      },
      {
        '<leader>sk',
        function() Snacks.picker.keymaps() end,
        desc = '[S]earch [K]eymaps',
      },
      {
        '<leader>sd',
        function() Snacks.picker.diagnostics() end,
        desc = '[S]earch [D]iagnostics',
      },
      {
        '<leader>sr',
        function() Snacks.picker.resume() end,
        desc = '[S]earch [R]esume',
      },
      {
        '<leader>s.',
        function() Snacks.picker.recent() end,
        desc = '[S]earch Recent Files',
      },
      {
        '<leader>sn',
        function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end,
        desc = '[S]earch [N]eovim files',
      },
      {
        '<leader>gc',
        function() Snacks.picker.git_log() end,
        desc = 'Git Log',
      },
      {
        '<leader>gs',
        function() Snacks.picker.git_status() end,
        desc = 'Git Status',
      },

      -- Explorer
      {
        '<leader>e',
        function() Snacks.explorer() end,
        desc = 'File [E]xplorer',
      },

      -- LSP (via snacks picker)
      {
        'grd',
        function() Snacks.picker.lsp_definitions() end,
        desc = '[G]oto [D]efinition',
      },
      {
        'grr',
        function() Snacks.picker.lsp_references() end,
        desc = '[G]oto [R]eferences',
      },
      {
        'gri',
        function() Snacks.picker.lsp_implementations() end,
        desc = '[G]oto [I]mplementation',
      },
      {
        'grt',
        function() Snacks.picker.lsp_type_definitions() end,
        desc = '[G]oto [T]ype Definition',
      },
      {
        'gO',
        function() Snacks.picker.lsp_symbols() end,
        desc = 'Document Symbols',
      },
      {
        'gW',
        function() Snacks.picker.lsp_workspace_symbols() end,
        desc = 'Workspace Symbols',
      },
    },
  },

  -- LSP: Lua dev setup
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buf = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Native gr* keymaps
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Highlight references on cursor hold
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Inlay hints toggle
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic config
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
        },
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- LSP servers configuration
      local servers = {
        clangd = {},
        gopls = {
          settings = {
            gopls = {
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
        ty = {
          settings = {
            ty = {
              -- ty settings here
            },
          },
        },
        ruff = {},
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = true,
              check = { command = 'clippy' },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
      }

      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      for server_name, server in pairs(servers) do
        vim.lsp.config(server_name, server)
      end

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { 'stylua', 'alejandra' })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_enable = vim.tbl_keys(servers or {}),
      }
    end,
  },

  -- Autoformat
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then return nil end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        nix = { 'alejandra' },
        python = { 'ruff_format' },
      },
    },
  },

  -- Autocompletion with blink.cmp
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    opts = {
      keymap = { preset = 'default' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  -- Colorscheme: Kanagawa Dragon
  -- {
  --   'rebelot/kanagawa.nvim',
  --   priority = 1000,
  --   config = function()
  --     require('kanagawa').setup {
  --       theme = 'dragon',
  --     }
  --
  --     vim.cmd.colorscheme 'kanagawa-dragon'
  --     vim.cmd.hi 'Comment gui=none'
  --   end,
  -- },

  -- Colorscheme: Modified Catppuccin
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha',
        no_italic = true,
        color_overrides = {
          mocha = {
            base = '#212121',
            mantle = '#212121',
            crust = '#212121',
          },
          macchiato = {
            base = '#212121',
            mantle = '#212121',
            crust = '#212121',
          },
        },
        custom_highlights = function()
          return {
            Normal = { bg = '#212121' },
            NormalNC = { bg = '#212121' },
            NormalFloat = { bg = '#212121' },
            FloatBorder = { bg = '#212121' },
            SignColumn = { bg = '#212121' },
            EndOfBuffer = { bg = '#212121' },
          }
        end,
      }

      vim.cmd.colorscheme 'catppuccin'
      vim.cmd.hi 'Comment gui=none'
    end,
  },

  -- Colorscheme: Tokyonight
  -- {
  --   'folke/tokyonight.nvim',
  --   priority = 1000,
  --   config = function()
  --     require('tokyonight').setup {
  --       styles = { comments = { italic = false } },
  --     }
  --     vim.cmd.colorscheme 'tokyonight-night'
  --   end,
  -- },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- Mini.nvim modules
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end
    end,
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local treesitter = require 'nvim-treesitter'
      local disabled = { markdown = true, markdown_inline = true }

      treesitter.setup { install_dir = vim.fn.stdpath('data') .. '/site' }
      local function enable_treesitter(buf)
        if disabled[vim.bo[buf].filetype] then return end
        pcall(vim.treesitter.start, buf)
        if vim.bo[buf].filetype ~= 'ruby' then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('custom-treesitter', { clear = true }),
        callback = function(event) enable_treesitter(event.buf) end,
      })

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= '' then enable_treesitter(buf) end
      end
    end,
  },

  -- Indent rainbow lines
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = function(_, opts)
      opts.indent = opts.indent or {}
      opts.indent.char = '▏'
      return require('indent-rainbowline').make_opts(opts)
    end,
    dependencies = { 'TheGLander/indent-rainbowline.nvim' },
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function() require('nvim-autopairs').setup {} end,
  },

  -- Distant (remote development)
  {
    'chipsenkbeil/distant.nvim',
    branch = 'v0.3',
    config = function()
      local distant = require 'distant'
      ---@diagnostic disable-next-line: missing-parameter
      distant:setup()
    end,
  },
}
