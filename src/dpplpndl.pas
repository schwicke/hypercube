program doppelpendel;

uses cthreads,crt,ptccrt,ptcgraph, selbstgraf;

const xm=320;
      ym=200;
      g=9.81;
      h=0.01;
      h2=0.01;

var x1a,y1a,x2a,y2a:integer;
    c:char;
    m1,m2,l1,l2,m,l1l2:real;
    f1,f2,w1,w2:real;

procedure funk(f1,f2,w1,w2:real;var w1n,w2n,fx,gx:real);
var sn,cs,df    : real;
    t1,t2,t3,t4 : real;
    g1,g2,g3,g4 : real;

begin
 w1n:=w1;
 w2n:=w2;
 df:=f1-f2;
 sn:=sin(df);cs:=cos(df);
 t1:=m1*l2*w1*w2*sn/(l1*m);
 t2:=g*sin(f1)/l1;
 t3:=cs*(l1*sqr(w1)*sn-g*sin(f2))/(m*l1l2);
 t4:=1+sqr(cs)/(m*l2);
 fx:=-(t1+t2+t3)/t4;
 g1:=(l1*sqr(w1)*sn-g*sin(f2))/l2;
 g2:=m2/m*w1*w2*cs*sn;
 g3:=g/l2*sin(f1)*cs;
 g4:=1+l1/l2*sqr(cs)*m2/m;
 gx:=(g1+g2+g3)/g4;

end;

procedure malen(x1,y1,x2,y2:integer);
begin
 {altes l”schen, neues zeichnen}
 setcolor(black);
 line(x1a,y1a,x2a,y2a);
 line(xm,ym,x1a,y1a);
 setfillstyle(1,black);
{ fillellipse(x1a,y1a,8,8);
 fillellipse(x2a,y2a,8,8);
} setcolor(yellow);
 line(xm,ym,x1,y1);
 line(x1,y1,x2,y2);
 setcolor(red);
 setfillstyle(1,red);
{ fillellipse(x1,y1,8,8);
 fillellipse(x2,y2,8,8);
} x1a:=x1;x2a:=x2;
 y1a:=y1;y2a:=y2;
end;


procedure iterstep(var f1,f2,w1,w2:real);
var k11,k12,k13,k14,
    k21,k22,k23,k24,
    k31,k32,k33,k34,
    k41,k42,k43,k44   :real;
begin
 {K1:}
    funk(f1,f2,w1,w2,k11,k12,k13,k14);
 {k2:}
    funk(f1+h2*k11,f2+h2*k12,w1+h2*k13,w2+h2*k14,k21,k22,k23,k24);
 {k3:}
    funk(f1+h2*k21,f2+h2*k22,w1+h2*k23,w2+h2*k24,k31,k32,k33,k34);
 {k4:}
    funk(f1+h*k31,f2+h*k32,w1+h*k33,w2+h*k34,k41,k42,k43,k44);
 f1:=f1+h*(k11+2*k21+2*k31+k41)/6;
 f2:=f2+h*(k12+2*k22+2*k32+k42)/6;
 w1:=w1+h*(k13+2*k23+2*k33+k43)/6;
 w2:=w2+h*(k14+2*k24+2*k34+k44)/6;
end;

procedure kalcnpos(var f1,f2,w1,w2:real);
var sn,cs:real;
    ix1,iy1,ix2,iy2:integer;
begin
 sn:=sin(f1);cs:=cos(f1);
 ix1:=xm+round(l1*sn);
 iy1:=ym+round(l1*cs);
 ix2:=ix1+round(l2*sin(f2));
 iy2:=iy1+round(l2*cos(f2));
 malen(ix1,iy1,ix2,iy2);
 iterstep(f1,f2,w1,w2);
end;

begin
   x1a:=0;x2a:=0;y1a:=0;y2a:=0;
   m1:=100;m2:=1;l1:=100;l2:=100;
   m:=m1+m2;l1l2:=l1*l2;
   f1:=-1;f2:=3;w1:=0.0;w2:=0;
   mygraphmode();
   repeat
      if keypressed then c:=readkey;
      kalcnpos(f1,f2,w1,w2);
      delay(10);
   until c=chr(27);
   mytextmode;
end.
