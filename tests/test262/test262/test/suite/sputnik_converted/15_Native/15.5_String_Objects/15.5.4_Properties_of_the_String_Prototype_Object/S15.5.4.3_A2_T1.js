// Copyright 2009 the Sputnik authors.  All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/**
* @name: S15.5.4.3_A2_T1;
* @section: 15.5.4.3;
* @assertion: The valueOf function is not generic; it throws a TypeError exception if its this value is not a String object. 
* Therefore, it cannot be transferred to other kinds of objects for use as a method;
* @description: Checking if creating variable String.prototype.valueOf fails;
*/


// Converted for Test262 from original Sputnik source

ES5Harness.registerTest( {
id: "S15.5.4.3_A2_T1",

path: "15_Native\15.5_String_Objects\15.5.4_Properties_of_the_String_Prototype_Object\S15.5.4.3_A2_T1.js",

assertion: "The valueOf function is not generic; it throws a TypeError exception if its this value is not a String object.",

description: "Checking if creating variable String.prototype.valueOf fails",

test: function testcase() {
   var __valueOf = String.prototype.valueOf;

//////////////////////////////////////////////////////////////////////////////
//CHECK#1
if (typeof __valueOf !== "function") {
  $ERROR('#1: __valueOf = String.prototype.valueOf; typeof __valueOf === "function". Actual: typeof __valueOf ==='+typeof __valueOf ); 
}

//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//CHECK#2
try {
  var x = __valueOf();
  $FAIL('#2: "__valueOf = String.prototype.valueOf; var x = __valueOf()" lead to throwing exception');
} catch (e) {
  if (!(e instanceof TypeError)) {
    $ERROR('#2.1: Exception is instance of TypeError. Actual: exception is '+e);
  }
}
//
//////////////////////////////////////////////////////////////////////////////

 }
});
