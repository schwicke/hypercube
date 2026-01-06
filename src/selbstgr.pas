Unit selbstgraf;
interface

uses dos,crt,ptccrt,ptcgraph;

var altmode:integer;
    orenable:boolean;

procedure graphmode;
procedure textmode;
procedure setrgb(nr,r,g,b:integer);
procedure save(name:string);
procedure load(name:string);
procedure initcolor;
procedure linexy(x1,y1,x2,y2:word;c:byte);

implementation

procedure graphmode;    {800X600 bei 256 aus 256k}
var  gd, gm, ret: integer;

begin
  gd := D8bit;
  gm := m640x480;
  initgraph(gd, gm, 'graphics');
  ret := graphresult();
  if ret <> grOK then
  begin
    write(grapherrormsg(ret));
    halt;
  end;
end;

procedure textmode;
begin
   closegraph();
end;

procedure setrgb(nr,r,g,b:smallint);
begin
   SetRGBPalette(nr,r,g,b);
end;

procedure initcolor;
var r,g,b,ri,gi,bi,index:smallint;
begin
   for r:=0 to 7 do
   begin
      ri:=9*r;
      for g:=0 to 7 do
      begin
	 gi:=9*g;
	 for b:=0 to 3 do
	 begin
	    bi:=21*b;
	    index:=(r shl 3 or g) shl 2 or b;
	    writeln(index);
	    writeln(ri,gi,bi);
	    setrgb(index,ri,gi,bi);
	 end;
      end;
   end;
end;

procedure save(name:string);
var f:file of char;
   x,y,b:integer;
   c:char;
begin
   assign(f,name);
   rewrite(f);
   for y:=0 to 599 do
      for x:=0 to 799 do
      begin
	 b:=getpixel(x,y);
	 c:=chr(b);
	 write(f,c);
      end;
   close(f);
end;

procedure load(name:string);
var f:file of char;
   x,y:integer;
   ch:char;
   c:byte;
begin
   assign(f,name);
   reset(f);
   for y:=0 to 599 do
      for x:=0 to 799 do
      begin
	 read(f,ch);
	 c:=ord(ch);
	 putpixel(x,y,c);
      end;
   close(f);
end;

procedure linexy(x1,y1,x2,y2:word;c:byte);
var x,y,dx,dy,s1,s2,d,t,i1,i2,i:integer;

function sgn(a:integer):integer;
begin
   sgn:=-1;
   if a>0 then sgn:=1 else if a=0 then sgn:=0;
end;

begin
   x:=x1;
   y:=y1;
   dx:=abs(x2-x1);
   dy:=abs(y2-y1);
   s1:=sgn(x2-x1);
   s2:=sgn(y2-y1);
   if dx<dy then
   begin
      d:=dx;
      dx:=dy;
      dy:=d;
      t:=1;
   end
   else t:=0;
   d:=dy shl 1 -dx;
   i1:=dy shl 1;
   i2:=dx shl 1 ;
   for i:=1 to dx do
   begin
      putpixel(x,y,c);
      while d>=0 do
      begin
	 if t=1 then inc(x,s1) else inc(y,s2);
	 d:=d-i2
      end;
      if t=1 then inc(y,s2) else inc(x,s1);
      d:=d+i1;
   end;
end;

begin
 orenable:=false;
end.


