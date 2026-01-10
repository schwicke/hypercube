Unit drei_dim;
{g+}

interface

uses crt,dos,ptccrt,ptcgraph,selbstgraf;

const xmax=800;
   ymax=600;
   dx=0.00001;

type vek=record
	    x,y,z:real;
	 end;


var Fluchtpunkt,brennpunkt,
   VUP, VRP, NRP, VRPs, xdach, ydach,
   vrpr, nrpr, fpr,
   vrpl, nrpl, fpl: vek;
   Augdist, brennweite, fluchtweite, bldlang, bldhoch: real;
   Fluchtdarst, rgenable: Boolean;

{declarations}
function calcproj(op:vek;var ox:vek):boolean; {projects point op to  Punkt op to viewport level ox}
procedure initproj;
procedure initrg;
procedure calcflucht;
procedure rgmode;
procedure normmode;
procedure put3dpixel(op:vek;color:byte);
function  absvek(op:vek):real;
procedure normvek(var op:vek);
function  calcline3d(op1,op2:vek;var ox1,ox2:vek):boolean;
procedure line3d(op1,op2:vek;farbe:byte);
procedure line2d(ox1,ox2:vek;farbe:byte);
procedure rotx(var ox:vek;a:real);
procedure roty(var ox:vek;a:real);
procedure rotz(var ox:vek;a:real);


implementation

function absvek(op:vek):real;
begin
   absvek:=sqrt(sqr(op.x)+sqr(op.y)+sqr(op.z));
end;

procedure normvek(var op:vek);
var b:real;
begin
   b:=absvek(op);
   op.x:=op.x/b;
   op.y:=op.y/b;
   op.z:=op.z/b;
end;

procedure calcflucht;
begin
   fluchtpunkt.x:=vrp.x+fluchtweite*nrp.x;
   fluchtpunkt.y:=vrp.y+fluchtweite*nrp.y;
   fluchtpunkt.z:=vrp.z+fluchtweite*nrp.z;
end;

procedure line2d(ox1,ox2:vek;farbe:byte);
var ix1,ix2,iy1,iy2:integer;
   unsicht,b1,b2:boolean;
   x1x2,x1,x2:vek;

   function prop1(x:real):real;
   begin
      x1x2.x:=x2.x-x1.x;
      x1x2.y:=x2.y-x1.y;
      if x1x2.x=0 then begin unsicht:=true;prop1:=0;end
   else prop1:=(x-x2.x)*x1x2.y/x1x2.x+x2.y;
   end;

   function prop2(y:real):real;
   begin
      x1x2.x:=x2.x-x1.x;
      x1x2.y:=x2.y-x1.y;
      if x1x2.y=0 then begin unsicht:=true;prop2:=0;end
   else prop2:=(y-x2.y)*x1x2.x/x1x2.y+x2.x;
   end;

begin
   x1:=ox1;x2:=ox2;
   unsicht:=false;
   {clipping on viewport limits}

   {1. clipping x1 --> ox1}

   b1:=x1.x<=-bldlang/2;
   b2:=x1.x>= bldlang/2;
   if b1 or b2 then
   begin                              {x-Clipping von x1}
      if b1 then ox1.x:=-0.5*bldlang else ox1.x:=0.5*bldlang;
      ox1.y:=prop1(ox1.x);
      x1:=ox1;
   end;

   if unsicht then exit;

   b1:=x1.y<=-bldhoch/2;
   b2:=x1.y>= bldhoch/2;
   if b1 or b2 then
   begin                              {y-Clipping von x1}
      if b1 then ox1.y:=-0.5*bldhoch else ox1.y:=0.5*bldhoch;
      ox1.x:=prop2(ox1.y);
      x1:=ox1;
   end;

   {2. clipping x2 --> ox2}
   b1:=x2.x<=-bldlang/2;
   b2:=x2.x>= bldlang/2;
   if b1 or b2 then
   begin                              {x-Clipping von x2}
      if b1 then ox2.x:=-0.5*bldlang else ox2.x:=0.5*bldlang;
      ox2.y:=prop1(ox2.x);
      x2:=ox2;
   end;

   if unsicht then exit;

   b1:=x2.y<=-bldhoch/2;
   b2:=x2.y>= bldhoch/2;
   if b1 or b2 then
   begin                              {y-Clipping von x2}
      if b1 then ox2.y:=-0.5*bldhoch else ox2.y:=0.5*bldhoch;
      ox2.x:=prop2(ox2.y);
      x2:=ox2;
   end;

   if (not unsicht) then
   begin
      ix1:=trunc(xmax*(x1.x/bldlang+0.5));
      iy1:=trunc(ymax*(0.5-x1.y/bldhoch));
      ix2:=trunc(xmax*(x2.x/bldlang+0.5));
      iy2:=trunc(ymax*(0.5-x2.y/bldhoch));
      if (ix1<xmax)and(ix2<xmax)and(iy1<ymax)and(iy2<ymax)
	 and(ix1>=0)and(ix2>0)and(iy1>0)and(iy2>0) then
	 if ((ix1=ix2)and(iy1=iy2))then putpixel(ix1,iy1,farbe) else
	    linexy(ix1,iy1,ix2,iy2,farbe);
   end;
