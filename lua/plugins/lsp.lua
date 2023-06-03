-- LSP stuff
--

return {
{
    "neovim/nvim-lspconfig",
    dependencies = {
        {"williamboman/mason-lspconfig.nvim"},
        {"williamboman/mason.nvim"},
        {"hrsh7th/nvim-cmp",
            dependencies = {
                "L3MON4D3/LuaSnip",
                "saadparwaiz1/cmp_luasnip",
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-cmdline"
            }
        }
    },
    opts = {
        -- Automatically format on save
        autoformat = true,
        -- options for vim.lsp.buf.format
        -- `bufnr` and `filter` is handled by the LazyVim formatter,
        -- but can be also overridden when specified
        format = {
            formatting_options = nil,
            timeout_ms = nil
        },
        -- LSP Server Settings
        ---@type lspconfig.options
        servers = {
            jsonls = {},
            dockerls = {},
            bashls = {},
            gopls = {},
            pyright = {},
            vimls = {},
            yamlls = {}
        },
        -- you can do any additional lsp server setup here
        -- return true if you don"t want this server to be setup with lspconfig
        ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
        setup = {
            -- example to setup with typescript.nvim
            -- tsserver = function(_, opts)
            --   require("typescript").setup({ server = opts })
            --   return true
            -- end,
            -- Specify * to use this function as a fallback for any server
            -- ["*"] = function(server, opts) end,
        }
    },
        config = function(_, opts)
            local servers = opts.servers
            local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

            local on_attach = function(client, bufnr)
                -- Mappings.
                local bufopts = { noremap=true, silent=true, buffer=bufnr }
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            end

            local function setup(server)
                local server_opts = vim.tbl_deep_extend("force", {
                    on_attach = on_attach,
                    capabilities = vim.deepcopy(capabilities)
                }, servers[server] or {})

                if opts.setup[server] then
                    if opts.setup[server](server, server_opts) then
                        return
                    end
                elseif opts.setup["*"] then
                    if opts.setup["*"](server, server_opts) then
                        return
                    end
                end
                require("lspconfig")[server].setup(server_opts)
            end

            -- temp fix for lspconfig rename
            -- https://github.com/neovim/nvim-lspconfig/pull/2439
            local mappings = require("mason-lspconfig.mappings.server")
            if not mappings.lspconfig_to_package.lua_ls then
                mappings.lspconfig_to_package.lua_ls = "lua-language-server"
                mappings.package_to_lspconfig["lua-language-server"] = "lua_ls"
            end

            local mlsp = require("mason-lspconfig")
            local available = mlsp.get_available_servers()

            local ensure_installed = {} ---@type string[]
            for server, server_opts in pairs(servers) do
                if server_opts then
                    server_opts = server_opts == true and {} or server_opts
                    -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
                    if server_opts.mason == false or not vim.tbl_contains(available, server) then
                        setup(server)
                    else
                        ensure_installed[#ensure_installed + 1] = server
                    end
                end
            end

            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = ensure_installed,
                automatic_installation = true
            })
            require("mason-lspconfig").setup_handlers({setup})


            -- LuaSnip setup
            local luasnip = require "luasnip"

            -- nvim-cmp setup
            local cmp = require "cmp"
            print("running cmp")
            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                mapping = {
                    ["<Down>"] = {i = cmp.mapping.select_next_item()},
                    ["<C-n>"]  = {i = cmp.mapping.select_next_item()},
                    ["<Up>"]   = {i = cmp.mapping.select_prev_item()},
                    ["<C-p>"]  = {i = cmp.mapping.select_prev_item()},

                    -- Scroll docs
                    ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
                    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),

                    -- Cancel completion
                    ["<C-c>"] = cmp.mapping({
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    }),

                    -- Choose autocomplete
                    ['<CR>'] = cmp.mapping.confirm({select = false}),

                },
                sources = {
                    {name = "nvim_lsp"},
                    {name = "path"},
                    {name = "luasnip"},
                    {name = "buffer",
                        option = {
                            -- Avoid accidentally running on big files
                            get_bufnrs = function()
                                local buf = vim.api.nvim_get_current_buf()
                                local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
                                if byte_size > 1024 * 1024 then -- 1 Megabyte max
                                    return {}
                                end
                                return {buf}
                            end
                        }
                    }
                }
            }
        end
    },
}
