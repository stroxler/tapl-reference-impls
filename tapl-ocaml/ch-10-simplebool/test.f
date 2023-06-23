/* Examples for testing */

bool_func: Bool->Bool;

bool_func true;

 lambda x:Bool. x;
 (lambda x:Bool->Bool. if x false then true else false) 
   (lambda x:Bool. if x then false else true); 
