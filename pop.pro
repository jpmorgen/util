; $Id: pop.pro,v 1.1 2002/09/05 17:14:57 jpmorgen Exp $

; pop  Uses an IDL array to emulate a stack.  null (0 by default) is
; the value used to indicate the end of the stack

function pop, stack, null=null

  nx=N_elements(stack)

  if nx eq 0 then message, 'ERROR: stack must be an existing array initialized to 0 or your choice of null'
  if NOT keyword_set(null) then null=0

  nx=N_elements(stack)
  if stack[0] EQ null then message, 'WARNING: trying to pop an empty stack', /CONTINUE

  value = stack[0]
  stack[0:nx-2] = stack[1:nx-1]
  stack[nx-1] = null

  return, value
end
