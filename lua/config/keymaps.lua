local mapKey = require("utils.keyMapper").mapKey

-- General
mapKey('<C-q>', ':q<cr>')

-- Neotree toggle
mapKey('<leader>e', ':Neotree toggle<cr>')

-- pane navigation
mapKey('<C-Left>', '<C-w>h')
mapKey('<C-Down>', '<C-w>j')
mapKey('<C-Up>', '<C-w>k')
mapKey('<C-Right>', '<C-w>l')

-- indent
mapKey('<', '<gv', 'v')
mapKey('>', '>gv', 'v')

