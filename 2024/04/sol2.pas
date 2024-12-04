program HelloWorld;
uses crt;
type
   grid = array [1..140] of string;
var
   a: integer;
   g: grid;
   s: string;
   lineno: integer;
   startx, starty, dirx, diry, dist, realx, realy, realx2, realy2: integer;
   count, count2: integer;
   ok : boolean;
   l : integer;
(* Here the main program block starts *)
begin
   writeln('Hello, World!');
   l := 0;
   for lineno := 1 to 140 do
   begin
      readln(s);
      if (s = '') then
         break;
      l := l + 1;
      g[lineno] := s;
   end;
   writeln(l);
   count := 0;
   count2 := 0;
   for startx := 1 to l do
      for starty := 1 to l do
      begin
         for dirx := -1 to 1 do
            for diry := -1 to 1 do
            begin
               if ((dirx = 0) and (diry = 0)) then
                  continue;
               ok := true;
               for dist := 0 to 3 do
               begin
                  realx := startx + dirx * dist;
                  realy := starty + diry * dist;
                  if ((realx < 1) or (realx > 140) or (realy < 1) or (realy > 140)) then
                  begin
                     ok := false;
                     break;
                  end;
                  if ('XMAS'[dist+1] <> g[realx][realy]) then
                  begin
                     ok := false;
                     break;
                  end;
               end;
               if ok then
               begin
                  count := count + 1;
               end;
            end;
         for dirx := -1 to 1 do
         begin
            if (dirx = 0) then
               continue;
            for diry := -1 to 1 do
            begin
               if (diry = 0) then
                  continue;
               ok := true;
               if ((startx < 2) or (startx >= l) or (starty < 2) or (starty >= l)) then
               begin
                  writeln('startx ', startx, ' starty ', starty, ' l ', l);
                  continue;
               end;
               for dist := -1 to 1 do
               begin
                  realx := startx + dirx * dist;
                  realy := starty + dirx * dist;
                  realx2 := startx + diry * dist;
                  realy2 := starty - diry * dist;
                  if ('MAS'[dist+2] <> g[realx][realy]) then
                  begin
                     writeln('dropped1 ', startx, ' ', starty, ' ', realx, ' ', realy, ' ', dist);
                     writeln('MAS'[dist+2], g[realx][realy]);
                     ok := false;
                     break;
                  end;
                  if ('MAS'[dist+2] <> g[realx2][realy2]) then
                  begin
                     writeln('dropped2 ', startx, ' ', starty, ' ', realx2, ' ', realy2, ' ', dist);
                     writeln('MAS'[dist+2], g[realx2][realy2]);
                     ok := false;
                     break;
                  end;
               end;
               if ok then
               begin
                  writeln('found', startx, ' ', starty, ' ', dirx, ' ', diry);
                  count2 := count2 + 1;
                  writeln(count2);
               end;
            end;
         end;
      end;
   writeln(count);
   writeln(count2);
end.
