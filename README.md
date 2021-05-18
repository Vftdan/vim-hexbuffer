# Vim hex buffer

## Why not 'fidian/hexmode'?
 * My plugin does not automatically convert binary buffers to hexadecimal
 * Saving hexadecimal buffer does not change anything on the disk

## Usage
 1. Create/open the file you want to edit (binary mode is recommended)
 2. Split the window or set `bufhidden=hide` or set `hidden=on` to prevent buffer unloading (important!)
 3. Run `:ToHexBuffer` command
 4. Make the changes in the hexadecimal buffer
 5. Save the buffer (`:w`)

Buffer with the original file should update after hexadecimal buffer saving.

## Dependencies
 * `xxd` (shipped with regular Vim)
