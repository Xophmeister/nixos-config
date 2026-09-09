-- tofu fmt writes two-space indentation and will not be argued with, so the
-- buffer is set to produce what the formatter would anyway.
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2

-- HCL comments are #, though the parser also accepts //. Commenting plugins
-- and `gc` read this.
vim.opt_local.commentstring = "# %s"
