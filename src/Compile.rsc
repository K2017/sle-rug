module Compile

import AST;
import Resolve;
import IO;
import lang::html5::DOM; // see standard library
import List;
import String;

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTML5Node type and the `str toString(HTML5Node x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, toString(form2html(f)));
}

HTML5Node form2html(AForm f) {
  list[value] attrs = []; 
  list[value] children = [form2html(q) | q:AQuestion _ <- f.questions]; 
  HTML5Node footer = footer(script(src(f.src[extension="js"].top.file)));
  return html([body(div(attrs + children)), footer]);
}

HTML5Node form2html(q:question(str label, AId i, AType tp)) {
  list[value] attrs = [id(i.name)]; 
  list[value] children = [p(label[1..-1]), form2html(i, tp)];
  return div(attrs + children);
}

HTML5Node form2html(b:block(list[AQuestion] qs)) {
  return div([id("block<b.src.offset>")] + [form2html(q) | q <- qs]);
}

HTML5Node form2html(ifthen(AExpr guard, AQuestion ifq)) {
  list[value] attrs = [];
  list[value] children = [form2html(ifq)];
  return div(attrs + children);
}

HTML5Node form2html(ifthenelse(AExpr guard, AQuestion ifq, AQuestion elseq)) {
  list[value] attrs = [];
  list[value] children = [form2html(ifq), form2html(elseq)];
  return div(attrs + children);
}

HTML5Node form2html(AId i, AType t) {
  list[HTML5Attr] attrs = [id("_<i.name>")];
  switch(t) {
    case integer(): attrs += [\type("number"), step("1")];
    case boolean(): attrs += [\type("checkbox")];
    // no attributes results in default string input
  }
  return input(attrs);
}


// ------ JavaScript ------

str form2js(AForm f, bool visible = true) {
  // normal variables
  list[str] decls = ["// variables:"];

  decls += [
"var <id.name> = document.getElementById(\'_<id.name>\').<getPropName(t)>;" 
           | /q:question(_, AId id, AType t, ex = empty()) := f];

  // computed variables
  decls += [
"// computed variable <id.name>:
document.getElementById(\'_<id.name>\').<getPropName(t)> = <form2js(exp)>;
document.getElementById(\'_<id.name>\').readOnly = true;
document.getElementById(\'_<id.name>\').disabled = true; 
document.getElementById(\'_<id.name>\').style = \"-webkit-appearance: none; -moz-appearance:textfield; margin: 0;\";\n" 
           | /q:question(_, AId id, AType t, ex = exp) := f, exp != empty()];

  return 
"document.addEventListener(\'input\', function (evt) {
'  updateVisibility();
});
updateVisibility();

function updateVisibility() {
'  <intercalate("\n", decls + [form2js(q) | q <- f.questions ])>
}";
}

str form2js(ifthen(AExpr guard, AQuestion ifq), bool visible = true) {
  return 
"if (<form2js(guard)>) {
'  <form2js(ifq, visible=true)>
} else {
'  <form2js(ifq, visible=false)>
}";
}

str form2js(ifthenelse(AExpr guard, AQuestion ifq, AQuestion elseq), bool visible = true) {
  return 
"if (<form2js(guard)>) {
'  <form2js(ifq, visible=true)>
'  <form2js(elseq, visible=false)>
} else {
'  <form2js(ifq, visible=false)>
'  <form2js(elseq, visible=true)>
}";
}

str form2js(b:block(list[AQuestion] qs), bool visible = true) {
  return 
"document.getElementById(\'block<b.src.offset>\').style.display = <visible ? "\"\"" : "\"none\"">;
<for (x <- [form2js(q) | q <- qs]) {>\n<x><}>";
}

str form2js(q:question(str label, AId id, AType tp), bool visible = true) {
  return "document.getElementById(\'<id.name>\').style.display = <visible ? "\"\"" : "\"none\"">;";
}

str form2js(AExpr e, bool visible = true) {
  switch (e) {
    case ref(AId x): return "<x.name>";
    case const(AConst x): return form2js(x);
    case brack(AExpr x): return "( <form2js(x)> )";
    case not(AExpr x): return "!<form2js(x)>";
    case mul(AExpr l, AExpr r): return "<form2js(l)> * <form2js(r)>";
    case div(AExpr l, AExpr r): return "<form2js(l)> / <form2js(r)>";
    case add(AExpr l, AExpr r): return "<form2js(l)> + <form2js(r)>";
    case sub(AExpr l, AExpr r): return "<form2js(l)> - <form2js(r)>";
    case lt(AExpr l, AExpr r): return "<form2js(l)> \< <form2js(r)>";
    case leq(AExpr l, AExpr r): return "<form2js(l)> \<= <form2js(r)>";
    case gt(AExpr l, AExpr r): return "<form2js(l)> \> <form2js(r)>";
    case geq(AExpr l, AExpr r): return "<form2js(l)> \>= <form2js(r)>";
    case eq(AExpr l, AExpr r): return "<form2js(l)> == <form2js(r)>";
    case neq(AExpr l, AExpr r): return "<form2js(l)> != <form2js(r)>";
    case and(AExpr l, AExpr r): return "<form2js(l)> && <form2js(r)>";
    case or(AExpr l, AExpr r): return "<form2js(l)> || <form2js(r)>";
  }
}

str form2js(AConst c, bool visible = true) {
  switch (c) {
    case integer(int i): return "<i>";
    case boolean(bool b): return "<b>";
    case string(str s): return s;
  }
}

str getPropName(AType t) {
  switch (t) {
    case boolean(): return "checked";
    case integer(): return "value";
    case string(): return "value";
  }
}
