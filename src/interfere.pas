program interfere;
{g+}
uses cthreads,dos,crt, ptccrt,ptcgraph, selbstgraf;

type zent=^zentrum;
     zentrum=record
              x,y:integer;
              a0:integer;  {amplitude}
              om:real;
              wtr:zent;
             end;
var wurzel:zent;
    n:integer;   {number}
    t:real;
    amax:integer;

procedure eingabe;
var h:zent;
    i:integer;

procedure lies(var x,y,a0:integer;var lam:real);
begin
 writeln('x and y-coordinates of the center:');
 readln(x,y);
 writeln('amplitude:');
 readln(a0);
 writeln('wavelength');
 readln(lam);lam:=2*pi/lam; {(c=1)}
end;

begin
 new(wurzel);
 h:=wurzel;
 h^.wtr:=nil;
 writeln('Number of centers');
 repeat readln(n); until n>=1;
 writeln('Time passed:');
 readln(t);
 lies(h^.x,h^.y,h^.a0,h^.om);
 i:=1;
 amax:=h^.a0;
 while i<n do
 begin
  i:=i+1;
  writeln;
    writeln('Center number: ',i);
  new(h^.wtr);h:=h^.wtr;h^.wtr:=nil;
  lies(h^.x,h^.y,h^.a0,h^.om);
  amax:=amax+h^.a0;
 end;
end;

procedure calc;
var x,y,c:integer;
    dist:real;
    h:zent;
    a,d1,d2:real;
begin
 for y:=0 to 599 do
 for x:=0 to 799 do
 begin
  h:=wurzel;
  d1:=x-h^.x;d2:=y-h^.y;
  dist:=sqrt(sqr(d1)+sqr(d2));
  a:=h^.a0*sin(h^.om*dist-h^.om*t);         {k*x-om*t mit k=om/c}
  while h^.wtr<>nil do
  begin
   h:=h^.wtr;
   d1:=x-h^.x;d2:=y-h^.y;
   dist:=sqrt(sqr(d1)+sqr(d2));
   a:=a+h^.a0*sin(h^.om*dist-h^.om*t);         {k*x-om*t mit k=om/c}
  end;
  c:=round((a/amax+1)*28+4);if c>63 then c:=63;
  putpixel(x,y,c);
 end;
end;

procedure paint;
var i:integer;
begin
 mygraphmode;
 for i:=0 to 63 do setrgb(i,i,i,i);
 calc;
 readln;
 mytextmode;
end;

begin
 wurzel:=nil;
 eingabe;
 paint;
end.
