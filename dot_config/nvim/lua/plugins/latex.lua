-- lua/plugins/latex.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- LaTeX: VimTeX + Nabla + Snippets científicos/matemáticos
-- Símbolos isolados (\alpha, \nabla...) via cmp-latex-symbols no cmp.lua
-- nvim-cmp e LuaSnip são gerenciados globalmente em plugins/cmp.lua
-- ─────────────────────────────────────────────────────────────────────────────

local function notify(msg, level, title)
  if package.loaded["snacks"] then
    require("snacks").notify(msg, { title = title or "VimTeX", level = level or "info" })
  else
    vim.notify(msg, level == "error" and vim.log.levels.ERROR or vim.log.levels.INFO)
  end
end

return {
  -- ── 1. VimTeX ─────────────────────────────────────────────────────────────
  {
    "lervag/vimtex",
    lazy = false,
    config = function()

      -- ── Compilação ────────────────────────────────────────────────────────
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        build_dir  = "",
        callback   = 1,
        continuous = 1,
        executable = "latexmk",
        options    = {
          "-lualatex",
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
          "-shell-escape",
        },
      }
      vim.g.vimtex_compiler_latexmk_engines = {
        _        = "-lualatex",
        lualatex = "-lualatex",
      }

      -- ── Visualização PDF (Okular + SyncTeX bidirecional) ──────────────────
      vim.g.vimtex_view_method          = "general"
      vim.g.vimtex_view_general_viewer  = "okular"
      vim.g.vimtex_view_general_options = "--unique file:@pdf#src:@line@tex"

      -- ── Opções gerais ─────────────────────────────────────────────────────
      vim.g.vimtex_syntax_enabled   = 0
      vim.g.vimtex_quickfix_mode    = 0
      vim.g.vimtex_complete_enabled = 1
      vim.g.vimtex_fold_enabled     = 0
      vim.g.tex_conceal             = "abdmg"
      vim.opt.conceallevel          = 2

      -- ── Autocmds ──────────────────────────────────────────────────────────
      local grp = vim.api.nvim_create_augroup("VimTeXCustom", { clear = true })

      vim.api.nvim_create_autocmd("User", {
        group    = grp,
        pattern  = "VimtexEventCompileSuccess",
        callback = function() notify("✅ Compilado com LuaLaTeX!") end,
      })

      vim.api.nvim_create_autocmd("User", {
        group    = grp,
        pattern  = "VimtexEventCompileFailed",
        callback = function() notify("❌ Erro na compilação!", "error") end,
      })

      -- Compilar ao salvar .tex
      vim.api.nvim_create_autocmd("BufWritePost", {
        group    = grp,
        pattern  = "*.tex",
        callback = function() vim.cmd("VimtexCompile") end,
      })

      -- Rodar Biber ao salvar .bib
      vim.api.nvim_create_autocmd("BufWritePost", {
        group    = grp,
        pattern  = "*.bib",
        callback = function()
          for _, tex in ipairs(vim.fn.glob("*.tex", false, true)) do
            os.execute("biber " .. vim.fn.fnamemodify(tex, ":t:r") .. " 2>/dev/null")
          end
          notify("✅ Biber executado!")
          vim.cmd("VimtexCompile")
        end,
      })

      -- ── Keymaps ───────────────────────────────────────────────────────────
      local k = function(lhs, cmd, desc)
        vim.keymap.set("n", lhs, cmd, { noremap = true, desc = desc })
      end

      k("<leader>lv", "<cmd>VimtexView<CR>",       "LaTeX: Forward search (SyncTeX)")
      k("<leader>ll", "<cmd>VimtexView<CR>",       "LaTeX: Abrir PDF")
      k("<leader>lc", "<cmd>VimtexCompile<CR>",    "LaTeX: Compilar")
      k("<leader>ls", "<cmd>VimtexStatus<CR>",     "LaTeX: Status")
      k("<leader>lL", "<cmd>VimtexLog<CR>",        "LaTeX: Ver log")
      k("<leader>lk", "<cmd>VimtexStop<CR>",       "LaTeX: Parar compilação")
      k("<leader>lK", "<cmd>VimtexClean<CR>",      "LaTeX: Limpar auxiliares")
      k("<leader>le", "<cmd>VimtexErrors<CR>",     "LaTeX: Ver erros")
      k("<leader>lT", "<cmd>VimtexTocToggle<CR>",  "LaTeX: Toggle TOC")

      -- Biber manual
      vim.keymap.set("n", "<leader>lb", function()
        local main = vim.b.vimtex and vim.b.vimtex.tex or vim.fn.expand("%:p:r")
        os.execute("biber " .. vim.fn.fnamemodify(main, ":t:r"))
        notify("✅ Biber executado!")
        vim.cmd("VimtexCompile")
      end, { noremap = true, desc = "LaTeX: Rodar Biber" })
    end,
  },

  -- ── 2. Nabla (preview de fórmulas inline) ─────────────────────────────────
  {
    "jbyuki/nabla.nvim",
    ft   = { "tex", "latex", "markdown" },
    keys = {
      { "<leader>lp", function() require("nabla").popup() end,       desc = "LaTeX: Preview fórmula" },
      { "<leader>lt", function() require("nabla").toggle_virt() end, desc = "LaTeX: Toggle virtual text" },
    },
  },

  -- ── 3. Snippets LaTeX (LuaSnip) ───────────────────────────────────────────
  -- Símbolos isolados (\alpha, \nabla, etc.) são inseridos via cmp-latex-symbols
  -- digitando \ + nome no modo insert — sem risco de ativar snippet por engano.
  {
    "L3MON4D3/LuaSnip",
    optional = true,
    opts = function(_, _)
      local ls = require("luasnip")
      local s, t, i = ls.snippet, ls.text_node, ls.insert_node

      ls.add_snippets("tex", {

        -- ════════════════════════════════════════════════════════════════════
        -- ESTRUTURA
        -- ════════════════════════════════════════════════════════════════════

        s("sec", {
          t("\\section{"), i(1, "Título"), t("}"),
          t({ "", "\\label{sec:" }), i(2, "label"), t("}"),
        }),
        s("ssec", {
          t("\\subsection{"), i(1, "Título"), t("}"),
          t({ "", "\\label{subsec:" }), i(2, "label"), t("}"),
        }),
        s("sssec", {
          t("\\subsubsection{"), i(1, "Título"), t("}"),
          t({ "", "\\label{subsubsec:" }), i(2, "label"), t("}"),
        }),

        -- ════════════════════════════════════════════════════════════════════
        -- REFERÊNCIAS
        -- ════════════════════════════════════════════════════════════════════

        s("cite",   { t("\\cite{"),     i(1, "key"),   t("}") }),
        s("citet",  { t("\\citet{"),    i(1, "key"),   t("}") }),
        s("citep",  { t("\\citep{"),    i(1, "key"),   t("}") }),
        s("ref",    { t("\\autoref{"),  i(1, "label"), t("}") }),
        s("eqref",  { t("\\eqref{eq:"), i(1, "label"), t("}") }),

        -- ════════════════════════════════════════════════════════════════════
        -- FIGURAS E TABELAS
        -- ════════════════════════════════════════════════════════════════════

        s("fig", {
          t({ "\\begin{figure}[htbp]", "  \\centering", "  \\includegraphics[width=" }),
          i(1, "0.8"), t("\\textwidth]{"), i(2, "figuras/figura.pdf"), t("}"),
          t({ "", "  \\caption{" }), i(3, "Legenda."), t("}"),
          t({ "", "  \\label{fig:" }), i(4, "label"), t("}"),
          t({ "", "\\end{figure}" }),
        }),

        s("fig2", {
          t({ "\\begin{figure}[htbp]", "  \\centering",
              "  \\begin{subfigure}[b]{0.48\\textwidth}", "    \\centering",
              "    \\includegraphics[width=\\textwidth]{" }),
          i(1, "fig1.pdf"), t("}"),
          t({ "", "    \\caption{" }), i(2, "Legenda (a)."), t("}"),
          t({ "", "    \\label{fig:" }), i(3, "a"), t("}"),
          t({ "", "  \\end{subfigure}", "  \\hfill",
              "  \\begin{subfigure}[b]{0.48\\textwidth}", "    \\centering",
              "    \\includegraphics[width=\\textwidth]{" }),
          i(4, "fig2.pdf"), t("}"),
          t({ "", "    \\caption{" }), i(5, "Legenda (b)."), t("}"),
          t({ "", "    \\label{fig:" }), i(6, "b"), t("}"),
          t({ "", "  \\end{subfigure}",
              "  \\caption{" }), i(7, "Legenda geral."), t("}"),
          t({ "", "  \\label{fig:" }), i(8, "label"), t("}"),
          t({ "", "\\end{figure}" }),
        }),

        s("tab", {
          t({ "\\begin{table}[htbp]", "  \\centering",
              "  \\caption{" }), i(1, "Legenda."), t("}"),
          t({ "", "  \\label{tab:" }), i(2, "label"), t("}"),
          t({ "", "  \\begin{tabular}{" }), i(3, "lcc"), t("}"),
          t({ "", "    \\hline", "    " }), i(4, "Col1 & Col2 & Col3 \\\\"),
          t({ "", "    \\hline", "    " }), i(5, "a & b & c \\\\"),
          t({ "", "    \\hline", "  \\end{tabular}", "\\end{table}" }),
        }),

        s("tabx", {  -- tabela com booktabs
          t({ "\\begin{table}[htbp]", "  \\centering",
              "  \\caption{" }), i(1, "Legenda."), t("}"),
          t({ "", "  \\label{tab:" }), i(2, "label"), t("}"),
          t({ "", "  \\begin{tabular}{" }), i(3, "lcc"), t("}"),
          t({ "", "    \\toprule", "    " }), i(4, "Col1 & Col2 & Col3 \\\\"),
          t({ "", "    \\midrule", "    " }), i(5, "a & b & c \\\\"),
          t({ "", "    \\bottomrule", "  \\end{tabular}", "\\end{table}" }),
        }),

        -- ════════════════════════════════════════════════════════════════════
        -- AMBIENTES MATEMÁTICOS
        -- ════════════════════════════════════════════════════════════════════

        s("eq", {
          t({ "\\begin{equation}", "  " }), i(1, "E = mc^2"),
          t({ "", "  \\label{eq:" }), i(2, "label"), t("}"),
          t({ "", "\\end{equation}" }),
        }),
        s("eqs", {
          t({ "\\begin{equation*}", "  " }), i(1, "E = mc^2"),
          t({ "", "\\end{equation*}" }),
        }),
        s("align", {
          t({ "\\begin{align}", "  " }), i(1, "f(x) &= ax^2 + bx + c \\\\"),
          t({ "", "       &= " }), i(2, "\\ldots"),
          t({ "", "  \\label{eq:" }), i(3, "label"), t("}"),
          t({ "", "\\end{align}" }),
        }),
        s("aligns", {
          t({ "\\begin{align*}", "  " }), i(1, "f(x) &= ax^2 + bx + c \\\\"),
          t({ "", "       &= " }), i(2, "\\ldots"),
          t({ "", "\\end{align*}" }),
        }),
        s("split", {
          t({ "\\begin{equation}", "  \\begin{split}", "    " }),
          i(1, "f(x) &= ax^2 \\\\"),
          t({ "", "         &+ bx + c" }),
          t({ "", "  \\end{split}",
              "  \\label{eq:" }), i(2, "label"), t("}"),
          t({ "", "\\end{equation}" }),
        }),
        s("gather", {
          t({ "\\begin{gather}", "  " }), i(1, "a + b = c \\\\"),
          t({ "", "  " }), i(2, "d + e = f"),
          t({ "", "\\end{gather}" }),
        }),
        s("cases", {
          t("f(x) = \\begin{cases}"),
          t({ "", "  " }), i(1, "x^2  & \\text{se } x \\geq 0 \\\\"),
          t({ "", "  " }), i(2, "-x^2 & \\text{se } x < 0"),
          t({ "", "\\end{cases}" }),
        }),

        -- ════════════════════════════════════════════════════════════════════
        -- OPERADORES MATEMÁTICOS (estruturas, não símbolos isolados)
        -- ════════════════════════════════════════════════════════════════════

        s("frac",  { t("\\frac{"),  i(1, "num"), t("}{"), i(2, "den"), t("}") }),
        s("dfrac", { t("\\dfrac{"), i(1, "num"), t("}{"), i(2, "den"), t("}") }),
        s("sqrt",  { t("\\sqrt{"),  i(1, "x"),   t("}") }),
        s("sqrtn", { t("\\sqrt["),  i(1, "n"),   t("]{"), i(2, "x"), t("}") }),

        -- Integrais
        s("int", {
          t("\\int_{"), i(1, "a"), t("}^{"), i(2, "b"), t("} "),
          i(3, "f(x)"), t(" \\, d"), i(4, "x"),
        }),
        s("iint", {
          t("\\iint_{"), i(1, "D"), t("} "),
          i(2, "f(x,y)"), t(" \\, d"), i(3, "x"), t(" \\, d"), i(4, "y"),
        }),
        s("oint", {
          t("\\oint_{"), i(1, "C"), t("} "),
          i(2, "\\mathbf{F}"), t(" \\cdot d"), i(3, "\\mathbf{r}"),
        }),
        s("intinf", {
          t("\\int_{-\\infty}^{+\\infty} "), i(1, "f(x)"), t(" \\, dx"),
        }),

        -- Somatório e produtório
        s("sum", {
          t("\\sum_{"), i(1, "n=0"), t("}^{"), i(2, "\\infty"), t("} "), i(3, "a_n"),
        }),
        s("prod", {
          t("\\prod_{"), i(1, "n=1"), t("}^{"), i(2, "N"), t("} "), i(3, "a_n"),
        }),

        -- Limites
        s("lim", {
          t("\\lim_{"), i(1, "x \\to"), t(" "), i(2, "\\infty"), t("} "), i(3, "f(x)"),
        }),

        -- Derivadas
        s("ddt", {
          t("\\frac{d"), i(1, "f"), t("}{d"), i(2, "t"), t("}"),
        }),
        s("ddtn", {
          t("\\frac{d^{"), i(1, "n"), t("}"), i(2, "f"),
          t("}{d"), i(3, "t"), t("^{"), i(4, "n"), t("}}"),
        }),
        s("pdd", {
          t("\\frac{\\partial "), i(1, "f"),
          t("}{\\partial "), i(2, "x"), t("}"),
        }),
        s("pddn", {
          t("\\frac{\\partial^{"), i(1, "n"), t("} "), i(2, "f"),
          t("}{\\partial "), i(3, "x"), t("^{"), i(4, "n"), t("}}"),
        }),
        s("pddxy", {
          t("\\frac{\\partial^2 "), i(1, "f"),
          t("}{\\partial "), i(2, "x"), t(" \\partial "), i(3, "y"), t("}"),
        }),

        -- Operadores vetoriais
        s("grad",  { t("\\nabla "),          i(1, "f") }),
        s("divv",  { t("\\nabla \\cdot "),   i(1, "\\mathbf{F}") }),
        s("curl",  { t("\\nabla \\times "),  i(1, "\\mathbf{F}") }),
        s("lapl",  { t("\\nabla^2 "),        i(1, "f") }),

        -- Vetores e matrizes
        s("vec",  { t("\\mathbf{"), i(1, "v"), t("}") }),
        s("mat", {
          t({ "\\begin{pmatrix}", "  " }), i(1, "a & b \\\\"),
          t({ "", "  " }), i(2, "c & d"),
          t({ "", "\\end{pmatrix}" }),
        }),
        s("matb", {
          t({ "\\begin{bmatrix}", "  " }), i(1, "a & b \\\\"),
          t({ "", "  " }), i(2, "c & d"),
          t({ "", "\\end{bmatrix}" }),
        }),
        s("mdet", {
          t({ "\\begin{vmatrix}", "  " }), i(1, "a & b \\\\"),
          t({ "", "  " }), i(2, "c & d"),
          t({ "", "\\end{vmatrix}" }),
        }),

        -- Normas e produtos
        s("norm",  { t("\\left\\| "), i(1, "\\mathbf{v}"), t(" \\right\\|") }),
        s("abs",   { t("\\left| "),   i(1, "x"),            t(" \\right|") }),
        s("inner", { t("\\langle "),  i(1, "u"), t(", "),   i(2, "v"), t(" \\rangle") }),

        -- Parênteses automáticos
        s("paren", { t("\\left( "),   i(1, "expr"), t(" \\right)") }),
        s("brack", { t("\\left[ "),   i(1, "expr"), t(" \\right]") }),
        s("brace", { t("\\left\\{ "), i(1, "expr"), t(" \\right\\}") }),

        -- Notação de Dirac
        s("bra",    { t("\\langle "), i(1, "\\psi"), t(" |") }),
        s("ket",    { t("| "),        i(1, "\\psi"), t(" \\rangle") }),
        s("braket", { t("\\langle "), i(1, "\\phi"), t(" | "), i(2, "\\psi"), t(" \\rangle") }),
        s("expect", { t("\\langle "), i(1, "\\hat{A}"), t(" \\rangle") }),

        -- ════════════════════════════════════════════════════════════════════
        -- TEXTO FORMATADO
        -- ════════════════════════════════════════════════════════════════════

        s("bf",   { t("\\textbf{"),     i(1, "texto"),  t("}") }),
        s("it",   { t("\\textit{"),     i(1, "texto"),  t("}") }),
        s("tt",   { t("\\texttt{"),     i(1, "código"), t("}") }),
        s("ul",   { t("\\underline{"),  i(1, "texto"),  t("}") }),
        s("emph", { t("\\emph{"),       i(1, "texto"),  t("}") }),

        -- ════════════════════════════════════════════════════════════════════
        -- LISTAS
        -- ════════════════════════════════════════════════════════════════════

        s("item", {
          t({ "\\begin{itemize}", "  \\item " }), i(1, "Primeiro"),
          t({ "", "  \\item " }), i(2, "Segundo"),
          t({ "", "  \\item " }), i(3, "Terceiro"),
          t({ "", "\\end{itemize}" }),
        }),
        s("enum", {
          t({ "\\begin{enumerate}", "  \\item " }), i(1, "Primeiro"),
          t({ "", "  \\item " }), i(2, "Segundo"),
          t({ "", "  \\item " }), i(3, "Terceiro"),
          t({ "", "\\end{enumerate}" }),
        }),

        -- ════════════════════════════════════════════════════════════════════
        -- BEAMER
        -- ════════════════════════════════════════════════════════════════════

        s("frame", {
          t("\\begin{frame}{"), i(1, "Título"), t("}"),
          t({ "", "  " }), i(2, "Conteúdo."),
          t({ "", "\\end{frame}" }),
        }),
        s("frames", {
          t("\\begin{frame}{"), i(1, "Título"), t("}{"), i(2, "Subtítulo"), t("}"),
          t({ "", "  " }), i(3, "Conteúdo."),
          t({ "", "\\end{frame}" }),
        }),
        s("cols", {
          t({ "\\begin{columns}", "  \\column{0.5\\textwidth}", "    " }),
          i(1, "Esquerda."),
          t({ "", "  \\column{0.5\\textwidth}", "    " }), i(2, "Direita."),
          t({ "", "\\end{columns}" }),
        }),
        s("colsa", {
          t({ "\\begin{columns}", "  \\column{0.4\\textwidth}", "    " }),
          i(1, "Menor."),
          t({ "", "  \\column{0.6\\textwidth}", "    " }), i(2, "Maior."),
          t({ "", "\\end{columns}" }),
        }),
        s("block", {
          t("\\begin{block}{"), i(1, "Título"), t("}"),
          t({ "", "  " }), i(2, "Conteúdo."),
          t({ "", "\\end{block}" }),
        }),
        s("alert", {
          t("\\begin{alertblock}{"), i(1, "Atenção!"), t("}"),
          t({ "", "  " }), i(2, "Mensagem."),
          t({ "", "\\end{alertblock}" }),
        }),
        s("exblock", {
          t("\\begin{exampleblock}{"), i(1, "Exemplo"), t("}"),
          t({ "", "  " }), i(2, "Conteúdo."),
          t({ "", "\\end{exampleblock}" }),
        }),

        -- Duas figuras Beamer com footnotes
        s("figcols", {
          t({ "\\begin{columns}",
              "  \\column{0.5\\textwidth}", "    \\begin{center}",
              "      \\includegraphics[width=0.9\\textwidth]{" }),
          i(1, "img1.png"), t("}"),
          t({ "", "      \\\\", "      {\\small " }), i(2, "Legenda esq."),
          t("\\footnotemark[1]}"),
          t({ "", "    \\end{center}", "",
              "  \\column{0.5\\textwidth}", "    \\begin{center}",
              "      \\includegraphics[width=0.9\\textwidth]{" }),
          i(3, "img2.png"), t("}"),
          t({ "", "      \\\\", "      {\\small " }), i(4, "Legenda dir."),
          t("\\footnotemark[2]}"),
          t({ "", "    \\end{center}", "\\end{columns}", "",
              "\\footnotetext[1]{\\tiny $^a$ " }),
          i(5, "Autor et al. (2020). DOI: \\href{https://doi.org/}{xxx}"),
          t({ "}", "\\footnotetext[2]{\\tiny $^b$ " }),
          i(6, "Autor et al. (2022). DOI: \\href{https://doi.org/}{xxx}"),
          t("}"),
        }),

        -- Figura única com footnote
        s("figfn", {
          t({ "\\begin{center}", "  \\includegraphics[width=" }),
          i(1, "0.8"), t("\\textwidth]{"), i(2, "figura.png"), t("}"),
          t({ "", "  \\\\", "  {\\small " }), i(3, "Legenda."),
          t("\\footnotemark[1]}"),
          t({ "", "\\end{center}",
              "\\footnotetext[1]{\\tiny " }),
          i(4, "Autor et al. (2020). DOI: \\href{https://doi.org/}{xxx}"),
          t("}"),
        }),

      }) -- fim add_snippets
    end,
  },
}
