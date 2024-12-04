program HelloWorld;
uses crt;
type
   grid = array [1..140] of string;
var
   a: integer;
   g: grid;
   s: string;
   lineno: integer;
   startx, starty, dirx, diry, dist, realx, realy: integer;
   count: integer;
   ok : boolean;
(* Here the main program block starts *)
begin
   writeln('Hello, World!');
   for lineno := 1 to 140 do
   begin
      readln(s);
      g[lineno] := s;
   end;
   count := 0;
   for startx := 1 to 140 do
      for starty := 1 to 140 do
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
                  writeln('found', startx, ' ', starty, ' ', dirx, ' ', diry);
                  count := count + 1;
                  writeln(count);
               end;
            end;
   writeln(count);
end.
