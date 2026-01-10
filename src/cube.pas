program wuerfel;
{g+}
uses cthreads,crt,ptccrt,ptcgraph,drei_dim;

{3d projection of N dimensional cubes}

type punkt=array[1..10] of real;
     lst=^liste;
     vrb=^verb;
     liste=record
            nr:integer;
            wtr:lst;
            p:punkt;
           end;
     verb=record
            wtr:vrb;
            p1,p2:integer;
            vp1,vp2:lst;
            x1,y1,x2,y2:real;
           end;

var pnkte:lst;
    vrsch,alt1,alt2:vrb;
    modus:boolean;

    n:integer;
    error:integer;
    c:char;
    farbe,rot,blau:word;
    d,s,fx,fy,fz:real;
    sn,cs:real;
    txt:string;
    gd, gm: integer;

function search(nr:integer):lst;
var h1:lst;
begin
 h1:=pnkte;
 while (h1<>nil)and(h1^.nr<>nr) do h1:=h1^.wtr;
 search:=h1;
end;

function zweihoch(x:integer):integer;
var i,y:integer;

begin
 y:=1;
 for i:=1 to x do y:=y*2;
 zweihoch:=y;
end;

procedure proj(flucht:boolean);
{projection on x,y  plane}
var v1:vrb;
   c1,c2,dx1,dy1,dz1,dx2,dy2,dz2:real;
begin
   v1:=vrsch;
   while v1<>nil do
   begin
      if v1^.vp1=nil then v1^.vp1:=search(v1^.p1);
      if v1^.vp2=nil then v1^.vp2:=search(v1^.p2);

      if flucht then
      begin
	 dx1:=v1^.vp1^.p[1]-fx;
	 dy1:=v1^.vp1^.p[2]-fy;
	 dz1:=v1^.vp1^.p[3]-fz;
	 dx2:=v1^.vp2^.p[1]-fx;
	 dy2:=v1^.vp2^.p[2]-fy;
	 dz2:=v1^.vp2^.p[3]-fz;
	 c1:=(s-v1^.vp1^.p[3])/dz1;
	 c2:=(s-v1^.vp2^.p[3])/dz2;
      end
   else begin
      c1:=0;c2:=0;
      dx1:=0;dx2:=0;
      dy1:=0;dy2:=0;
   end;

      v1^.x1:=(v1^.vp1^.p[1])-c1*dx1;{Projektion}
      v1^.y1:=(v1^.vp1^.p[2])-c1*dy1;
      v1^.x2:=v1^.vp2^.p[1]-c2*dx2;
      v1^.y2:=v1^.vp2^.p[2]-c2*dy2;
      v1:=v1^.wtr;
   end;
end;

procedure create(n:integer);
var i,j,k:integer;
    w1,h1,h2:lst;
    v1,v2,w2:vrb;


begin
   pnkte:=nil;
   vrsch:=nil;
   new(pnkte);
   new(vrsch);
   vrsch^.x1:=0;vrsch^.x2:=0;vrsch^.y1:=0;vrsch^.y2:=0;
   vrsch^.p1:=1;vrsch^.p2:=1;
   pnkte^.wtr:=nil;
   pnkte^.nr:=1;
   vrsch^.wtr:=nil;vrsch^.vp1:=nil;vrsch^.vp2:=nil;
   for i:=1 to n do pnkte^.p[i]:=0;{nullpunkt als Ausgangspunkt}
   for j:=1 to n do {dimension}
   begin

{Verbindungsvorschrift fÅr neue Punkte}
      v1:=vrsch;
      if v1<>nil then
      begin
	 new(w2);
	 v2:=w2;
	 w2^.wtr:=nil;
	 w2^.vp1:=nil;w2^.vp2:=nil;
      end;
      while v1<>nil do
      begin
	 v2^.p1:=(v1^.p1+zweihoch(j-1));
	 v2^.p2:=(v1^.p2+zweihoch(j-1));
	 v1:=v1^.wtr;
	 if v1<>nil then
	 begin
	    new(v2^.wtr);
	    v2:=v2^.wtr;
	    v2^.wtr:=nil;
	    v2^.vp1:=nil;
	    v2^.vp2:=nil;
	 end;
      end;
      v1:=vrsch^.wtr;
      vrsch:=w2;
      v2^.wtr:=v1;
      v1:=vrsch;
      while v1^.wtr<>nil do v1:=v1^.wtr;
      {calculate new points}
      w1:=nil;
      new(w1);
      w1^.wtr:=nil;
      h1:=pnkte;
      h2:=w1;
      {Add: split one point into two}
      while h1<>nil do
      begin
	 new(h2^.wtr);
	 h2^.wtr^.wtr:=nil;
	 {extend into j-direction}
	 for k:=1 to n do
	    if k=j then
	    begin          {move}
	       h2^.p[k]:=100;
	       h2^.wtr^.p[k]:=-100;
	    end
            else
	    begin      {kopieren}
	       h2^.p[k]:=h1^.p[k];
	       h2^.wtr^.p[k]:=h1^.p[k];
	    end;
	 h2^.nr:=h1^.nr;{nummerieren}
	 h2^.wtr^.nr:=h2^.nr+zweihoch(j-1);

	 {extend connection rule}
	 new(v1^.wtr);
	 v1:=v1^.wtr;
	 v1^.wtr:=nil;
	 v1^.vp1:=nil;
	 v1^.vp2:=nil;
	 v1^.p1:=h2^.nr;
	 v1^.p2:=h2^.wtr^.nr; {connect}

	 h2:=h2^.wtr;
	 h1:=h1^.wtr;

	 if h1<>nil then
	 begin
	    new(h2^.wtr);
	    h2:=h2^.wtr;
	    h2^.wtr:=nil;
	 end;
      end; {of while}
      pnkte:=w1;
   end;
   vrsch:=vrsch^.wtr;
   proj(modus);
