return {
  'akinsho/bufferline.nvim',
  enabled = true,
  version = "*",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require("bufferline").setup {
      options = {
        mode = "buffers",
        numbers = "ordinal",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,

        indicator = { icon = '▎', style = 'icon' },
        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',

        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 18,

        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,

        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
            separator = true
          },
          {
            filetype = "aerial",
            text = "Outline",
            text_align = "center",
            separator = true
          },
        },

        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,
        separator_style = "thick",
        enforce_regular_tabs = false,
        always_show_bufferline = true,

        hover = {
          enabled = true,
          delay = 200,
          reveal = { 'close' }
        },

        sort_by = 'insert_after_current',
      },

      highlights = {
        fill = {
          bg = "#11111b",
        },

        background = {
          fg = "#6c7086",
          bg = "#181825",
        },

        buffer_selected = {
          fg = "#cdd6f4",
          bg = "#1e1e2e",
          bold = true,
          italic = false,
        },

        buffer_visible = {
          fg = "#bac2de",
          bg = "#313244",
        },

        numbers = {
          fg = "#6c7086",
          bg = "#181825",
        },
        numbers_selected = {
          fg = "#89b4fa",
          bg = "#1e1e2e",
          bold = true,
        },
        numbers_visible = {
          fg = "#9399b2",
          bg = "#313244",
        },

        modified = {
          fg = "#f9e2af",
          bg = "#181825",
        },
        modified_selected = {
          fg = "#f9e2af",
          bg = "#1e1e2e",
          bold = true,
        },
        modified_visible = {
          fg = "#f9e2af",
          bg = "#313244",
        },

        separator = {
          fg = "#45475a",
          bg = "#181825",
        },
        separator_selected = {
          fg = "#89b4fa",
          bg = "#1e1e2e",
        },
        separator_visible = {
          fg = "#585b70",
          bg = "#313244",
        },

        indicator_selected = {
          fg = "#89b4fa",
          bg = "#1e1e2e",
        },
        indicator_visible = {
          fg = "#585b70",
          bg = "#313244",
        },

        close_button = {
          fg = "#6c7086",
          bg = "#181825",
        },
        close_button_selected = {
          fg = "#f38ba8",
          bg = "#1e1e2e",
        },
        close_button_visible = {
          fg = "#9399b2",
          bg = "#313244",
        },

        duplicate = {
          fg = "#585b70",
          bg = "#181825",
          italic = true,
        },
        duplicate_selected = {
          fg = "#a6adc8",
          bg = "#1e1e2e",
          italic = true,
        },
        duplicate_visible = {
          fg = "#6c7086",
          bg = "#313244",
          italic = true,
        },

        error = {
          fg = "#f38ba8",
          bg = "#181825",
        },
        error_selected = {
          fg = "#f38ba8",
          bg = "#1e1e2e",
          bold = true,
        },
        error_diagnostic = {
          fg = "#f38ba8",
          bg = "#181825",
        },
        error_diagnostic_selected = {
          fg = "#f38ba8",
          bg = "#1e1e2e",
        },

        warning = {
          fg = "#f9e2af",
          bg = "#181825",
        },
        warning_selected = {
          fg = "#f9e2af",
          bg = "#1e1e2e",
          bold = true,
        },
        warning_diagnostic = {
          fg = "#f9e2af",
          bg = "#181825",
        },
        warning_diagnostic_selected = {
          fg = "#f9e2af",
          bg = "#1e1e2e",
        },

        info = {
          fg = "#89dceb",
          bg = "#181825",
        },
        info_selected = {
          fg = "#89dceb",
          bg = "#1e1e2e",
        },
        info_diagnostic = {
          fg = "#89dceb",
          bg = "#181825",
        },
        info_diagnostic_selected = {
          fg = "#89dceb",
          bg = "#1e1e2e",
        },
      },
    }
  end,
}
