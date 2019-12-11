module Compile

import AST;
import Resolve;
import IO;
import lang::html5::DOM; // see standard library
import List;

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
  return html([body(div(attrs + children))]);
}

HTML5Node form2html(q:question(str label, AId id, AType tp)) {
  list[value] attrs = []; 
  list[value] children = [p(label[1..-1]), form2html(id, tp)];
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
  list[HTML5Attr] attrs = [id(i.name)];
  switch(t) {
    case integer(): attrs += [\type("number"), step("1")];
    case boolean(): attrs += [\type("checkbox")];
    // no attributes results in default string input
  }
  return input(attrs);
}


// ------ JavaScript ------

str form2js(AForm f) {
  return "function updateVisibility() {\n<intercalate("\n", [form2js(q) | q <- f.questions ])>\n}";
}

str form2js(ifthen(AExpr guard, AQuestion ifq)) {
  return "if (<form2js(guard)>)\n  <form2js(ifq, visible=true)>else\n  <form2js(ifq, visible=false)>";
}

str form2js(ifthenelse(AExpr guard, AQuestion ifq, AQuestion elseq)) {
  return "if (<form2js(guard)>)\n  <form2js(ifq, visible=true)><form2js(elseq, visible=false)>else\n  <form2js(ifq, visible=false)><form2js(elseq, visible=true)>";
}

str form2js(b:block(list[AQuestion] ifq), bool visible = true) {
  return "document.getElementById(\'block<b.src.offset>\').style.display = <visible ? "initial" : "none">;\n";
}

str form2js(q:question(str label, AId id, AType tp), bool visible = true) {
  return "document.getElementById(\'<id.name>\').style.display = <visible ? "initial" : "none">;\n";
}

str form2js(AExpr e) {
  return "";
  /*switch (e) {
    case ref(AId x): 
  }*/
}


