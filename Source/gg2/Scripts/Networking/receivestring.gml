/* Read a string with a length prefix.

argument0 = buffer
*/

var length, result;

length = read_ubyte(argument0)

result = read_string(argument0, length)

return result
