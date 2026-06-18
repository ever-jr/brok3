vim.keymap.set("n", "<F5>", function()
    if vim.fn.has("win32") == 1 then
        vim.cmd(":! /k build.bat")
    else
        vim.cmd(":! ./build.sh")
    end
end, {})
