; $Id: push.pro,v 1.1 2002/09/05 17:15:02 jpmorgen Exp $

; push  Uses an IDL array to emulate a stack.  null (0 by default) is
; the value used to indicate the end of the stack

pro push, value, stack, null=null

  nx=N_elements(stack)

  if nx eq 0 then message, 'ERROR: stack must be an existing array initialized to 0 or your choice of null'
  if NOT keyword_set(null) then null=0

  if stack[nx-1] NE null then message, 'WARNING: stack overflow', /CONTINUE

  stack[1:nx-1] = stack[0:nx-2]
  stack[0] = value

  return
end
