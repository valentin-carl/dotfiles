-----------------------------------------------------------
-- vimtex keymaps (optional helpers)
-----------------------------------------------------------
-- <leader>ll : start compilation
-- <leader>lv : open viewer
-- <leader>lk : stop compilation
-- <leader>lc : clean aux files


-----------------------------------------------------------
-- filetype / syntax
-----------------------------------------------------------

vim.cmd([[
    filetype plugin indent on
    syntax enable
]])


-----------------------------------------------------------
-- basic settings
-----------------------------------------------------------

--vim.opt.clipboard = "unnamedplus"
--vim.opt.encoding = "utf-8"
--vim.opt.fileencoding = "utf-8"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
--vim.opt.softtabstop = 4
vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = 'a'
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.o.signcolumn = "number"


-----------------------------------------------------------
-- lazy.nvim hat irgendwie besondere Bedürfnisse und will 
-- hier schon geladen werden
-----------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
vim.cmd.colorscheme("default") -- lazy setzt sonst manchmal eins, das will ich nicht


-----------------------------------------------------------
-- plugins
-----------------------------------------------------------

require("lazy").setup({

    -- help with shortcuts
    {
        "folke/which-key.nvim",
        event = "VimEnter",
        opts = {
            delay = 0,
            preset = "modern"
        }
    },

    -- VimTeX, kompilieren etc.
    {
        "lervag/vimtex",
        lazy = false,
        init = function()
            -- Required for vimtex to work properly
            vim.g.tex_flavor = "latex"
            -- Use Skim as PDF viewer
            --vim.g.vimtex_view_method = "skim"
            vim.g.vimtex_view_method = "general"
            vim.g.vimtex_view_skim_sync = 1
            vim.g.vimtex_view_skim_activate = 1
            -- Latexmk options
            vim.g.vimtex_compiler_method = "latexmk"
            -- Disable conceal (optional, personal preference)
            vim.g.tex_conceal = "abdmg"
            vim.opt.conceallevel = 0
        end,
    },

    -- klammern, quotation marks, etc. von alleine zumachen
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true, -- if using treesitter
                fast_wrap = {},
            })
        end,
    },

    -- fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-tree/nvim-web-devicons"
        },
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown(),
                    },
                },
            })
            -- telescope extensions
            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "ui-select")
            -- See `:help telescope.builtin`
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>sd", function()
                require("telescope.builtin").diagnostics({ bufnr = 0 })
            end, { desc = "[s]how [d]iagnostics" })
            vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[s]earch [h]elp" })
            vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[s]earch [k]eymaps" })
            vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[s]earch [f]iles" })
            vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[s]earch by [g]rep" })
            vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] find existing buffers" })
            vim.keymap.set("n", "<leader>/", function()
                builtin.live_grep({
                    grep_open_files = true,
                    prompt_title = "live grep in open files",
                })
            end, { desc = "[s]earch [/] in open files" })
        end,
    },

    -- mason => lsp installer
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
        end,
    },

    -- I'm never touching this again
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            -- 1. Setup Mason
            require("mason").setup()

            -- 2. Setup Mason-LSPConfig and ensure servers are installed
            local mason_lspconfig = require("mason-lspconfig")
            mason_lspconfig.setup({
                ensure_installed = {
                    "texlab",
                    "lua_ls",
                    "pyright",
                    "ltex",
                    "gopls",
                },
                automatic_installation = true,
            })

            -- 3. Use the new Neovim 0.11+ LSP config API
            vim.lsp.config(
                "lua_ls",
                {
                    settings = {
                        Lua = {
                            runtime = {
                                version = "LuaJIT",
                            },
                            diagnostics = {
                                globals = {
                                    "vim",
                                    "require",
                                },
                            },
                        },
                    },
                }
            )
        end,
    },

    -- auto completion popups
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-cmdline",
        },
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                    { name = 'path' },
                })
            })
        end
    },

    -- color scheme :) 
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function ()
            require("gruvbox").setup({
                transparent = true,
                italic = {
                    strings = false,
                    emphasis = false,
                    comments = false,
                    operators = false,
                    folds = false,
                }
            })
        end
    },

    -- or maybe some other colors?
    {
        "lucasadelino/conifer.nvim",
        priority = 1000,
        lazy = false,
        config = function ()
            require("conifer").setup({
                transparent = true,
            })
        end,
    },

    -- macht irgendwie highlighting besser oder so?
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        opts = {
            ensure_installed = { "lua", "latex", "go" },
            auto_install = true,
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
        },
    },

    -- automatisch nach updates schauen (trever modus)
    checker = { enabled = true },
})

--vim.cmd.colorscheme("gruvbox")
vim.cmd.colorscheme("conifer")


-----------------------------------------------------------
-- keymaps
-----------------------------------------------------------

vim.keymap.set("n", "<leader>la", ":Lazy<CR>")
vim.keymap.set("n", "<leader>ma", ":Mason<CR>")
vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>", { desc = "Compile LaTeX" })
vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>", { desc = "View PDF" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic popup" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')


-----------------------------------------------------------
-- transparenter Hintergrund
-----------------------------------------------------------

vim.cmd([[
    highlight Normal guibg=NONE ctermbg=NONE
    highlight NormalNC guibg=NONE ctermbg=NONE
    highlight SignColumn guibg=NONE ctermbg=NONE
    highlight VertSplit guibg=NONE ctermbg=NONE
    highlight StatusLine guibg=NONE ctermbg=NONE
    highlight LineNr guibg=NONE ctermbg=NONE
    highlight EndOfBuffer guibg=NONE ctermbg=NONE
]])

