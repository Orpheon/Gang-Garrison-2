//argument0=buffer; argument1=string

write_ubyte(argument0, OHU_RCON_COMMAND)
write_ubyte(argument0, string_length(argument1))
write_string(argument0, argument1)