end;


procedure out(n:integer);
var h:lst;
   i:integer;
begin
   h:=pnkte;
   while h<>nil do
   begin
      writeln('punkt:',h^.nr,' : ');
      for i:=1 to n do write(h^.p[i]:2,',');
      writeln;
      h:=h^.wtr;
   end;
end;

procedure drw(dl:boolean ;vrsch:vrb);
var h:vrb;
   function xkoord(x:real):integer;
   begin
      xkoord:=round(x+320);
   end;

   function ykoord(y:real):integer;
   begin
      ykoord:=round(240-y);
   end;

begin
   h:=vrsch;
   while h<>nil do
   begin
      if dl then setcolor(farbe)
      else setcolor(black);
      line(xkoord(h^.x1),ykoord(h^.y1),xkoord(h^.x2),ykoord(h^.y2));
      h:=h^.wtr;
   end;
end;

procedure rota(sn,cs:real;mo:integer);
{sn,cs are sin(w) and  cos(w), respectively}
{This procedure rotates by an angle,
mo:modus defines the position in the matrix.
where  0 < mo < dim-1}
var h:lst;
   a,b:real;
begin
   h:=pnkte;
   while h<>nil do
   begin
      a:=h^.p[mo];
      b:=h^.p[mo+1];
      h^.p[mo]:=a*cs-b*sn;
      h^.p[mo+1]:=a*sn+b*cs;
      h:=h^.wtr;
   end;
   proj(modus);
end;

procedure ausg(vrsch:vrb);
var h:vrb;
begin
   h:=vrsch;
   while h<>nil do
   begin
      writeln('p1p2',h^.p1,h^.p2,'##',h^.x1,h^.y1,'#',h^.x2,h^.y2);
      h:=h^.wtr;
   end;
end;

function copy(quelle:vrb):vrb;
{copies list}
var nw,hq,hn:vrb;
   procedure make(var feld:vrb);
   begin
      new(feld);
      feld^.wtr:=nil;
      feld^.vp1:=nil;
      feld^.vp2:=nil;
   end;

begin
   hq:=quelle;
   if hq<>nil then
   begin
      make(nw);
      hn:=nw;
   end;
   while hq<>nil do
   begin
      hn^.x1:=hq^.x1;hn^.x2:=hq^.x2;
      hn^.y1:=hq^.y1;hn^.y2:=hq^.y2;
      hn^.p1:=hq^.p1;
      hn^.p2:=hq^.p2;
      hq:=hq^.wtr;
      if hq<>nil then
      begin
	 make(hn^.wtr);
	 hn:=hn^.wtr;
      end;
   end;
   copy:=nw;
end;

procedure update(var ziel,quelle:vrb);
var hz,hq:vrb;
begin
   hz:=ziel;
   hq:=quelle;
   while hq<>nil do
   begin
      hz^.x1:=hq^.x1;
      hz^.x2:=hq^.x2;
      hz^.y1:=hq^.y1;
      hz^.y2:=hq^.y2;
      hq:=hq^.wtr;
      hz:=hz^.wtr;
   end;
end;

procedure wahl(var farbe:word);
var i:integer;
   c:char;
begin
   i:=0;
   repeat
      cleardevice;
      setpalette(farbe,i);
      setcolor(farbe);
      outtextxy(0,0,'Farbe waehlen');
      repeat
	 c:=readkey;
      until c in ['+','-',#27];
      case c of
	'+':i:=i+1;
	'-':i:=i-1;
      end;
   until c=#27;
end;

{main starts here}
begin
   modus:=true;
   sn:=sin(0.01);
   cs:=cos(0.01);
   rot:=4;
   blau:=3;
   s:=50;
   fy:=0;
   fz:=1000;
   d:=60;
   writeln('<,>: Change eye distance, +,- distance of vanishing point');
   writeln('Enter the cubes dimension (e.g. 2, 3, 4, 5, ...):');
   readln(n);
   create(n);
   alt1:=copy(vrsch);
   alt2:=copy(vrsch);
   gd := D8bit;
   gm := m640x480;
   initgraph(gd, gm, 'graphics');
   error := graphresult();
   if error=grok then
   begin
      c:=' ';
      if n>1 then
	 repeat
	    farbe:=rot;
	    fx:=-d;fy:=-2;
	    proj(modus);
	    drw(false,alt1);
	    drw(true,vrsch);
	    update(alt1,vrsch);
	    farbe:=blau;
	    fx:=d;fy:=2;
	    proj(modus);
	    drw(false,alt2);
	    drw(true,vrsch);
	    update(alt2,vrsch);
	    settextstyle(3,horizdir,1);
	    setcolor(yellow);
	    outtextxy(0,0,'Rotate with keys 1..'+chr(n-1+ord('0')));
	    repeat
	       if keypressed then c:=readkey;
	    until c in['+','-','<','>',#27,'1'..chr(ord('1')+n-2)];
	    case c of
	      '<':begin d:=d-0.1;c:=' ';end;
	      '>':begin d:=d+0.1;c:=' ';end;
	      '+':begin fz:=fz-10;c:=' ';end;
	      '-':begin fz:=fz+10;c:=' ';end;
	    end;
	    rota(sn,cs,1+ord(c)-ord('1'));
            delay(word(round(100/n)));
	 until c=chr(27);
   end
   else
   begin
      restorecrtmode;txt:=grapherrormsg(error);
      writeln('Fehler:',txt);
      readln;
      writeln(red,green);
   end;
end.


