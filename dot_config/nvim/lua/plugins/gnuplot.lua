-- lua/plugins/gnuplot.lua
-- ─────────────────────────────────────────────────────────────────────────────
-- NOTA: os autocmds globais (autoread, FocusGained, FileChangedShellPost)
-- foram movidos para lua/core/autocmds.lua onde pertencem.
-- ─────────────────────────────────────────────────────────────────────────────

return {

  -- ── 1. Treesitter: sintaxe Gnuplot ──────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "gnuplot" })
      end
    end,
  },

  -- ── 2. Detecção de filetype + keymaps ───────────────────────────────────────
  -- Usando "lazy.nvim" como plugin fictício (event-driven, sem dependência externa)
  {
    "nvim-lua/plenary.nvim",  -- já é dependência comum; apenas aproveitamos o hook
    lazy = true,
    init = function()

      -- ── Detecção de extensões ────────────────────────────────────────────────
      vim.filetype.add({
        extension = {
          gp      = "gnuplot",
          gnuplot = "gnuplot",
          gnu     = "gnuplot",
          plt     = "gnuplot",
        },
      })

      -- ── Helpers locais ───────────────────────────────────────────────────────
      local function open_file(path)
        vim.fn.system("xdg-open " .. vim.fn.shellescape(path) .. " &")
      end

      local function find_output(lines)
        for _, line in ipairs(lines) do
          local match = line:match("set%s+output%s+['\"]([^'\"]+)['\"]")
          if match then return match end
        end
      end

      local function has_terminal(lines)
        for _, line in ipairs(lines) do
          if line:match("^%s*set%s+terminal") then return true end
        end
        return false
      end

      local function run_gnuplot(file)
        local out = vim.fn.system("gnuplot " .. vim.fn.shellescape(file) .. " 2>&1")
        return vim.v.shell_error == 0, out
      end

      -- ── FileType autocmd ─────────────────────────────────────────────────────
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("GnuplotConfig", { clear = true }),
        pattern = "gnuplot",
        callback = function(ev)
          local buf  = ev.buf
          local bopts = { buffer = buf, silent = true }

          -- Indentação
          vim.bo[buf].expandtab     = true
          vim.bo[buf].shiftwidth    = 4
          vim.bo[buf].tabstop       = 4
          vim.bo[buf].softtabstop   = 4
          vim.bo[buf].commentstring = "# %s"

          -- ── <leader>rr  Executar arquivo inteiro ────────────────────────────
          vim.keymap.set("n", "<leader>rr", function()
            vim.cmd("w")
            local file = vim.fn.expand("%:p")
            local ok, result = run_gnuplot(file)

            if ok then
              vim.notify("✓ Gnuplot executado!", vim.log.levels.INFO)
              vim.cmd("checktime")
              local png = vim.fn.expand("%:r") .. ".png"
              if vim.fn.filereadable(png) == 1 then open_file(png) end
            else
              vim.notify("✗ Erro:\n" .. result, vim.log.levels.ERROR)
            end
          end, vim.tbl_extend("force", bopts, { desc = "Gnuplot: Executar arquivo" }))

          -- ── <leader>rp  Preview rápido ───────────────────────────────────────
          vim.keymap.set("n", "<leader>rp", function()
            vim.cmd("w")
            local file  = vim.fn.expand("%:p")
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            if has_terminal(lines) then
              local ok, result = run_gnuplot(file)
              if ok then
                vim.notify("✓ Plot gerado!", vim.log.levels.INFO)
                vim.cmd("checktime")
                local out = find_output(lines)
                if out and vim.fn.filereadable(out) == 1 then
                  open_file(out)
                  vim.notify("📊 Abrindo: " .. out, vim.log.levels.INFO)
                end
              else
                vim.notify("✗ Erro:\n" .. result, vim.log.levels.ERROR)
              end
            else
              -- Sem terminal declarado → PNG temporário
              local tmp_png    = vim.fn.tempname() .. ".png"
              local tmp_script = vim.fn.tempname() .. ".gp"
              local f = io.open(tmp_script, "w")
              if not f then return end

              f:write("set terminal pngcairo enhanced font 'Arial,12' size 800,600\n")
              f:write("set output '" .. tmp_png .. "'\n")
              f:write(table.concat(lines, "\n"))
              f:close()

              run_gnuplot(tmp_script)
              vim.fn.delete(tmp_script)

              if vim.fn.filereadable(tmp_png) == 1 then
                open_file(tmp_png)
                vim.notify("📊 Preview: " .. tmp_png, vim.log.levels.INFO)
              else
                vim.notify("✗ Erro ao gerar preview", vim.log.levels.ERROR)
              end
            end
          end, vim.tbl_extend("force", bopts, { desc = "Gnuplot: Preview" }))

          -- ── <leader>ro  Abrir último output ─────────────────────────────────
          vim.keymap.set("n", "<leader>ro", function()
            local base = vim.fn.expand("%:r")
            for _, ext in ipairs({ ".pdf", ".png", ".svg", ".eps" }) do
              local out = base .. ext
              if vim.fn.filereadable(out) == 1 then
                open_file(out)
                vim.notify("📊 Abrindo: " .. vim.fn.fnamemodify(out, ":t"), vim.log.levels.INFO)
                return
              end
            end
            vim.notify("✗ Nenhum arquivo de saída encontrado", vim.log.levels.WARN)
          end, vim.tbl_extend("force", bopts, { desc = "Gnuplot: Abrir output" }))

          -- ── <leader>rs  Executar seleção visual ─────────────────────────────
          vim.keymap.set("v", "<leader>rs", function()
            local s_line = vim.fn.line("'<")
            local e_line = vim.fn.line("'>")
            local lines  = vim.api.nvim_buf_get_lines(0, s_line - 1, e_line, false)
            local tmp    = vim.fn.tempname() .. ".gp"
            local f = io.open(tmp, "w")
            if not f then return end

            f:write(table.concat(lines, "\n"))
            f:close()

            local ok, result = run_gnuplot(tmp)
            vim.fn.delete(tmp)

            if ok then
              vim.notify("✓ Seleção executada!", vim.log.levels.INFO)
            else
              vim.notify("✗ Erro:\n" .. result, vim.log.levels.ERROR)
            end
          end, vim.tbl_extend("force", bopts, { desc = "Gnuplot: Executar seleção" }))

          -- ── <leader>ri  REPL interativo ──────────────────────────────────────
          vim.keymap.set("n", "<leader>ri", function()
            vim.cmd("terminal gnuplot")
          end, vim.tbl_extend("force", bopts, { desc = "Gnuplot: REPL interativo" }))

          -- ── <leader>rh  Help sobre palavra sob cursor ────────────────────────
          vim.keymap.set("n", "<leader>rh", function()
            local word = vim.fn.expand("<cword>")
            vim.cmd("terminal gnuplot -e 'help " .. word .. "'")
          end, vim.tbl_extend("force", bopts, { desc = "Gnuplot: Help" }))

          -- ── <leader>rc  Checar sintaxe ───────────────────────────────────────
          vim.keymap.set("n", "<leader>rc", function()
            vim.cmd("w")
            local file   = vim.fn.expand("%:p")
            local ok, result = run_gnuplot(
              vim.fn.shellescape(file):gsub("^'", ""):gsub("'$", "")
            )
            -- roda com terminal dumb para não gerar arquivo
            local raw = vim.fn.system(
              "gnuplot -e \"set terminal dumb\" " .. vim.fn.shellescape(file) .. " 2>&1"
            )
            if vim.v.shell_error == 0 then
              vim.notify("✓ Sintaxe OK", vim.log.levels.INFO)
            else
              vim.notify("✗ Sintaxe:\n" .. raw, vim.log.levels.ERROR)
            end
          end, vim.tbl_extend("force", bopts, { desc = "Gnuplot: Checar sintaxe" }))

          -- ── <leader>rd  Preview ASCII (sem app externo) ──────────────────────
          vim.keymap.set("n", "<leader>rd", function()
            local lines      = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local tmp_script = vim.fn.tempname() .. ".gp"
            local f = io.open(tmp_script, "w")
            if not f then return end

            f:write("set terminal dumb size 100,30\n")
            for _, line in ipairs(lines) do
              if not line:match("^%s*set%s+terminal") and not line:match("^%s*set%s+output") then
                f:write(line .. "\n")
              end
            end
            f:close()

            local result = vim.fn.system("gnuplot " .. vim.fn.shellescape(tmp_script) .. " 2>&1")
            vim.fn.delete(tmp_script)

            -- Abre num split temporário (fechar com q)
            vim.cmd("botright 15new")
            vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result, "\n"))
            vim.bo.buftype   = "nofile"
            vim.bo.bufhidden = "wipe"
            vim.bo.filetype  = "text"
            vim.keymap.set("n", "q", "<cmd>bd!<cr>", { buffer = true, silent = true })
          end, vim.tbl_extend("force", bopts, { desc = "Gnuplot: Preview ASCII" }))

        end, -- fim callback
      })
    end, -- fim init
  },

  -- ── 3. Snippets (LuaSnip) ───────────────────────────────────────────────────
  {
    "L3MON4D3/LuaSnip",
    optional = true,
    opts = function(_, _)
      local ls = require("luasnip")
      local s  = ls.snippet
      local t  = ls.text_node
      local i  = ls.insert_node

      ls.add_snippets("gnuplot", {

        -- ── Terminais ─────────────────────────────────────────────────────────
        s("png", {
          t({ "set terminal pngcairo enhanced font 'Arial,12' size 800,600",
              "set output '" }), i(1, "output.png"), t("'"),
        }),
        s("pdf", {
          t({ "set terminal pdfcairo enhanced font 'Arial,12' size 6in,4in",
              "set output '" }), i(1, "output.pdf"), t("'"),
        }),
        s("svg", {
          t({ "set terminal svg enhanced font 'Arial,12' size 800,600",
              "set output '" }), i(1, "output.svg"), t("'"),
        }),
        s("eps", {
          t({ "set terminal epscairo enhanced font 'Arial,12' size 6in,4in",
              "set output '" }), i(1, "output.eps"), t("'"),
        }),
        -- Gera PDF + .tex com fontes do LaTeX (ideal para artigos)
        s("tex", {
          t({ "set terminal cairolatex pdf colortext size 12cm,8cm",
              "set output '" }), i(1, "output.tex"), t("'"),
        }),

        -- ── Plots ─────────────────────────────────────────────────────────────
        s("plot", {
          t("plot '"), i(1, "data.dat"), t("' using "), i(2, "1:2"),
          t(" with "), i(3, "lines"), t(" lw "), i(4, "2"),
          t(" lc '"), i(5, "#0072BD"), t("' title '"), i(6, "label"), t("'"),
        }),
        s("plotf", {   -- função matemática
          t("plot "), i(1, "sin(x)"), t(" lw "), i(2, "2"),
          t(" lc '"), i(3, "#0072BD"), t("' title '"), i(4, "f(x)"), t("'"),
        }),
        s("plote", {   -- yerrorbars
          t("plot '"), i(1, "data.dat"), t("' using 1:2:3 with yerrorbars lw "),
          i(2, "2"), t(" title '"), i(3, "label"), t("'"),
        }),
        s("plotxy", {  -- xyerrorbars
          t("plot '"), i(1, "data.dat"), t("' using 1:2:3:4 with xyerrorbars lw "),
          i(2, "2"), t(" title '"), i(3, "label"), t("'"),
        }),
        s("plotm", {   -- múltiplos arquivos
          t("plot '"), i(1, "data1.dat"), t("' u 1:2 w lines title '"), i(2, "a"), t("', \\"),
          t({ "", "     '" }), i(3, "data2.dat"), t("' u 1:2 w lines title '"), i(4, "b"), t("'"),
        }),
        s("plotlp", {  -- linespoints
          t("plot '"), i(1, "data.dat"), t("' using 1:2 with linespoints"),
          t(" lw "), i(2, "2"), t(" pt "), i(3, "7"), t(" ps "), i(4, "1.2"),
          t(" lc '"), i(5, "#0072BD"), t("' title '"), i(6, "label"), t("'"),
        }),
        s("hist", {    -- histograma
          t({ "set style data histograms",
              "set style fill solid 0.8 border -1",
              "set boxwidth 0.8",
              "plot '" }), i(1, "data.dat"), t("' using 2:xtic(1) title '"), i(2, "label"), t("'"),
        }),

        -- ── Estilos ───────────────────────────────────────────────────────────
        s("ls", {
          t("set linestyle "), i(1, "1"), t(" lc '"), i(2, "#0072BD"), t("'"),
          t(" lt "), i(3, "1"), t(" lw "), i(4, "2"), t(" pt "), i(5, "7"), t(" ps "), i(6, "1.5"),
        }),
        s("palette", {   -- cores científicas (matplotlib-like)
          t({ "set linestyle 1 lc '#0072BD' lw 2 pt 7  ps 1.2",
              "set linestyle 2 lc '#D95319' lw 2 pt 9  ps 1.2",
              "set linestyle 3 lc '#EDB120' lw 2 pt 5  ps 1.2",
              "set linestyle 4 lc '#7E2F8E' lw 2 pt 11 ps 1.2",
              "set linestyle 5 lc '#77AC30' lw 2 pt 13 ps 1.2",
              "set linestyle 6 lc '#4DBEEE' lw 2 pt 15 ps 1.2" }),
        }),
        s("viridis", {   -- paleta sequencial
          t({ "set palette defined ( \\",
              "  0 '#440154', \\",
              "  1 '#31688e', \\",
              "  2 '#35b779', \\",
              "  3 '#fde725'  \\",
              ")" }),
        }),

        -- ── Layout ────────────────────────────────────────────────────────────
        s("multi", {
          t("set multiplot layout "), i(1, "2"), t(","), i(2, "2"),
          t(" title '"), i(3, "título"), t("'"),
          t({ "", "", "# subplot 1", "plot " }), i(4, "sin(x)"),
          t({ "", "", "# subplot 2", "plot " }), i(5, "cos(x)"),
          t({ "", "", "unset multiplot" }),
        }),
        s("margin", {
          t("set lmargin at screen "), i(1, "0.12"),
          t({ "", "set rmargin at screen " }), i(2, "0.95"),
          t({ "", "set bmargin at screen " }), i(3, "0.12"),
          t({ "", "set tmargin at screen " }), i(4, "0.95"),
        }),

        -- ── Eixos / Labels ────────────────────────────────────────────────────
        s("labels", {
          t("set xlabel '"), i(1, "x"), t("' font ',14'"),
          t({ "", "set ylabel '" }), i(2, "y"), t("' font ',14'"),
          t({ "", "set title  '" }), i(3, "título"), t("' font ',16'"),
        }),
        s("range", {
          t("set xrange ["), i(1, "0"), t(":"), i(2, "10"), t("]"),
          t({ "", "set yrange [" }), i(3, "0"), t(":"), i(4, "1"), t("]"),
        }),
        s("log", {
          t("set logscale "), i(1, "xy"),
          t({ "", "set format " }), i(2, "xy"), t(" '10^{%T}'"),
        }),
        s("tics", {
          t("set xtics "), i(1, "0"), t(","), i(2, "1"), t(","), i(3, "10"),
          t({ "", "set mxtics " }), i(4, "5"),
          t({ "", "set ytics " }), i(5, "0"), t(","), i(6, "0.2"), t(","), i(7, "1"),
          t({ "", "set mytics " }), i(8, "2"),
        }),
        s("grid", {
          t({ "set grid xtics ytics",
              "set grid mxtics mytics",
              "set grid lw 1 lc 'gray70', lw 0.5 lc 'gray90'" }),
        }),

        -- ── Legenda ───────────────────────────────────────────────────────────
        s("legend", {
          t("set key "), i(1, "top right"), t(" box lw 1"),
          t({ "", "set key font ',12' spacing 1.5 samplen 3" }),
        }),
        s("noleg", { t("unset key") }),

        -- ── Fit ───────────────────────────────────────────────────────────────
        s("fitlin", {
          t({ "f(x) = a*x + b",
              "fit f(x) '" }), i(1, "data.dat"), t("' using 1:2 via a, b"),
          t({ "", "plot '" }), i(2, "data.dat"),
          t("' u 1:2 w points title 'dados', \\"),
          t({ "", "     f(x) w lines title sprintf('%.3fx + %.3f', a, b)" }),
        }),
        s("fitexp", {
          t({ "f(x) = a * exp(-b * x) + c",
              "a = 1; b = 0.1; c = 0",
              "fit f(x) '" }), i(1, "data.dat"), t("' using 1:2 via a, b, c"),
          t({ "", "plot '" }), i(2, "data.dat"),
          t("' u 1:2 w points title 'dados', f(x) w lines title 'fit exp'"),
        }),
        s("fitgauss", {
          t({ "f(x) = a * exp(-(x-mu)**2 / (2*sigma**2))",
              "a = 1; mu = 0; sigma = 1",
              "fit f(x) '" }), i(1, "data.dat"), t("' using 1:2 via a, mu, sigma"),
          t({ "", "plot '" }), i(2, "data.dat"),
          t("' u 1:2 w points title 'dados', \\"),
          t({ "", "     f(x) w lines title sprintf('mu=%.2f sigma=%.2f', mu, sigma)" }),
        }),
        s("fitpow", {
          t({ "f(x) = a * x**b",
              "a = 1; b = 2",
              "fit f(x) '" }), i(1, "data.dat"), t("' using 1:2 via a, b"),
          t({ "", "plot '" }), i(2, "data.dat"),
          t("' u 1:2 w points title 'dados', \\"),
          t({ "", "     f(x) w lines title sprintf('%.3f x^{%.3f}', a, b)" }),
        }),

        -- ── 3D / Mapas ────────────────────────────────────────────────────────
        s("heatmap", {
          t({ "set view map",
              "set pm3d at b interpolate 4,4",
              "unset surface",
              "set palette rgbformulae 33,13,10",
              "set colorbox",
              "splot '" }), i(1, "data.dat"), t("' using 1:2:3 with pm3d title ''"),
        }),
        s("3d", {
          t({ "set hidden3d",
              "set pm3d depthorder",
              "set palette rgbformulae 33,13,10",
              "set ticslevel 0",
              "set view 60,30",
              "splot '" }), i(1, "data.dat"), t("' using 1:2:3 with pm3d title ''"),
        }),
        s("contour", {
          t({ "set contour base",
              "set cntrparam levels " }), i(1, "10"),
          t({ "", "unset surface",
              "set view map",
              "splot '" }), i(2, "data.dat"), t("' using 1:2:3 with lines"),
        }),

        -- ── Anotações e utilidades ─────────────────────────────────────────────
        s("arrow", {
          t("set arrow from "), i(1, "x1,y1"), t(" to "), i(2, "x2,y2"),
          t(" lw 1.5 lc 'black'"),
        }),
        s("lbl", {
          t("set label '"), i(1, "texto"), t("' at "), i(2, "x,y"),
          t(" font ',12' tc 'black'"),
        }),
        s("vline", {
          t("set arrow from "), i(1, "0"), t(",graph 0 to "),
          i(2, "0"), t(",graph 1 nohead lw 1.5 lc 'red' dt 2"),
        }),
        s("hline", {
          t("set arrow from graph 0,"), i(1, "0"),
          t(" to graph 1,"), i(2, "0"),
          t(" nohead lw 1.5 lc 'red' dt 2"),
        }),
        s("rect", {
          t("set object 1 rectangle from "), i(1, "x1,y1"), t(" to "), i(2, "x2,y2"),
          t(" fc rgb 'gray' fs transparent solid 0.2 noborder"),
        }),
        s("loop", {
          t("do for ["), i(1, "k=1:5"), t("] {"),
          t({ "", "  plot sprintf('" }), i(2, "data_%d.dat"),
          t("', k) u 1:2 title sprintf('"), i(3, "run %d"), t("', k)"),
          t({ "", "}" }),
        }),
        s("sprintf", {
          t("title sprintf('"), i(1, "val = %.3f"), t("', "), i(2, "var"), t(")"),
        }),

        -- ── Template completo ──────────────────────────────────────────────────
        s("template", {
          t({ "# ── Terminal ──────────────────────────────────────────────────",
              "set terminal pdfcairo enhanced font 'Arial,12' size 6in,4in",
              "set output '" }), i(1, "output.pdf"), t("'"),
          t({ "", "",
              "# ── Estilos ───────────────────────────────────────────────────",
              "set linestyle 1 lc '#0072BD' lw 2 pt 7  ps 1.2",
              "set linestyle 2 lc '#D95319' lw 2 pt 9  ps 1.2",
              "set linestyle 3 lc '#EDB120' lw 2 pt 5  ps 1.2",
              "set linestyle 4 lc '#7E2F8E' lw 2 pt 11 ps 1.2",
              "",
              "# ── Labels ────────────────────────────────────────────────────",
              "set xlabel '" }), i(2, "x"), t("' font ',14'"),
          t({ "", "set ylabel '" }), i(3, "y"), t("' font ',14'"),
          t({ "", "set title  '" }), i(4, "título"), t("' font ',16'"),
          t({ "", "",
              "# ── Grid ─────────────────────────────────────────────────────",
              "set grid xtics ytics lw 1 lc 'gray70'",
              "",
              "# ── Legenda ───────────────────────────────────────────────────",
              "set key top right box lw 1 font ',12' spacing 1.5",
              "",
              "# ── Plot ──────────────────────────────────────────────────────",
              "plot '" }), i(5, "data.dat"),
          t("' using 1:2 with lines ls 1 title '"), i(6, "label"), t("'"),
        }),

      }) -- fim add_snippets
    end,
  },

}
