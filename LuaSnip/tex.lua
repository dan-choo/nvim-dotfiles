local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

return
{
    -- \frac
    s({
        trig="([^%a])ff", 
        regTrig = true,
        wordTrig = false,
        dscr="Expands 'ff' into '\frac{}{}'",
        snippetType="autosnippet"
    },
    fmta(
    "<>\\frac{<>}{<>}", {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
        i(2)
    })
    ),

    -- \{\}
    s({
        trig="([^%a])ss",
        regTrig = true,
        wordTrig = false,
        dscr="Expands 'ss' into the set command",
        snippetType="autosnippet"
    },
    fmta(
    "<>\\{<>\\}", {
        f( function(_, snip) return snip.captures[1] end ),
        i(1)
    })
    ),
    
    -- Code for environment snippet in the above GIF
    s({
        trig="([^%a])ee",
        regTrig = true,
        wordTrig = false,
        dscr="Expands 'ee' into environment",
        snippetType="autosnippet"
    },
    fmta(
    [[
    <>\begin{<>}
        <>
    <>\end{<>}
    ]], {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
        i(2),
        t(" "),
        rep(1),  -- this node repeats insert node i(1)
    })
    ),

}
