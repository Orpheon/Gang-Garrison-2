// argument0=buffer; argument1=the player ID; argument2=string to send

write_ubyte(argument0, OHU_CHAT)
write_ubyte(argument0, argument1)
write_ubyte(argument0, string_length(argument2))
write_string(argument0, argument2)
