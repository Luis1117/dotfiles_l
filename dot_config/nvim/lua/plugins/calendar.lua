return {
  "renerocksai/calendar-vim",
  config = function()
    -- Comportamento inicial
    vim.g.calendar_no_mappings = 0 -- Permite atalhos padrão (h,j,k,l, etc)
    vim.g.calendar_monday = 1      -- Começa a semana na segunda-feira
    vim.g.calendar_week_number = 1 -- Mostra o número da semana (útil para cronograma de tese)
    vim.g.calendar_google_calendar = 1
    vim.g.calendar_google_task = 1
    
    -- Definindo atalhos rápidos no Which-key (se você usar)
    vim.keymap.set("n", "<leader>Cl", ":CalendarV<CR>", { desc = "Calendário Vertical" })
    vim.keymap.set("n", "<leader>Ch", ":CalendarH<CR>", { desc = "Calendário Horizontal" })
  end
}
