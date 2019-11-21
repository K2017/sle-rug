module Series2

import ParseTree;
import IO;
import String;
import Boolean;

/*
 * Syntax definition
 * - define a grammar for JSON (https://json.org/)
 */
 
start syntax JSON
  = Object;
  
syntax Object
  = "{" {Element ","}* "}"
  ;
  
syntax Element
  = String name ":" Value val
  ;
  
syntax Value
  = String
  | Number
  | Array
  | Object
  | Boolean
  | Null
  ;

syntax Null
  = "null";
  
syntax Boolean
  = "true" // Fill in
  | "false" // Fill in
  ;  
  
syntax Array
  = "[" {Value ","}* "]"
  ;  
  
lexical String
  = [\"] ![\"]* [\"]; // slightly simplified
  
lexical Number
  = [0-9]+ ; // Fill in. Hint; think of the pattern for numbers in regular expressions. How do you accept a number in a regex?  

layout Whitespace = [\ \t\n]* !>> [\ \t\n];  
  
// import the module in the console
start[JSON] example() 
  = parse(#start[JSON], 
          "{
          '  \"age\": 42, 
          '  \"name\": \"Joe\",
          '  \"address\": {
          '     \"street\": \"Wallstreet\",
          '     \"number\": 102
          '  },
          '  \"residences\": [\"chicago\",\"florida\"],
          '  \"married\": true
          '}");    
  


// use visit/deep match to find all element names
// - use concrete pattern matching
// - use "<x>" to convert a String x to str
set[str] propNames(start[JSON] json) {
    set[str] ret = {};
    for(/Element x := json) {
        ret = ret + "<x.name>";
    }
    return ret;
}

// define a recursive transformation mapping JSON to map[str,value] 
// - every Value constructor alternative needs a 'transformation' function
// - define a data type for representing null;

map[str, value] json2map(start[JSON] json) = json2map(json.top);

map[str, value] json2map((JSON)`<Object obj>`)  = json2map(obj);
map[str, value] json2map((Object)`{<{Element ","}* elems>}`) = ( unquote("<elem.name>"):json2value(elem.val) | Element elem <- elems );

str unquote(str s) = s[1..-1];

value json2value((Value)`<String s>`)    = unquote("<s>"); // This is an example how to transform the String literal to a value
value json2value((Value)`<Number n>`)    = toInt("<n>"); // ... This needs to change. The String module contains a function to convert a str to int
value json2value((Value)`<Boolean b>`)   = fromString("<b>");
value json2value((Value)`<Array ar>`)    = json2value(ar);
value json2value((Array)`[<{Value ","}* vals>]`) = [json2value(val) | Value val <- vals];
value json2value((Value)`<Object ob>`)   = json2map(ob);
value json2value((Value)`<Null nu>`)     = "null";

default value json2value(Value v) { throw "No tranformation function for `<v>` defined"; }

test bool example2map() = json2map(example()) == (
  "age": 42,
  "name": "Joe",
  "address" : (
     "street" : "Wallstreet",
     "number" : 102
  ),
  "residences" : ["chicago","florida"],
  "married": true
);

 
  
/*
 * Optionally: do this tutorial to get more familiarized with concrete syntax
 * by extending Javascript with new language features:
 *   https://github.com/cwi-swat/hack-your-javascript
 */  
  
