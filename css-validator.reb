Rebol [
	Title: "CSS parser"
	Author: onetom@hackerspace.sg
]

spacer: charset reduce [ tab newline #" " ]
_: [ some spacer ]
digit: charset [ #"0" - #"9" ]
letter: charset [ #"a" - #"z" #"A" - #"Z" ]
dash: charset "-"
word: [ some letter any [ letter | digit | dash ] ]
comment: [ to "/*" thru "*/" ]

pseudo-selector: [ ":" word opt [ "(" thru ")" ] ]
tag-selector: [ word opt pseudo-selector ]
id-selector: [ "#" tag-selector ]
class-selector: [ "." tag-selector ]
selector: [
	[ tag-selector | id-selector | class-selector ]
	any [ id-selector | class-selector ]
	opt pseudo-selector ]
selectors: [ selector any [ [ opt _ ">" opt _ | _ ] selector ] ]
group-of-selectors: [ selectors any [ _ "," _ selectors ] ]
property: [ word ]
declaration: [ "{" _ property _ ":" _ value opt ";" ]
declarations: [ any declaration ]
ruleset: [ group-of-selectors declarations ]
css-rules: [ some [ comment | ruleset | _ ] ]

test: funct [desc css rule /fail] [
	pass?: parse/all css rule
	if any [
		all [fail pass?]
		not any [fail pass?]
	][
		print [ "✗" desc ]
		probe css]
]

print "^/---------------"

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
