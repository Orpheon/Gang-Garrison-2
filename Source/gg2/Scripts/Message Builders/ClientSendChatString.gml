//argument0 = buffer; argument1 = the string

write_ubyte(argument0, OHU_CHAT)
write_ubyte(argument0, string_length(argument1))
write_string(argument0, argument1)
