program sol1
implicit none

   !real, dimension(100) :: p, q
   character(len=20001) :: rawinput
   integer :: input(20001)
   integer(8) :: i, j, x, y, z, total, pos, endpos

   ! comment
   open (1, file = 'input', status = 'old')

   read (1,*) rawinput
   do i = 1,20001   !comment at end of line
      if (rawinput(i:i) == ' ') exit
      input(i) = iachar(rawinput(i:i)) - iachar('0')
      write(*,*) i, input(i)
      !write(*,*) p(i)
   end do
   endpos = i - 1
   write (*,*) i
   total = 0
   pos = 0
   do j = 1,i-1
      if (mod(j, 2) == 1) then
         y = (j - 1) / 2 * (((pos + input(j)) * (pos + input(j) - 1)) / 2 - (pos * (pos - 1)) / 2)
         total = total + y
         !write(*,*) "adding length", input(j), "of", (j - 1) / 2, "makes", y
         pos = pos + input(j)
      else
         !write (*,*) "foo", endpos
         do
            !write(*,*) "endpos", endpos, input(endpos)
            if (endpos < j) exit
            if (input(j) == 0) exit
            if (input(endpos) > 0) then
               x = min(input(j), input(endpos))
               !write(*,*) "endpos", endpos
               !write(*,*) "min of", input(j), "and", input(endpos), "is", x
               input(j) = input(j) - x
               input(endpos) = input(endpos) - x
               y = (endpos - 1) / 2 * (((pos + x - 1) * (pos + x)) / 2 - (pos * (pos - 1)) / 2)
               !write(*,*) ((pos + x - 1) * (pos + x)) / 2, (pos * (pos - 1)) / 2
               total = total + y
               !write(*,*) "adding length", x, "of", (endpos - 1) / 2, "makes", y
               pos = pos + x
            else
               endpos = endpos - 2
            end if
         end do
         pos = pos + input(j)
         if (endpos < j) exit
         !write (*,*) "foo", endpos
      end if
      write(*,*) input(j), total
   end do
   write (*,*) total
   close(1)
end program sol1
