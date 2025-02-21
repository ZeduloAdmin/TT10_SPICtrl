Nano SPI device - takes SPI input and allows read/write of IO pins and SRAM registero.

All SPI commands are 4 bit long, arg is 4 bits
        CMD:    ARG:            Definition:
        STATUS  field           Returns status for the specific field
        SET     IO pin          Sets the specified output pin
        CLEAR   IO pin          Clears the specified output pin
        TARGET  reg/addr/io     Specify the target for read/write operations
        WRITE   data            Writes to the set target
        READ    n/a             Reads from the set target

CMD_STATUS 4'h0
CMD_SET 4'h1
CMD_CLEAR 4'h2
CMD_TARGET 4'h3
CMD_WRITE 4'h4
CMD_READ 4'h5
