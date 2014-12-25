Rebol [
	Title: "CSS parser"
	Author: onetom@hackerspace.sg
]

spacer: charset reduce [ tab newline #" " ]
_: [ any spacer ]
digit: charset [ #"0" - #"9" ]
letter: charset [ #"a" - #"z" #"A" - #"Z" ]
hex: union digit charset [ #"a" - #"f" #"A" - #"F" ]
dash: "-"
word: [ some letter any [ letter | digit | dash ] ]
comment: [ to "/*" thru "*/" ]

fn: [ word [ "(" thru ")" ] ]
pseudo-selector: [ ":" [ fn | word ] ]
tag-selector: [ word opt pseudo-selector ]
id-selector: [ "#" tag-selector ]
class-selector: [ "." tag-selector ]
selector: [
	[ tag-selector | id-selector | class-selector ]
	any [ id-selector | class-selector ]
	opt pseudo-selector ]
selectors: [ selector any [ [ _ ">" _ | _ ] selector ] ]
group-of-selectors: [ selectors any [ _ "," _ selectors ] ]
property: [ some [ letter | dash ] any [ letter | digit | dash ] ]
float: [ some digit opt [ "." any digit] ]
unit: [ "px" | "em" | "rem" | "%" ]
value: [ float opt unit | fn | word ]
declaration: [ property _ ":" _ some [ value _ opt "," _ ] opt ";" ]
declarations: [ "{" _ any [ declaration _ ] "}" ]
ruleset: [ group-of-selectors declarations ]
css-rules: [ some [ comment | ruleset | _ ] ]

test: funct [desc css rule /fail] [
	pass?: parse/all css rule
	if any [
		all [fail pass?]
		not any [fail pass?]
	][
		print [ "✗" desc ]
		probe css
	]
]

print [ "^/-------" now/time "--------^/" ]

print "=== ID selector ==="
test "Simple" "#menu" id-selector
test/fail "Not a tag" "div" id-selector
test/fail "Not a class" ".some-class" id-selector

print "=== Class selector ==="
test "Simple" ".menu" class-selector
test/fail "Not a tag" "div" class-selector
test/fail "Not an ID" "#menu" class-selector

print "=== Words ==="
test "With dash" "left-nav" word
test/fail "Can not start with number" "1word" word
test/fail "Can not start with dash" "-word" word

print "=== Comment ==="
test "Multi-line" {/* Some *
	multi-line comment */} comment

print "=== Selector ==="
test "Only tag" "div" selector
test "tag+id+class+pseudo" "div#menu.right.aligned:hover" selector
test "pseudo with param" ".tablet:not(.mobile).only.row" selector

print "=== Selectors ==="
test "Select children" "a img" selectors
test "Select immediate children" "a > img" selectors
test "Compact select immediate children" "a>img" selectors

print "=== Group of selectors ==="
test "Compact 2 tags" "th,td" group-of-selectors
test "2 complex selectors" "th#first , td.odd" group-of-selectors

print "=== Property declaration ==="
test "Compact, simple" "color:red" declaration
test "Unit value" "margin: 1.2em;" declaration
test "Function value" "src: url(../fonts/basic.icons.eot);" declaration
test "Function+Word+Number value"
	"box-shadow: 0.3em 0em 0em 0 rgba(0, 0, 0, 0.2) inset;" declaration
test "Multiple comma separated functions"
	"src: url(../fonts/basic.icons.eot?#iefix) format('embedded-opentype'), url(../fonts/basic.icons.svg#basic.icons) format('svg'), url(../fonts/basic.icons.woff) format('woff'), url(../fonts/basic.icons.ttf) format('truetype');"
	declaration
