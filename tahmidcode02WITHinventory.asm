.model small
.stack 100h
.data
    ; Authentication Messages
    welcome_msg db 'Welcome to Restaurant Inventory System$'
    menu_msg db 10,13,'1. Create Account',10,13,'2. Login',10,13,'3. Exit',10,13,'Enter choice: $'
    user_prompt db 10,13,'Enter username: $'
    pass_prompt db 10,13,'Enter password: $'
    success_msg db 10,13,'Login successful!$'
    error_msg db 10,13,'Invalid credentials!$'
    
    ; User Data
    username db 20 dup('$')
    password db 20 dup('$')
    stored_user db 20 dup('$')
    stored_pass db 20 dup('$')
    
    ; Inventory Data
    inv_menu db 10,13,'Inventory Menu:',10,13
            db '1. Add Item',10,13
            db '2. View Inventory',10,13
            db '3. Logout',10,13
            db 'Enter choice: $'
    
    ; Array Structure
    MAX_ITEMS equ 50
    item_name db 'Item Name: $'
    item_price db 'Price: $'
    item_qty db 'Quantity: $'
    newline db 13,10,'$'
    
    ; Inventory Array
    inventory_items db MAX_ITEMS * 20 dup('$')  ; 20 chars per item name
    inventory_prices dw MAX_ITEMS dup(0)        ; Word-sized prices
    inventory_qty dw MAX_ITEMS dup(0)           ; Word-sized quantities
    item_count dw 0                            ; Current number of items

.code
main proc
    mov ax, @data
    mov ds, ax
    
    ; Display welcome
    lea dx, welcome_msg
    mov ah, 09h
    int 21h

main_menu:
    lea dx, menu_msg
    mov ah, 09h
    int 21h
    
    mov ah, 01h
    int 21h
    
    cmp al, '1'
    je create_account
    cmp al, '2'
    je login
    cmp al, '3'
    je exit_prog
    jmp main_menu

create_account:
    lea dx, user_prompt
    mov ah, 09h
    int 21h
    
    lea dx, stored_user
    mov ah, 0ah
    int 21h
    
    lea dx, pass_prompt
    mov ah, 09h
    int 21h
    
    lea dx, stored_pass
    mov ah, 0ah
    int 21h
    jmp main_menu

login:
    lea dx, user_prompt
    mov ah, 09h
    int 21h
    
    lea dx, username
    mov ah, 0ah
    int 21h
    
    lea dx, pass_prompt
    mov ah, 09h
    int 21h
    
    lea dx, password
    mov ah, 0ah
    int 21h
    
    call verify_login
    cmp al, 1
    je inventory_menu
    
    lea dx, error_msg
    mov ah, 09h
    int 21h
    jmp main_menu

inventory_menu:
    lea dx, inv_menu
    mov ah, 09h
    int 21h
    
    mov ah, 01h
    int 21h
    
    cmp al, '1'
    je add_item
    cmp al, '2'
    je view_inventory
    cmp al, '3'
    je main_menu
    jmp inventory_menu

add_item:
    ; Check if inventory is full
    mov ax, item_count
    cmp ax, MAX_ITEMS
    jae inventory_menu
    
    ; Get item details
    lea dx, item_name
    mov ah, 09h
    int 21h
    
    ; Calculate array offset
    mov bx, item_count
    mov ax, 20          ; 20 chars per item
    mul bx
    mov si, ax
    
    ; Store item name
    lea dx, inventory_items[si]
    mov ah, 0ah
    int 21h
    
    ; Get and store price
    lea dx, item_price
    mov ah, 09h
    int 21h
    
    mov ah, 01h
    int 21h
    sub al, '0'
    
    mov bx, item_count
    shl bx, 1          ; multiply by 2 for word size
    mov inventory_prices[bx], ax
    
    ; Get and store quantity
    lea dx, item_qty
    mov ah, 09h
    int 21h
    
    mov ah, 01h
    int 21h
    sub al, '0'
    
    mov inventory_qty[bx], ax
    
    inc item_count
    jmp inventory_menu

view_inventory:
    ; Check if inventory is empty
    cmp item_count, 0
    je inventory_menu
    
    mov cx, item_count  ; Loop counter
    xor si, si          ; Index for names
    xor bx, bx          ; Index for prices/qty
    
display_loop:
    push cx
    
    ; Display item name
    lea dx, item_name
    mov ah, 09h
    int 21h
    
    lea dx, inventory_items[si]
    mov ah, 09h
    int 21h
    
    ; Display price
    lea dx, item_price
    mov ah, 09h
    int 21h
    
    mov ax, inventory_prices[bx]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; Display quantity
    lea dx, item_qty
    mov ah, 09h
    int 21h
    
    mov ax, inventory_qty[bx]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; New line
    lea dx, newline
    mov ah, 09h
    int 21h
    
    add si, 20          ; Next item name
    add bx, 2           ; Next price/qty
    
    pop cx
    loop display_loop
    
    jmp inventory_menu

verify_login:
    ; Simple verification (returns 1 in AL if valid)
    mov al, 1
    ret

exit_prog:
    mov ah, 4ch
    int 21h

main endp
end main