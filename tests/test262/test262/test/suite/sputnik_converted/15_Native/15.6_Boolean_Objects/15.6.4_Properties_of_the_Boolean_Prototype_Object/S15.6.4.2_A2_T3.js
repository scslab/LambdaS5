// Copyright 2009 the Sputnik authors.  All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/**
 * @name: S15.6.4.2_A2_T3;
 * @section: 15.6.4.2;
 * @assertion: The toString function is not generic, it cannot be transferred 
 * to other kinds of objects for use as a method and there is should be 
 * a TypeError exception if its this value is not a Boolean object;
 * @description: transferring to the Date objects;
*/


// Converted for Test262 from original Sputnik source

ES5Harness.registerTest( {
id: "S15.6.4.2_A2_T3",

path: "15_Native\15.6_Boolean_Objects\15.6.4_Properties_of_the_Boolean_Prototype_Object\S15.6.4.2_A2_T3.js",

assertion: "The toString function is not generic, it cannot be transferred",

description: "transferring to the Date objects",

test: function testcase() {
   //CHECK#1
try{
  var s1 = new Date();
  s1.toString = Boolean.prototype.toString;
  var v1 = s1.toString(); 
  $ERROR('#1: Boolean.prototype.toString on not a Boolean object should throw TypeError');
}
catch(e){
  if(!(e instanceof TypeError)){
    $ERROR('#1: Boolean.prototype.toString on not a Boolean object should throw TypeError, not '+e);
  }
}

//CHECK#1
try{
  var s2 = new Date();
  s2.myToString = Boolean.prototype.toString;
  var v2 = s2.myToString(); 
  $ERROR('#2: Boolean.prototype.toString on not a Boolean object should throw TypeError');
}
catch(e){
  if(!(e instanceof TypeError)){
    $ERROR('#2: Boolean.prototype.toString on not a Boolean object should throw TypeError, not '+e);
  }
}


 }
});
