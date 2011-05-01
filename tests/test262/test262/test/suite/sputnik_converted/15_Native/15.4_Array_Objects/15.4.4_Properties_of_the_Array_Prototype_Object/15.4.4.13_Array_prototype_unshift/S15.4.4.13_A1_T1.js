// Copyright 2009 the Sputnik authors.  All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/**
 * @name: S15.4.4.13_A1_T1;
 * @section: 15.4.4.13;
 * @assertion: The arguments are prepended to the start of the array, such that 
 * their order within the array is the same as the order in which they appear in 
 * the argument list;
 * @description: Checking case when unsift is given no arguments or one argument;
*/


// Converted for Test262 from original Sputnik source

ES5Harness.registerTest( {
id: "S15.4.4.13_A1_T1",

path: "15_Native\15.4_Array_Objects\15.4.4_Properties_of_the_Array_Prototype_Object\15.4.4.13_Array_prototype_unshift\S15.4.4.13_A1_T1.js",

assertion: "The arguments are prepended to the start of the array, such that",

description: "Checking case when unsift is given no arguments or one argument",

test: function testcase() {
   //CHECK#1
var x = new Array();
var unshift = x.unshift(1);
if (unshift !== 1) {
  $ERROR('#1: x = new Array(); x.unshift(1) === 1. Actual: ' + (unshift));
}  

//CHECK#2
if (x[0] !== 1) {
  $ERROR('#2: x = new Array(); x.unshift(1); x[0] === 1. Actual: ' + (x[0]));
}

//CHECK#3
var unshift = x.unshift();
if (unshift !== 1) {
  $ERROR('#3: x = new Array(); x.unshift(1); x.unshift() === 1. Actual: ' + (unshift));
}

//CHECK#4
if (x[1] !== undefined) {
  $ERROR('#4: x = new Array(); x.unshift(1); x.unshift(); x[1] === unedfined. Actual: ' + (x[1]));
}

//CHECK#5
var unshift = x.unshift(-1);
if (unshift !== 2) {
  $ERROR('#5: x = new Array(); x.unshift(1); x.unshift(); x.unshift(-1) === 2. Actual: ' + (unshift));
}

//CHECK#6
if (x[0] !== -1) {
  $ERROR('#6: x = new Array(); x.unshift(1); x.unshift(-1); x[0] === -1. Actual: ' + (x[0]));
}

//CHECK#7
if (x[1] !== 1) {
  $ERROR('#7: x = new Array(); x.unshift(1); x.unshift(-1); x[1] === 1. Actual: ' + (x[1]));
}

//CHECK#8
if (x.length !== 2) {
  $ERROR('#8: x = new Array(); x.unshift(1); x.unshift(); x.unshift(-1); x.length === 2. Actual: ' + (x.length));
} 

 }
});
