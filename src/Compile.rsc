module Compile

import AST;
import Resolve;
import IO;
import lang::html5::DOM; // see standard library

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
HTML5Node form2html(block(list[AQuestion] qs)) {
  return div([form2html(q) | q <- qs]);
}
HTML5Node form2html(ifthen(AExpr guard, AQuestion ifq)) {
  return div();
}
HTML5Node form2html(ifthenelse(AExpr guard, AQuestion ifq, AQuestion elseq)) {
  return div();
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

data Condition 
 = ifthencon(AExpr guard, AQuestion ifq)
 | ifelsecon(AExpr guard, AQuestion ifq, AQuestion elseq)
 ;

str form2js(AForm f) {
  return "";
}

str form2js(ifthen(AExpr guard, AQuestion ifq)) {
  return "if (<form2js(guard)>)\n  <form2js(ifq, true)>\nelse\n  <form2js(ifq, false)>";
}

str form2js(AQuestion q, bool visibly) {
  
}

str form2js(AExpr e) {
  
}


