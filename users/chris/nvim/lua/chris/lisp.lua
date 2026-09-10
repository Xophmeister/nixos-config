-- Lisp editing: REPL integration and structural editing.
--
-- Conjure replaces vim-fireplace. It covers Clojure and Scheme from one
-- plugin, so the Scheme side gains a REPL it did not previously have --
-- chicken-lsp-server only ever provided completion and navigation.
--
-- Mappings live under <localleader>, set to "," in init.lua. <localleader>ee
-- evaluates the form under the cursor, <localleader>er the root form,
-- <localleader>eb the whole buffer, <localleader>ls opens the log, and
-- <localleader>K looks a symbol up in the client's documentation.

-- Conjure's Scheme client speaks to an external REPL over stdio and assumes
-- MIT Scheme, so CHICKEN needs both the command and the prompt to wait for.
--
-- -:c is required: csi prints no prompt at all when its stdin is a pipe, and
-- Conjure has nothing to synchronise on without one. -quiet is deliberately
-- absent despite being documented as only suppressing the banner -- it
-- silences the prompt too, which leaves Conjure waiting forever.
--
-- The pattern is a Lua pattern, matching prompts like "#;1> ".
vim.g["conjure#client#scheme#stdio#command"] = "csi -:c"
vim.g["conjure#client#scheme#stdio#prompt_pattern"] = "#;%d+> "

-- The heads-up display overlaps the completion popup in a narrow split;
-- the log buffer is a keystroke away when it is wanted.
vim.g["conjure#log#hud#enabled"] = false

-- Documentation lookup, moved off the bare K that Conjure claims by default.
--
-- Conjure reads each mapping value as either a string or a table, and the two
-- are not equivalent: a string is appended to the <localleader> prefix, while
-- a table is taken as a whole mapping and used verbatim. This one defaults to
-- {"K"}, which is how it lands on K itself rather than under the prefix -- so
-- giving it the plain string "K" is what moves it to <localleader>K.
--
-- That matters well beyond the Lisps. Conjure's filetype list covers Python,
-- Rust and Lua as well as Clojure and Scheme, and the mapping is buffer-local
-- to each of them, so the default shadowed Neovim's own K -- LSP hover -- in
-- most of what gets edited here. Little is lost by moving it: clojure-lsp and
-- chicken-lsp-server both answer hover with documentation, the latter reading
-- the same chicken-doc repository Conjure's lookup would have consulted.
vim.g["conjure#mapping#doc_word"] = "K"

-- Structural editing.
--
-- vim-sexp provides the motions and text objects, and the
-- mappings-for-regular-people layer rebinds them off the awkward defaults.
-- parinfer-rust infers the parens from indentation as you type. The two are
-- complementary rather than overlapping: parinfer maintains balance while
-- writing, vim-sexp moves and reshapes forms that already exist.
vim.g.sexp_enable_insert_mode_mappings = 1

-- parinfer's smart mode follows edits rather than reformatting on entry,
-- which is the only mode that leaves existing files alone.
vim.g.parinfer_mode = "smart"
