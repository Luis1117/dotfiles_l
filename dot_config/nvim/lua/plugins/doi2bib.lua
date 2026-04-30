-- lua/plugins/doi2bib.lua
-- Inserção de referências via DOI / arXiv ID → .bib formatado com segurança
-- Dependência externa: npm install -g bibtex-tidy

local BIBTEX_TIDY = "/home/luis11/.npm-global/bin/bibtex-tidy"

local function find_bib()
  return vim.fn.glob(vim.fn.getcwd() .. "/**/*.bib", false, true)[1]
    or vim.fn.glob(vim.fn.expand("%:p:h") .. "/*.bib", false, true)[1]
end

local function tidy(bib)
  if vim.fn.filereadable(BIBTEX_TIDY) ~= 1 then
    vim.notify("bibtex-tidy não encontrado em " .. BIBTEX_TIDY, vim.log.levels.WARN)
    return
  end

  local result = vim.fn.system({
    BIBTEX_TIDY,
    bib,
    "--modify",
    "--curly",
    "--numeric",
    "--sort=year",
    "--sort-fields",
    "--no-wrap",
    "--trailing-commas",
    "--enclosing-braces=title,journal,booktitle",
    "--quiet",
  })

  if vim.v.shell_error ~= 0 then
    vim.notify("❌ bibtex-tidy erro:\n" .. result, vim.log.levels.ERROR)
  end
end

local function reload_bib_buffer(bib)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf) == bib then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("edit!")
      end)
    end
  end
end

local function fetch_doi(doi)
  local result = vim.fn.system({
    "curl", "-sL",
    "-H", "Accept: text/bibliography; style=bibtex",
    "https://doi.org/" .. doi,
  })

  if vim.v.shell_error ~= 0 or result == "" or not result:match("^%s*@") then
    return nil, result
  end

  return result, nil
end

local function fetch_arxiv(arxiv_id)
  arxiv_id = arxiv_id:gsub("^[Aa]r[Xx]iv:", "")

  local result = vim.fn.system({
    "curl", "-sL",
    "https://export.arxiv.org/abs/" .. arxiv_id,
  })

  local doi = result:match('data%-doi="([^"]+)"')
    or result:match('doi%.org/([^"<]+)')

  if doi then
    return fetch_doi(doi)
  end

  local title = result:match('<meta name="citation_title" content="([^"]+)"')
    or "Unknown Title"

  local authors = {}
  for a in result:gmatch('<meta name="citation_author" content="([^"]+)"') do
    table.insert(authors, a)
  end

  local year = result:match('<meta name="citation_date" content="(%d%d%d%d)')
    or os.date("%Y")

  local entry = string.format(
    '@misc{arxiv_%s,\n  author        = {%s},\n  title         = {{%s}},\n  year          = {%s},\n  eprint        = {%s},\n  archiveprefix = {arXiv},\n  url           = {https://arxiv.org/abs/%s},\n}\n',
    arxiv_id:gsub("/", "_"),
    table.concat(authors, " and "),
    title,
    year,
    arxiv_id,
    arxiv_id
  )

  return entry, nil
end

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function sanitize_key_part(s)
  s = s or ""
  s = vim.fn.iconv(s, "utf-8", "ascii//TRANSLIT")
  s = s:gsub("[{}\\]", "")
  s = s:gsub("[^%w%s%-]", "")
  s = s:gsub("%s+", "")
  return s
end

local function get_existing_keys(bib)
  local keys = {}
  local f = io.open(bib, "r")
  if not f then
    return keys
  end

  local content = f:read("*a")
  f:close()

  for key in content:gmatch("@%w+%s*{%s*([^,%s]+)%s*,") do
    keys[key] = true
  end

  return keys
end

local function make_unique_key(base, existing)
  if not existing[base] then
    return base
  end

  local i = 2
  while existing[base .. tostring(i)] do
    i = i + 1
  end
  return base .. tostring(i)
end

