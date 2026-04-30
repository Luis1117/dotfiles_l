return {
  "piersolenski/wtf.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  event = "LspAttach",
  config = function()
    require("wtf").setup({
      -- Escolha o provider: "openai" | "anthropic" | "ollama"
      ai_provider = "openai",

      -- Pega a key da variável de ambiente (não coloque a key direto aqui)
      openai_api_key = os.getenv("OPENAI_API_KEY"),

      -- Modelo a usar
      openai_model_id = "gpt-4o",

      -- Língua da explicação
      language = "português",

      -- Busca no Google além de explicar (opcional)
      search_engine = "google",
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>ww", function()
      require("wtf").ai()
    end, { desc = "WTF: explicar diagnóstico com IA" })

    vim.keymap.set("n", "<leader>ws", function()
      require("wtf").search()
    end, { desc = "WTF: buscar diagnóstico no Google" })
  end,
}