end;

procedure initproj;
{calculate xdach und ydach and normalise}
var b:real;
begin
   normvek(nrp);   {Bildschirmnormale  normieren}
   b:=vup.x*nrp.x+vup.y*nrp.y+vup.z*nrp.z;
   ydach.x:=vup.x-b*nrp.x;
   ydach.y:=vup.y-b*nrp.y;
   ydach.z:=vup.z-b*nrp.z;
   normvek(ydach);
   xdach.x:=ydach.y*nrp.z-ydach.z*nrp.y;
   xdach.y:=ydach.z*nrp.x-ydach.x*nrp.z;
   xdach.z:=ydach.x*nrp.y-ydach.y*nrp.x;
   vrps.x:=vrp.x*xdach.x+vrp.y*xdach.y+vrp.z*xdach.z;
   vrps.y:=vrp.x*ydach.x+vrp.y*ydach.y+vrp.z*ydach.z;
end;

procedure initrg;
var  ox,vxr,vxl:vek;
begin
   ox.x:=nrp.x*brennweite;
   ox.y:=nrp.y*brennweite;
   ox.z:=nrp.z*brennweite;

   brennpunkt.x:=vrp.x-ox.x;
   brennpunkt.y:=vrp.y-ox.y;
   brennpunkt.z:=vrp.z-ox.z;

   vxr.x:=ox.x+0.5*augdist*xdach.x;
   vxr.y:=ox.y+0.5*augdist*xdach.y;
   vxr.z:=ox.z+0.5*augdist*xdach.z;

   vxl.x:=ox.x-0.5*augdist*xdach.x;
   vxl.y:=ox.y-0.5*augdist*xdach.y;
   vxl.z:=ox.z-0.5*augdist*xdach.z;

   vrpr.x:=brennpunkt.x+vxr.x;
   vrpr.y:=brennpunkt.y+vxr.y;
   vrpr.z:=brennpunkt.z+vxr.z;

   vrpl.x:=brennpunkt.x+vxl.x;
   vrpl.y:=brennpunkt.y+vxl.y;
   vrpl.z:=brennpunkt.z+vxl.z;

   normvek(vxl);nrpl:=vxl;
   normvek(vxr);nrpr:=vxr;

   fpl.x:=vrpl.x+fluchtweite*nrpl.x;
   fpl.y:=vrpl.y+fluchtweite*nrpl.y;
   fpl.z:=vrpl.z+fluchtweite*nrpl.z;

   fpr.x:=vrpr.x+fluchtweite*nrpr.x;
   fpr.y:=vrpr.y+fluchtweite*nrpr.y;
   fpr.z:=vrpr.z+fluchtweite*nrpr.z;
end;




function calcproj(op:vek;var ox:vek):boolean;
{project to viewport and test for visibility}

var b,lamda,z,n:real;
   h,d,xs:vek;

