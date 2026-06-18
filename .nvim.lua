vim.keymap.set("n", "<F5>", function()
    vim.cmd(":! ./build.sh")
end, {})
