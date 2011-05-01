// Copyright 2009 the Sputnik authors.  All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/**
 * @name: S9.1_A1_T1;
 * @section: 9.1;
 * @assertion: Result of primitive conversion from object is a default value for the Object;
 * @description: Using operator Number. The operator calls ToPrimitive with hint Number;
*/


// Converted for Test262 from original Sputnik source

ES5Harness.registerTest( {
id: "S9.1_A1_T1",

path: "09_Type_Conversion\9.1_ToPrimitive\S9.1_A1_T1.js",

assertion: "Result of primitive conversion from object is a default value for the Object",

description: "Using operator Number. The operator calls ToPrimitive with hint Number",

test: function testcase() {
   // CHECK#1
var object = {valueOf: function() {return "1"}, toString: function() {return 0}};
if (Number(object) !== 1) {
  $ERROR('#1: var object = {valueOf: function() {return "1"}, toString: function() {return 0}}; Number(object) === 1. Actual: ' + (Number(object)));
}

// CHECK#2
var object = {valueOf: function() {return {}}, toString: function() {return "0"}};
if (Number(object) !== 0) {
  $ERROR('#2: var object = {valueOf: function() {return {}}, toString: function() {return "0"}}; Number(object) === 0. Actual: ' + (Number(object)));
}


 }
});
