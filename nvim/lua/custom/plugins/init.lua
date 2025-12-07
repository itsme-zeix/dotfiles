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
          opts.buffer = bufnr
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
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [r]eset hunk' })

        -- Actions (normal mode)
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })

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
            jump = { close = false },
            win = {
              list = {
                keys = {
                  ['S'] = 'edit_split',
                  ['s'] = 'edit_vsplit',
                  ['t'] = { 'tab', mode = { 'n', 'i' } },
                },
              },
            },
          },
        },
      },
      quickfile = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      -- Picker
      {
        '<leader><space>',
        function()
          Snacks.picker.smart()
        end,
        desc = 'Smart Find Files',
      },
      {
        '<leader>,',
        function()
          Snacks.picker.buffers()
        end,
        desc = 'Buffers',
      },
      {
        '<leader>/',
        function()
          Snacks.picker.grep()
        end,
        desc = 'Grep',
      },
      {
        '<leader>:',
        function()
          Snacks.picker.command_history()
        end,
        desc = 'Command History',
      },
      {
        '<leader>sf',
        function()
          Snacks.picker.files()
        end,
        desc = '[S]earch [F]iles',
      },
      {
        '<leader>sg',
        function()
          Snacks.picker.grep()
        end,
        desc = '[S]earch by [G]rep',
      },
      {
        '<leader>sw',
        function()
          Snacks.picker.grep_word()
        end,
        desc = '[S]earch current [W]ord',
      },
      {
        '<leader>sh',
        function()
          Snacks.picker.help()
        end,
        desc = '[S]earch [H]elp',
      },
      {
        '<leader>sk',
        function()
          Snacks.picker.keymaps()
        end,
        desc = '[S]earch [K]eymaps',
      },
      {
        '<leader>sd',
        function()
          Snacks.picker.diagnostics()
        end,
        desc = '[S]earch [D]iagnostics',
      },
      {
        '<leader>sr',
        function()
          Snacks.picker.resume()
        end,
        desc = '[S]earch [R]esume',
      },
      {
        '<leader>s.',
        function()
          Snacks.picker.recent()
        end,
        desc = '[S]earch Recent Files',
      },
      {
        '<leader>sn',
        function()
          Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
        end,
        desc = '[S]earch [N]eovim files',
      },
      {
        '<leader>gc',
        function()
          Snacks.picker.git_log()
        end,
        desc = 'Git Log',
      },
      {
        '<leader>gs',
        function()
          Snacks.picker.git_status()
        end,
        desc = 'Git Status',
      },

      -- Explorer
      {
        '<leader>e',
        function()
          Snacks.explorer()
        end,
        desc = 'File [E]xplorer',
      },

      -- LSP (via snacks picker)
      {
        'grd',
        function()
          Snacks.picker.lsp_definitions()
        end,
        desc = '[G]oto [D]efinition',
      },
      {
        'grr',
        function()
          Snacks.picker.lsp_references()
        end,
        desc = '[G]oto [R]eferences',
      },
      {
        'gri',
        function()
          Snacks.picker.lsp_implementations()
        end,
        desc = '[G]oto [I]mplementation',
      },
      {
        'grt',
        function()
          Snacks.picker.lsp_type_definitions()
        end,
        desc = '[G]oto [T]ype Definition',
      },
      {
        'gO',
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = 'Document Symbols',
      },
      {
        'gW',
        function()
          Snacks.picker.lsp_workspace_symbols()
        end,
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
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Native gr* keymaps for Neovim 0.11+
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Highlight references on cursor hold
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
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
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
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
        gopls = {},
        pyrefly = {},
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

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { 'stylua' })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
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
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
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
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
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

  -- Colorscheme: Kanagawa (primary)
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'kanagawa-dragon'
      vim.cmd.hi 'Comment gui=none'
    end,
  },

  -- Colorscheme: Tokyonight (alternative, uncomment to use)
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
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'css',
        'diff',
        'go',
        'gomod',
        'gosum',
        'html',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'rust',
        'toml',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },

  -- Indent rainbow lines
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = function(_, opts)
      return require('indent-rainbowline').make_opts(opts)
    end,
    dependencies = { 'TheGLander/indent-rainbowline.nvim' },
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup {}
    end,
  },

  -- CopilotChat
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    event = 'VeryLazy',
    dependencies = {
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    build = 'make tiktoken',
    opts = {
      model = 'gpt-5.1',
      window = {
        layout = 'vertical',
        width = 0.5,
        border = 'rounded',
      },
      headers = {
        user = '👤 You',
        assistant = '🤖 Copilot',
        tool = '🔧 Tool',
      },
      separator = '━━',
      auto_fold = true,
    },
    keys = {
      { '<leader>cc', '<cmd>CopilotChatToggle<cr>', desc = 'CopilotChat - Toggle' },
      { '<leader>ce', '<cmd>CopilotChatExplain<cr>', mode = { 'n', 'v' }, desc = 'CopilotChat - Explain' },
      { '<leader>cr', '<cmd>CopilotChatReview<cr>', mode = { 'n', 'v' }, desc = 'CopilotChat - Review' },
      { '<leader>cf', '<cmd>CopilotChatFix<cr>', mode = { 'n', 'v' }, desc = 'CopilotChat - Fix' },
      { '<leader>co', '<cmd>CopilotChatOptimize<cr>', mode = { 'n', 'v' }, desc = 'CopilotChat - Optimize' },
      { '<leader>cd', '<cmd>CopilotChatDocs<cr>', mode = { 'n', 'v' }, desc = 'CopilotChat - Docs' },
      { '<leader>ct', '<cmd>CopilotChatTests<cr>', mode = { 'n', 'v' }, desc = 'CopilotChat - Tests' },
      { '<leader>cm', '<cmd>CopilotChatCommit<cr>', desc = 'CopilotChat - Commit message' },
    },
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
