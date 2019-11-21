module Series1

import IO;

/*
 * Documentation: http://docs.rascal-mpl.org 
 *  or button with wasp with hat)
 */

/*
 * Hello world
 *
 * - Import IO, write a function that prints out Hello World!
 * - open the console (right-click in the editor, "Start console"
 * - import this module and invoke helloWorld.
 */
 
void helloWorld() {
    println("Henlo World!");
} 


/*
 * FizzBuzz (https://en.wikipedia.org/wiki/Fizz_buzz)
 * - implement imperatively
 * - implement as list-returning function
 */
 
void fizzBuzz1() {
    for(i <- [0..100]) {
        if(i % 15 == 0) {
            print("fizzbuzz");
        }
        else if(i % 5 == 0) {
            print("buzz");
        }
        else if(i % 3 == 0) {
            print("fizz");
        } else {
            print("<i>");
        }
        print(" ");
    }
}

list[str] fizzBuzz2() {
    list[str] ret = [i % 15 == 0 ? "fizzbuzz" : 
                     i % 5 == 0 ? "buzz" : 
                     i % 3 == 0 ? "fizz" : 
                     "<i>" | i <- [0..100]];
    return ret;
}

/*
 * Factorial
 * - first using ordinary recursion
 * - then using pattern-based dispatch 
 *  (complete the definition with a default case)
 */
 

int factorial(int n) {
    if (n == 0) return 0;
    if (n == 1) return 1;
    return n*factorial(n-1);
}

int fact(0) = 1;
int fact(1) = 1;
int fact(n) = n*fact(n-1);



/*
 * Comprehensions
 * - use println to see the result
 */
 
void comprehensions() {

  // construct a list of squares of integer from 0 to 9 (use range [0..10])
  println("list of squares: <[i*i | i <- [0..10]]>");
  // same, but construct a set
  println("set of squares: <{i*i | i <- [0..10]}>");
  
  // same, but construct a map
  println("map of squares: <(i:i*i | i <- [0..10])>");
  // construct a list of factorials from 0 to 9
  println("list of factorials: <[fact(i) | i <- [0..10]]>");
  // same, but no only for even numbers 
  println("same but for even: <[fact(i) | i <- [0..10], i % 2 == 0]>");
}
 

/*
 * Pattern matching
 * - fill in the blanks with pattern match expressions (using :=)
 */
 

void patternMatching() {
  str hello = "Hello World!";
  
  
  // print all splits of list
  list[int] aList = [1,2,3,4,5];
  for ([*hd,*tl] := aList) {
    println("<hd> <tl>");
  }
  
  // print all partitions of a set
  set[int] aSet = {1,2,3,4,5};
  for ({*hd,*tl} := aSet) {
    println("<hd> <tl>");
  } 
}  
 
 
 
/*
 * Trees
 * - complete the data type ColoredTree with
 *   constructors for binary red and black branches
 * - use the exampleTree() to test in the console
 */
 
data ColoredTree
  = leaf(int n)
  | red(ColoredTree l, ColoredTree r)
  | black(ColoredTree l, ColoredTree r);
  

ColoredTree exampleTree()
  =  red(black(leaf(1), red(leaf(2), leaf(3))),
              black(leaf(4), leaf(5)));  
  
  
// write a recursive function summing the leaves
// (use switch or pattern-based dispatch)

int sumLeaves(leaf(n)) = n;
int sumLeaves(red(l, r)) = sumLeaves(l) + sumLeaves(r);
int sumLeaves(black(l, r)) = sumLeaves(l) + sumLeaves(r);

// same, but now with visit
int sumLeavesWithVisit(ColoredTree t) {
    int sum = 0;
    visit(t) {
        case leaf(n): sum = sum + n;
    };
    return sum;
}

// same, but now with a for loop and deep match
int sumLeavesWithFor(ColoredTree t) {
    int sum = 0;
    for(/leaf(n) := t) {
        sum = sum + n;
    }
    return sum;
}

// same, but now with a reducer and deep match
// Reducer = ( <initial value> | <some expression with `it` | <generators> )
int sumLeavesWithReducer(ColoredTree t) = ( 0 | it + e | /leaf(e) <- t); 


// add 1 to all leaves; use visit + =>
ColoredTree inc1(ColoredTree t) {
    return visit(t) {
        case leaf(n) => leaf(n+1)
    };
}

// write a test for inc1, run from console using :test
test bool testInc1() = sumLeaves(inc1(exampleTree())) == 20;

// define a property for inc1, i.e. a boolean
// function that checks if one tree is inc1 of the other
// (without using inc1).
// Use switch on the tupling of t1 and t2 (`<t1, t2>`)
// or pattern based dispatch.
// Hint! The tree also needs to have the same shape!
bool isInc1(ColoredTree t1, ColoredTree t2) {
    switch(<t1,t2>) {
        case </int e1, /int e2>: if(!(e1 == e2 + 1 || e2 == e1 + 1)) return false;
    }
    return true;
}
 
// write a randomized test for inc1 using the property
// again, execute using :test
test bool testInc1Randomized(ColoredTree t1) = isInc1(inc1(t1), t1);


 

 
  
  
