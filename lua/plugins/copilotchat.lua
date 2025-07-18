--[[
This config is taken from: 
https://github.com/yilengyao/Neo-Vim/blob/34a070846d8a783dcf3171cd6810ec34fa23056c/mac-neovim-config/nvim/lua/plugins/copilotchat.lua
https://github.com/CopilotC-Nvim/CopilotChat.nvim/discussions/27
]]--

-- ~/.config/nvim/lua/plugins/copilotchat.lua
local prompts = {
  -- Code related prompts
  Explain = "Please explain how the following code works.",
  Review = "Please review the following code and provide suggestions for improvement.",
  Tests = "Please explain how the selected code works, then generate unit tests for it.",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following text and provide a solution.",
  BetterNamings = "Please provide better names for the following variables and functions.",
  Documentation = "Please provide documentation for the following code.",
  SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
  -- Text related prompts
  Summarize = "Please summarize the following text.",
  Spelling = "Please correct any grammar and spelling errors in the following text.",
  Wording = "Please improve the grammar and wording of the following text.",
  Concise = "Please rewrite the following text to make it more concise.",
}

return {
  { import = "plugins.copilot" },
  -- { import = "plugins.telescope" },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-telescope/telescope.nvim" }, -- Use telescope for help actions
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      model = "gpt-4",
      question_header = "## User ",
      answer_header = "## Copilot ",
      error_header = "## Error ",
      separator = " ", -- Separator to use in chat
      debug = true,
      prompts = prompts,
      auto_follow_cursor = false,
      show_help = false,
      mappings = {
        -- Tab for completion
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          insert = "<Tab>",
        },
        -- Close the chat
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        -- Clear the chat buffer
        reset = {
          normal = "<C-l>",
          insert = "<C-l>",
        },
        -- Submit the prompt to Copilot
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-CR>",
        },
        -- Accept the diff
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        -- show_diff
        show_diff = {
          normal = "gmd",
        },
        -- Show system prompt
        show_system_prompt = {
          normal = "gmp",
        },
        -- Show user selection
        show_user_selection = {
          normal = "gms",
        },
      },
    },
    config = function(_, opts)
      local copilot_chat = require("CopilotChat")
      local select = require("CopilotChat.select")
      copilot_chat.setup(opts)

      -- Use unnamed register for the selection
      opts.selection = select.unnamed

      -- Override the git prompts message
      opts.prompts.Commit = {
        prompt = "Write commit message for the change with commitizen convention",
        selection = select.gitdiff,
      }
      opts.prompts.CommitStaged = {
        prompt = "Write commit message for the change with commitizen convention",
        selection = function(source)
          return select.gitdiff(source, true)
        end,
      }

      vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
        copilot_chat.ask(args.args, { selection = select.visual })
      end, { nargs = "*", range = true })

      -- Inline chat with Copilot
      vim.api.nvim_create_user_command("CopilotChatInline", function(args)
        copilot_chat.ask(args.args, {
          selection = select.visual,
          window = {
            layout = "float",
            relative = "cursor",
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, { nargs = "*", range = true })

      vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
        copilot_chat.ask(args.args, { selection = select.visual })
      end, { nargs = "*", range = true })

      -- Inline chat with Copilot
      vim.api.nvim_create_user_command("CopilotChatInline", function(args)
        copilot_chat.ask(args.args, {
          selection = select.visual,
          window = {
            layout = "float",
            relative = "cursor",
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, { nargs = "*", range = true })

      -- Restore CopilotChatBuffer
      vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
        copilot_chat.ask(args.args, { selection = select.buffer })
      end, { nargs = "*", range = true })

      -- Custom buffer for CopilotChat
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true

          -- Get current filetype and set it to markdown if the current filetype is copilot-chat
          local ft = vim.bo.filetype
          if ft == "copilot-chat" then
            vim.bo.filetype = "markdown"
          end
        end,
      })

      -- Define the function to prompt the user and run CopilotChat
      local function ask_copilot()
        local input = vim.fn.input("Ask Copilot: ")
        if input ~= "" then
          vim.cmd("CopilotChat " .. input)
        end
      end

      -- Function to get the visual selection range
      local function get_visual_selection_range()
        local start_line, start_col = unpack(vim.fn.getpos("'<"), 2, 3)
        local end_line, end_col = unpack(vim.fn.getpos("'>"), 2, 3)
        return start_line, start_col, end_line, end_col
      end

      -- Function to get the selected text
      local function get_selected_text(start_line, start_col, end_line, end_col)
        local lines = vim.fn.getline(start_line, end_line)
        if #lines == 0 then
          return nil
        end
        lines[1] = string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
        return table.concat(lines, "\n")
      end

      -- Function to prompt the user and run CopilotChat in visual mode
      local function ask_copilot_visual()
        -- Get the visual selection range
        local start_line, start_col, end_line, end_col = get_visual_selection_range()

        -- Get the selected text
        local selection = get_selected_text(start_line, start_col, end_line, end_col)

        -- If no text was selected, return
        if not selection then
          return
        end

        -- Prompt the user for input
        local input = vim.fn.input("Ask Copilot: ", selection)
        if input ~= "" then
          vim.cmd("CopilotChat " .. input)
        end
      end

      -- Create a user command to ask Copilot
      vim.api.nvim_create_user_command("AskCopilot", function()
        ask_copilot()
      end, { desc = "Ask Copilot a question" })

      vim.api.nvim_create_user_command("AskCopilotVisual", function()
        ask_copilot_visual()
      end, { range = true, desc = "Ask Copilot a question with visual selection" })

      -- Custom input for CopilotChat "Space+cci+Enter"
      ---- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>cca<CR>",
        ":AskCopilot<CR>",
        { desc = "CopilotChat - Ask input", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>cca<CR>",
        ":AskCopilotVisual<CR>",
        { desc = "CopilotChat - Ask input with visual selection", noremap = true, silent = true }
      )

      -- Explain code "Space+cce+Enter"
      -- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>cce<cr>",
        "<cmd>CopilotChatExplain<cr>",
        { desc = "CopilotChat - Explain code", noremap = true, silent = true }
      )
      -- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>cce<cr>",
        ":CopilotChatExplain<cr>",
        { desc = "CopilotChat - Explain code", noremap = true, silent = true }
      )

      -- Generate tests "Space+cct+Enter"
      ---- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>cct<cr>",
        "<cmd>CopilotChatTests<cr>",
        { desc = "CopilotChat - Generate tests", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>cct<cr>",
        ":CopilotChatTests<cr>",
        { desc = "CopilotChat - Generate tests", noremap = true, silent = true }
      )

      -- Review code "Space+ccr+Enter"
      ---- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccr<cr>",
        "<cmd>CopilotChatReview<cr>",
        { desc = "CopilotChat - Review code", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccr<cr>",
        ":CopilotChatReview<cr>",
        { desc = "CopilotChat - Review code", noremap = true, silent = true }
      )

      -- Refactor code "Space+ccrf+Enter"
      ---- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccrf<cr>",
        "<cmd>CopilotChatRefactor<cr>",
        { desc = "CopilotChat - Refactor code", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccrf<cr>",
        ":CopilotChatRefactor<cr>",
        { desc = "CopilotChat - Refactor code", noremap = true, silent = true }
      )

      -- Fix code "Space+ccf+Enter"
      ---- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccf<cr>",
        "<cmd>CopilotChatFixCode<cr>",
        { desc = "CopilotChat - Fix code", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccf<cr>",
        ":CopilotChatFixCode<cr>",
        { desc = "CopilotChat - Fix code", noremap = true, silent = true }
      )

      -- Documentation "Space+ccd+Enter"
      ---- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccd<cr>",
        "<cmd>CopilotChatDocumentation<cr>",
        { desc = "CopilotChat - Add documentation for code", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccd<cr>",
        ":CopilotChatDocumentation<cr>",
        { desc = "CopilotChat - Add documentation for code", noremap = true, silent = true }
      )

      -- Better namings "Space+ccsa+Enter"
      ---- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccsa<cr>",
        "<cmd>CopilotChatSwaggerApiDocs<cr>",
        { desc = "CopilotChat - Add Swagger API documentation", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccsa<cr>",
        ":CopilotChatSwaggerApiDocs<cr>",
        { desc = "CopilotChat - Add Swagger API documentation", noremap = true, silent = true }
      )

      -- Better namings "Space+ccsjs+Enter"
      ---- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccsjs<cr>",
        "<cmd>CopilotChatSwaggerJsDocs<cr>",
        { desc = "CopilotChat - Add Swagger API with Js Documentation", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccsjs<cr>",
        ":CopilotChatSwaggerJsDocs<cr>",
        { desc = "CopilotChat - Add Swagger API with Js Documentation", noremap = true, silent = true }
      )

      -- Summarize Text "Space+ccs+Enter"
      ----(normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccs<cr>",
        "<cmd>CopilotChatSummarize<cr>",
        { desc = "CopilotChat - Summarize text", noremap = true, silent = true }
      )
      ----(visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccs<cr>",
        ":CopilotChatSummarize<cr>",
        { desc = "CopilotChat - Summarize text", noremap = true, silent = true }
      )

      -- Correct Spelling "Space+ccsp+Enter"
      ----  (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccsp<cr>",
        "<cmd>CopilotChatSpelling<cr>",
        { desc = "CopilotChat - Correct spelling", noremap = true, silent = true }
      )
      ----  (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccsp<cr>",
        ":CopilotChatSpelling<cr>",
        { desc = "CopilotChat - Correct spelling", noremap = true, silent = true }
      )

      -- Improve Wording "Space+ccw+Enter"
      ----  (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccw<cr>",
        "<cmd>CopilotChatWording<cr>",
        { desc = "CopilotChat - Improve wording", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccw<cr>",
        ":CopilotChatWording<cr>",
        { desc = "CopilotChat - Improve wording", noremap = true, silent = true }
      )

      -- Make text concise "Space+ccc+Enter"
      ---- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccc<cr>",
        "<cmd>CopilotChatConcise<cr>",
        { desc = "CopilotChat - Make text concise", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccc<cr>",
        ":CopilotChatConcise<cr>",
        { desc = "CopilotChat - Make text concise", noremap = true, silent = true }
      )

      -- Opening floating Window to Chat with Copilot "Space+ccv+Enter"
      ---- (normal mode)
      -- vim.api.nvim_set_keymap(
      vim.keymap.set(
        "n",
        "<leader>ccv",
        ":CopilotChatVisual<cr>",
        { desc = "CopilotChat - Open in vertical split", noremap = true, silent = true }
      )
      ---- (visual mode)
      -- vim.api.nvim_set_keymap(
      vim.keymap.set(
        "x",
        "<leader>ccv",
        ":CopilotChatVisual<cr>",
        { desc = "CopilotChat - Open in vertical split", noremap = true, silent = true }
      )

      -- Opening Window to Chat with Copilot "Space+ccx+Enter"
      ---- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccx<cr>",
        ":CopilotChatInline<cr>",
        { desc = "CopilotChat - Run in-place code", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccx<cr>",
        ":CopilotChatInline<cr>",
        { desc = "CopilotChat - Run in-place code", noremap = true, silent = true }
      )

      -- Debug Info "Space+ccdb+Enter"
      ---- (normal mode)
      vim.api.nvim_set_keymap(
        "n",
        "<leader>ccdb<cr>",
        "<cmd>CopilotChatDebugInfo<cr>",
        { desc = "CopilotChat - Debug Info", noremap = true, silent = true }
      )
      ---- (visual mode)
      vim.api.nvim_set_keymap(
        "x",
        "<leader>ccdb<cr>",
        ":CopilotChatDebugInfo<cr>",
        { desc = "CopilotChat - Debug Info", noremap = true, silent = true }
      )
    end,
  },
}