begin
   calcproj:=false;
   if fluchtdarst then
   begin
      {perspective viewing}
      h.x:=vrp.x-fluchtpunkt.x;
      h.y:=vrp.y-fluchtpunkt.y;
      h.z:=vrp.z-fluchtpunkt.z;

      d.x:=op.x-fluchtpunkt.x;
      d.y:=op.y-fluchtpunkt.y;
      d.z:=op.z-fluchtpunkt.z;

      z:=h.x*nrp.x+h.y*nrp.y+h.z*nrp.z;
      n:=d.x*nrp.x+d.y*nrp.y+d.z*nrp.z;

      b:=((op.x-vrp.x)*nrp.x+(op.y-vrp.y)*nrp.y+(op.z-vrp.z)*nrp.z);
      {clip points outside}
      if (b<=0) and (n<>0) then
      begin
	 if b=0 then xs:=op
	 else
	 begin
	    lamda:=z/n;
	    xs.x:=fluchtpunkt.x+lamda*d.x;
	    xs.y:=fluchtpunkt.y+lamda*d.y;
	    xs.z:=fluchtpunkt.z+lamda*d.z;
	 end;
	 ox.x:=-vrps.x+xdach.x*xs.x+xdach.y*xs.y+xdach.z*xs.z;
	 ox.y:=-vrps.y+ydach.x*xs.x+ydach.y*xs.y+ydach.z*xs.z;
	 ox.z:=-lamda;
	 calcproj:=true;
      end;
   end
   else
   begin
      {parallel projection}
      n:=(op.x-vrp.x)*nrp.x+(op.y-vrp.y)*nrp.y+(op.z-vrp.z)*nrp.z;
      {Clipping}
      if n<=0 then
      begin
	 ox.x:=-vrps.x+xdach.x*op.x+xdach.y*op.y+xdach.z*op.z;
	 ox.y:=-vrps.y+ydach.x*op.x+ydach.y*op.y+ydach.z*op.z;
	 ox.z:=abs(n);
	 calcproj:=true;
      end;
   end;
end;

procedure normmode;
begin
   rgenable:=false;
end;

procedure rgmode;
var x,y:integer;
begin
   initproj;
   rgenable:=true;
   fluchtdarst:=true;
   for y:=0 to 15 do
      for x:=0 to 15 do
	 setrgb(16*y+x,4*y,4*x,0);
   initrg;
end;

procedure put3dpixel(op:vek;color:byte);
var ox,oxr,oxg,vrp1,nrp1,fp:vek;
   ix,iy: integer;
   vr,vg: boolean;

begin
   if not rgenable then
      if calcproj(op,ox) then
      begin
	 ix:=round(xmax*(ox.x/bldlang+0.5));
	 iy:=round(ymax*(0.5-ox.y/bldhoch));
	 if (ix>=0)and(iy>=0)and(ix<xmax)and(iy<ymax)then
	    putpixel(ix,iy,color);
      end;
   if rgenable then
   begin
      {first calculate both points}
      color:=color and 15;  {16 shades of grey}
      vrp1:=vrp;
      nrp1:=nrp;

      {move by augdist/2 to the right}
      fp:=fluchtpunkt;

      vrp:=vrpr;nrp:=nrpr;fluchtpunkt:=fpr;
      initproj;
      vr:=calcproj(op,oxr);

      {move by augdist/2 to the left}
      vrp:=vrpl;nrp:=nrpl;fluchtpunkt:=fpl;
      initproj;
      vg:=calcproj(op,oxg);

      vrp:=vrp1;nrp:=nrp1;fluchtpunkt:=fp;
      initproj;

      if vr then
      begin
	 ix:=round(xmax*(oxr.x/bldlang+0.5));
	 iy:=round(ymax*(0.5-oxr.y/bldhoch));
	 if (ix>=0)and(iy>=0)and(ix<xmax)and(iy<ymax)then putpixel(ix,iy,color);
      end;

      if vg then
      begin
	 ix:=round(xmax*(oxg.x/bldlang+0.5));
	 iy:=round(ymax*(0.5-oxg.y/bldhoch));
	 if (ix>=0)and(iy>=0)and(ix<xmax)and(iy<ymax)then putpixel(ix,iy,16*color);
      end;
   end;
end;

function calcline3d(op1,op2:vek;var ox1,ox2:vek):boolean;
var b,b1,b2,n,l:real;
   p1p2,op:vek;
   dummy:boolean;

