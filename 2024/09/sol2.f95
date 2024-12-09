program sol2
implicit none

   !real, dimension(100) :: p, q
   character(len=20001) :: rawinput
   integer :: input(20001)
   integer(8) :: i, j, x, y, z, total, pos, endpos, totalsize, startp, endp
   integer :: nexts(9)
   integer :: nextposs(9)
   integer :: filledamount(20001)

   ! comment
   open (1, file = 'input', status = 'old')

   totalsize = 0
   read (1,*) rawinput
   do i = 1,20001   !comment at end of line
      if (rawinput(i:i) == ' ') exit
      input(i) = iachar(rawinput(i:i)) - iachar('0')
      totalsize = totalsize + input(i)
      filledamount(i) = 0
      !write(*,*) i, input(i)
      !write(*,*) p(i)
   end do
   
   do j = 1,9
      nexts(j) = 2
      nextposs(j) = input(1)
   end do

   endpos = i - 1
   write (*,*) i
   total = 0
   do j = i - 1, 2, -2
      x = input(j)
      do
         if (input(nexts(x)) - filledamount(nexts(x)) >= x) then
            filledamount(j) = x
            startp = nextposs(x) + filledamount(nexts(x))
            endp = startp + x
            y = (j - 1) / 2 * ((endp * (endp - 1)) / 2 - (startp * (startp - 1)) / 2)
            total = total + y
            filledamount(nexts(x)) = filledamount(nexts(x)) + x
            !write(*,*) "adding length", input(j), "of", (j - 1) / 2, "at", startp, "makes", y
            exit
         else
            if (nexts(x) + 2 > j) then
               !write(*,*) "cannot compact", (j-1)/2
               exit
            end if
            nextposs(x) = nextposs(x) + input(nexts(x)) + input(nexts(x) + 1)
            nexts(x) = nexts(x) + 2
         end if
      end do
   end do
   pos = 0
   do j = 1, i - 1
      if (mod(j, 2) == 1 .and. filledamount(j) == 0) then
         startp = pos
         endp = pos + input(j)
         y = (j - 1) / 2 * ((endp * (endp - 1)) / 2 - (startp * (startp - 1)) / 2)
         !write(*,*) "adding length", input(j), "of", (j - 1) / 2, "at", startp, "makes", y
         total = total + y
      end if
      pos = pos + input(j)
   end do
   write (*,*) total
   close(1)
end program sol2
