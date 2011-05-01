// Copyright 2009 the Sputnik authors.  All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/**
 * @name: S11.13.2_A4.9_T1.3;
 * @section: 11.13.2, 11.10.1;
 * @assertion: The production x &= y is the same as x = x & y; 
 * @description: Type(x) and Type(y) vary between primitive string and String object;
*/


// Converted for Test262 from original Sputnik source

ES5Harness.registerTest( {
id: "S11.13.2_A4.9_T1.3",

path: "11_Expressions\11.13_Assignment_Operators\11.13.2_Compound_Assignment\S11.13.2_A4.9_T1.3.js",

assertion: "The production x &= y is the same as x = x & y",

description: "Type(x) and Type(y) vary between primitive string and String object",

test: function testcase() {
   //CHECK#1
x = "1";
x &= "1";
if (x !== 1) {
  $ERROR('#1: x = "1"; x &= "1"; x === 1. Actual: ' + (x));
}

//CHECK#2
x = new String("1");
x &= "1";
if (x !== 1) {
  $ERROR('#2: x = new String("1"); x &= "1"; x === 1. Actual: ' + (x));
}

//CHECK#3
x = "1";
x &= new String("1");
if (x !== 1) {
  $ERROR('#3: x = "1"; x &= new String("1"); x === 1. Actual: ' + (x));
}

//CHECK#4
x = new String("1");
x &= new String("1");
if (x !== 1) {
  $ERROR('#4: x = new String("1"); x &= new String("1"); x === 1. Actual: ' + (x));
}

//CHECK#5
x = "x";
x &= "1";
if (x !== 0) {
  $ERROR('#5: x = "x"; x &= "1"; x === 0. Actual: ' + (x));
}

//CHECK#6
x = "1";
x &= "x";
if (x !== 0) {
  $ERROR('#6: x = "1"; x &= "x"; x === 0. Actual: ' + (x));
}

 }
});