begin
   p1p2.x:=op2.x-op1.x;
   p1p2.y:=op2.y-op1.y;
   p1p2.z:=op2.z-op1.z;
   n:=p1p2.x*nrp.x+p1p2.y*nrp.y+p1p2.z*nrp.z;
   b1:=(vrp.x-op1.x)*nrp.x+
   (vrp.y-op1.y)*nrp.y+
   (vrp.z-op1.z)*nrp.z;
   b2:=(vrp.x-op2.x)*nrp.x+
   (vrp.y-op2.y)*nrp.y+
   (vrp.z-op2.z)*nrp.z;
   if (b1<0)and(b2<0)then
   begin
      calcline3d:=false;
      exit;
   end; {both behind}
   if (b1>=0)and(b2<0) then      {only op2 behind}
   begin
    b:=b1;b1:=b2;b2:=b;
    op:=op1;op1:=op2;op2:=op;
   end;
   {projection of vectors without clipping}
   dummy:=calcproj(op2,ox2);
   if (b1<0)and(b2>=0) then
   begin                        {op1 behind view port}
      if n<>0 then
      begin
	 l:=b1/n;
	 op.x:=l*p1p2.x+op1.x;
	 op.y:=l*p1p2.y+op1.y;
	 op.z:=l*p1p2.z+op1.z;
	 ox1.x:=xdach.x*op.x+xdach.y*op.y+xdach.z*op.z-vrps.x;
	 ox1.y:=ydach.x*op.x+ydach.y*op.y+ydach.z*op.z-vrps.y;
      end
      else
      begin calcline3d:=false;exit;end;
   end
   else dummy:=calcproj(op1,ox1);
   {at this point there are projections of clipped endpoints in ox1,ox2}
   calcline3d:=dummy;
end;

procedure line3d(op1,op2:vek;farbe:byte);
var dummy,vr,vl:boolean;
   ox1,ox2,ox1r,ox2r,ox1l,ox2l,vrp1,nrp1,fp:vek;
begin
   dummy:=(op1.x=op2.x)and(op1.y=op2.y)and(op1.z=op2.z);
   if dummy then put3dpixel(op1,farbe)
   else
      if rgenable then
      begin
	 farbe:=farbe and 15;
	 vrp1:=vrp;
	 nrp1:=nrp;
	 {move by augdist/2 to the right}

	 fp:=fluchtpunkt;

	 vrp:=vrpr;nrp:=nrpr;fluchtpunkt:=fpr;
	 initproj;
	 vr:=calcline3d(op1,op2,ox1r,ox2r);

	 {move by augdist/2 nach the left}
	 vrp:=vrpl;nrp:=nrpl;fluchtpunkt:=fpl;
	 initproj;
	 vl:=calcline3d(op1,op2,ox1l,ox2l);
	 vrp:=vrp1;nrp:=nrp1;fluchtpunkt:=fp;
	 initproj;
	 if vr and vl then
	 begin
	    line2d(ox1l,ox2l,16*farbe);
	    line2d(ox1r,ox2r,farbe);
	 end;
      end
      else
      begin
	 dummy:=calcline3d(op1,op2,ox1,ox2);
	 if dummy then line2d(ox1,ox2,farbe);
      end;
end;

procedure rotx(var ox:vek;a:real);
var x1,x2,x3,c,s:real;
begin
   c:=cos(a);s:=sin(a);
   x2:=ox.y*c-ox.z*s;
   x3:=ox.y*s+ox.z*c;
   x1:=ox.x;
   ox.x:=x1;ox.y:=x2;ox.z:=x3;
end;

procedure roty(var ox:vek;a:real);
var x1,x2,x3,c,s:real;
begin
   c:=cos(a);s:=sin(a);
   x3:=ox.z*c-ox.x*s;
   x1:=ox.z*s+ox.x*c;
   x2:=ox.y;
   ox.x:=x1;ox.y:=x2;ox.z:=x3;
end;


procedure rotz(var ox:vek;a:real);
var x1,x2,x3,c,s:real;
begin
   c:=cos(a);s:=sin(a);
   x1:=ox.x*c-ox.y*s;
   x2:=ox.x*s+ox.y*c;
   x3:=ox.z;
   ox.x:=x1;ox.y:=x2;ox.z:=x3;
end;

begin
   vrp.x:=10; vrp.y:=00; vrp.z:=10;
   vup.x:=0; vup.y:=0; vup.z:=1;
   nrp.x:=1;nrp.y:=1;nrp.z:=1;
   fluchtpunkt.x:=100;
   fluchtpunkt.y:=100;
   fluchtpunkt.z:=100;
   bldhoch:=60;bldlang:=80;
   augdist:=2;
   fluchtweite:=1;
   fluchtdarst:=true;
   initproj;
   normmode;
   orenable:=true;
end.
