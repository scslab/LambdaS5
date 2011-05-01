// Copyright 2009 the Sputnik authors.  All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/**
 * @name: S7.3_A1.1_T2;
 * @section: 7.3;
 * @assertion: LINE FEED (U+000A) may occur between any two tokens;
 * @description: Insert real LINE FEED between tokens of var x=1;  
*/


// Converted for Test262 from original Sputnik source

ES5Harness.registerTest( {
id: "S7.3_A1.1_T2",

path: "07_Lexical_Conventions\7.3_Line_Terminators\S7.3_A1.1_T2.js",

assertion: "LINE FEED (U+000A) may occur between any two tokens",

description: "Insert real LINE FEED between tokens of var x=1",

test: function testcase() {
   //CHECK#1
var
x
=
1;
if (x !== 1) {
  $ERROR('#1: var\\nx\\n=\\n1\\n; x === 1. Actual: ' + (x));
}

 }
});