local function generate_key(entry, bib)
  local existing = get_existing_keys(bib)

  local author = entry:match("author%s*=%s*{([^}]+)}") or ""
  local year = entry:match("year%s*=%s*{?(%d%d%d%d)}?") or os.date("%Y")
  local title = entry:match("title%s*=%s*{{([^}]+)}}")
    or entry:match("title%s*=%s*{([^}]+)}")
    or ""

  local first_author = author:match("^([^,]+)")
  if first_author and first_author:match(" and ") then
    first_author = first_author:match("^(.-) and ")
  end

  if first_author and first_author:match(",") then
    first_author = first_author:match("^([^,]+)")
  end

  if first_author then
    first_author = trim(first_author)
    local lastname = first_author:match("(%S+)$") or first_author
    lastname = sanitize_key_part(lastname)

    if lastname ~= "" then
      local base = lastname .. year
      return make_unique_key(base, existing)
    end
  end

  local title_word = sanitize_key_part(title:match("^(%w+)") or "ref")
  local base = title_word .. year
  return make_unique_key(base, existing)
end

local function replace_entry_key(entry, new_key)
  return entry:gsub("^%s*@(%w+)%s*{%s*([^,%s]+)%s*,", "@%1{" .. new_key .. ",", 1)
end

local function normalize_new_entry(entry, bib)
  local key = generate_key(entry, bib)
  return replace_entry_key(entry, key), key
end

local function is_arxiv_id(id)
  id = trim(id)
  return id:lower():match("^arxiv:")
    or id:match("^%d%d%d%d%.%d%d%d%d%d[vV]?%d*$")
    or id:match("^%d%d%d%d%.%d%d+$")
end

return {
  {
    "nvim-lua/plenary.nvim",
    optional = true,
    keys = {
      {
        "<leader>li",
        function()
          local id = trim(vim.fn.input("DOI / arXiv ID: "))
          if id == "" then
            return
          end

          local bib = find_bib()
          if not bib then
            vim.notify("Nenhum .bib encontrado no projeto!", vim.log.levels.WARN)
            return
          end

          vim.notify("🔍 Buscando " .. id .. "...", vim.log.levels.INFO)

          local entry, err
          if is_arxiv_id(id) then
            entry, err = fetch_arxiv(id)
          else
            entry, err = fetch_doi(id)
          end

          if not entry then
            vim.notify("❌ Não encontrado:\n" .. (err or ""), vim.log.levels.ERROR)
            return
          end

          entry = trim(entry)
          entry, new_key = normalize_new_entry(entry, bib)

          local f, ferr = io.open(bib, "a")
          if not f then
            vim.notify("❌ Não foi possível abrir " .. bib .. ": " .. (ferr or ""), vim.log.levels.ERROR)
            return
          end

          f:write("\n\n" .. entry .. "\n")
          f:flush()
          f:close()

          vim.defer_fn(function()
            tidy(bib)
            reload_bib_buffer(bib)
            vim.notify(
              "✅ Adicionado em " .. vim.fn.fnamemodify(bib, ":t") .. " com key: " .. new_key,
              vim.log.levels.INFO
            )
          end, 100)
        end,
        ft = { "tex", "latex", "bib" },
        desc = "LaTeX: DOI/arXiv → .bib",
      },

      {
        "<leader>lbt",
        function()
          local bib = find_bib()
          if not bib then
            vim.notify("Nenhum .bib encontrado!", vim.log.levels.WARN)
            return
          end

          if vim.fn.filereadable(BIBTEX_TIDY) ~= 1 then
            vim.notify("bibtex-tidy não encontrado em " .. BIBTEX_TIDY, vim.log.levels.WARN)
            return
          end

          tidy(bib)
          reload_bib_buffer(bib)

          vim.notify(
            "✅ .bib formatado sem alterar citation keys: " .. vim.fn.fnamemodify(bib, ":t"),
            vim.log.levels.INFO
          )
        end,
        ft = { "tex", "latex", "bib" },
        desc = "LaTeX: Formatar .bib com segurança",
      },
    },
  },
}
