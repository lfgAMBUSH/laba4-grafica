unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
StdCtrls, GraphType, IntfGraphics, LCLType, LCLProc, LCLIntf, ExtCtrls,
ExtDlgs, fpImage, crt, FPWritePNM, math;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Image1: TImage;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    SavePictureDialog1: TSavePictureDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure arceq(x0, y0, r, x1,y1,x2,y2:real; canvas:TCanvas);
var x,y,kp,bp:real;
 inv:integer;
begin
 if x1>=x2 then inv:=-1 else inv:=1;//нужна ли инверсия
 if x1=x2 then x1:=x1+0.1/r;// плутовство исключить вертикали.
 kp:=(y1-y2)/(x1-x2);//угловой коэффициент секущей хорды
 bp:=y1-x1*kp;//свободный член секущей хорды
 //прорисовываем как функцию y=f(x) по точкам
 x:=0;// начиная с x=0
 y:=r;
 while x<y do //до угла 45
 begin //если точки с нужной стороны секущей
 y:=sqrt(sqr(r)-sqr(x));//вывод точек в симметричных секторах
 if inv*((y0+y)-(kp*(x0+x)+bp))<=0 then
 canvas.Pixels[floor(x0+x),floor(y0+y)]:=canvas.Pen.Color;
 if inv*((y0-y)-(kp*(x0+x)+bp))<=0 then
 canvas.Pixels[floor(x0+x),floor(y0-y)]:=canvas.Pen.Color;
 if inv*((y0+y)-(kp*(x0-x)+bp))<=0 then
 canvas.Pixels[floor(x0-x),floor(y0+y)]:=canvas.Pen.Color;
 if inv*((y0-y)-(kp*(x0-x)+bp))<=0 then
 canvas.Pixels[floor(x0-x),floor(y0-y)]:=canvas.Pen.Color;
 x:=x+1
 end;
 while y>=0 do //с угла 45 до y=0 выводим ка функцию x=g(y)
 begin //если точки с нужной стороны секущей
 x:=sqrt(sqr(r)-sqr(y)); //вывод точек в симметричных секторах
 if inv*((y0+y)-(kp*(x0+x)+bp))<=0 then
 canvas.Pixels[floor(x0+x),floor(y0+y)]:=canvas.Pen.Color;
 if inv*((y0-y)-(kp*(x0+x)+bp))<=0 then
 canvas.Pixels[floor(x0+x),floor(y0-y)]:=canvas.Pen.Color;
 if inv*((y0+y)-(kp*(x0-x)+bp))<=0 then
 canvas.Pixels[floor(x0-x),floor(y0+y)]:=canvas.Pen.Color;
 if inv*((y0-y)-(kp*(x0-x)+bp))<=0 then
 canvas.Pixels[floor(x0-x),floor(y0-y)]:=canvas.Pen.Color;
 y:=y-1
 end;
end;

procedure arcparam(x0, y0, r, x1,y1,x2,y2:real; canvas:TCanvas);
var x,y,tau,tau0,sa,ea:real;
begin
 if x1=x0 then if y1>y0 then sa:=pi/2 else sa:=3*pi/2
 else sa:=arctan((y1-y0)/(x1-x0));//начальный угол
 if x2=x0 then if y2>y0 then ea:=pi/2 else ea:=3*pi/2
 else ea:=arctan((y2-y0)/(x2-x0));//конечный угол
 if x1<x0 then sa:=pi+sa;//коррекция полуплоскости нач угла
 if x2<x0 then ea:=pi+ea;//коррекция полуплоскости кон угла
 if sa<0 then sa:=sa+2*pi;//коррекция знака начального угла
 if ea<0 then ea:=ea+2*pi;//коррекция знака конечного угла
 if sa>ea then//если начальный угол больше конечного
 ea:=ea+2*pi;//доворачиваем конечный угол на оборот
 tau0:=1/r;//чем больше радиус тем меньше шаг.
 tau:=sa;//начинаем с начального угла
 while tau<ea do //рисуем до конечного
 begin
 x:=x0+r*cos(tau);// параметрическое уравнение для x
 y:=y0+r*sin(tau);// параметрическое уравнение для y
 canvas.Pixels[floor(x),floor(y)]:=canvas.Pen.Color;// точка
 tau:=tau+tau0;//увеличиваем угол
 end;
end;

procedure arcbrez(x0, y0, r, x1,y1,x2,y2:integer; canvas:TCanvas);
const pi=3.1415926;
var x,y,delta,spx,epx,spy,epy,sag,eag,sp,ep:integer;
 sa,ea,rs,re,t:real;
 dr,inv:boolean;
begin
 x:=0; //начальное значение x для алгоритма Брезенхема
 y:=R; //начальное значение y для алгоритма Брезенхэма
 delta:=2-2*r; //ошибка
 rs:=sqrt(sqr(x1-x0)+sqr(y1-y0));//длина луча начального угла
 re:=sqrt(sqr(x2-x0)+sqr(y2-y0));//длина луча конечного угла
 sa:=arcsin((y1-y0)/rs);//начальный угол
 ea:=arcsin((y2-y0)/re);//конечный угол
 if x1<x0 then sa:=pi-sa;//коррекция полуплоскости нач угла
 if x2<x0 then ea:=pi-ea;//коррекция полуплоскости кон угла
 if sa<0 then sa:=sa+2*pi;//коррекция знака начального угла
 if ea<0 then ea:=ea+2*pi;//коррекция знака конечного угла
 inv:=false;//нужна ли инверсия
 if sa>ea then//если начальный угол больше конечного
 begin
 t:=sa;
 sa:=ea;
 ea:=t; //меняем их местами
 inv:=true;//и инвертируем вывод
 end;
 sag:=round(sa*360/2/pi);//начальный угол в градусах
 eag:=round(ea*360/2/pi);//конечный угол в градусах
 spx:=round(x0+r*cos(sa));//абсцисса начала сектора
 spy:=round(y0+r*sin(sa));//ордината начала сектора
 epx:=round(x0+r*cos(ea));//абсцисса конца сектора
 epy:=round(y0+r*sin(ea));//ордината конца сектора
 while x<=y do //вывод по алгоритму Бразенхейма 8 секторов
 begin
 dr:=false;//если есть все условия вывода для каждого сектора
 if (sag<=45)and(eag>=0) then
 begin
 if (sag>=0) then sp:=spy else sp:=y0;
 if (eag<45) then ep:=epy else ep:=y0+r;
 if (y0+x>=sp) and (y0+x<=ep) then dr:=true;
 end;
 if (dr and (not inv)) or (inv and (not dr)) then
 canvas.Pixels[x0+y,y0+x]:=canvas.Pen.Color;//1 (обр)
 dr:=false;
 if (sag<90) and (eag>=45) then
 begin
 if (sag>=45) then sp:=spx else sp:=x0+r;
 if (eag<90) then ep:=epx else ep:=x0;
 if (x0+x <= sp) and (x0+x >= ep) then dr:=true;
 end;
 if (dr and (not inv)) or (inv and (not dr)) then
 canvas.Pixels[x0+x,y0+y]:=canvas.Pen.Color;//2
 dr:=false;
 if (sag<135) and (eag>=90) then
 begin
 if (sag>=90) then sp:=spx else sp:=x0;
 if (eag<135) then ep:=epx else ep:=x0-r;
 if (x0-x <= sp) and (x0-x >= ep) then dr:=true;
 end;
 if (dr and (not inv)) or (inv and (not dr)) then
 canvas.Pixels[x0-x,y0+y]:=canvas.Pen.Color;//3 (обр)
 dr:=false;
 if (sag<180) and (eag>=135) then
 begin
 if (sag>=135) then sp:=spy else sp:=y0+r;
 if (eag<180) then ep:=epy else ep:=y0;
 if (y0+x <= sp) and (y0+x >= ep) then dr:=true;
 end;
 if (dr and (not inv)) or (inv and (not dr)) then
 canvas.Pixels[x0-y,y0+x]:=canvas.Pen.Color;//4
 dr:=false;
 if (sag<225) and (eag>=180) then
 begin
 if (sag>=180) then sp:=spy else sp:=y0;
 if (eag<225) then ep:=epy else ep:=y0-r;
 if (y0-x <= sp) and (y0-x >= ep) then dr:=true;
 end;
 if (dr and (not inv)) or (inv and (not dr)) then
 canvas.Pixels[x0-y,y0-x]:=canvas.Pen.Color;//5 (обр)
 dr:=false;
 if (sag<270) and (eag>=225) then
 begin
 if (sag>=225) then sp:=spx else sp:=x0-r;
 if (eag<270) then ep:=epx else ep:=x0;
 if (x0-x >= sp) and (x0-x <= ep) then dr:=true;
 end;
 if (dr and (not inv)) or (inv and (not dr)) then
 canvas.Pixels[x0-x,y0-y]:=canvas.Pen.Color;//6
 dr:=false;
 if (sag<315) and (eag>=270) then
 begin
 if (sag>=270) then sp:=spx else sp:=x0;
 if (eag<315) then ep:=epx else ep:=x0+r;
 if (x0+x >= sp) and (x0+x <= ep) then dr:=true;
 end;
 if (dr and (not inv)) or (inv and (not dr)) then
 canvas.Pixels[x0+x,y0-y]:=canvas.Pen.Color;//7 (обр)
 dr:=false;
 if (sag<360) and (eag>=315) then
 begin
 if (sag>=315) then sp:=spy else sp:=y0-r;
 if (eag<360) then ep:=epy else ep:=y0;
 if (y0-x >= sp) and (y0-x <= ep) then dr:=true;
 end;
 if (dr and (not inv)) or (inv and (not dr)) then
 canvas.Pixels[x0+y,y0-x]:=canvas.Pen.Color;//8
// Переход к следующей точке
 if (delta<0) and (2*(delta+y)-1<=0) then
 begin
 x:=x+1;
 delta:=delta+2*x+1
 end
 else
 if (delta>0) and (2*(delta-x)-1>0) then
 begin
 y:=y-1;
 delta:=delta-2*y+1
 end
 else
 begin
 x:=x+1;
 y:=y-1;
 delta:=delta+2*(x-y)
 end;
 end;
end;

procedure TForm1.Button1Click(Sender: Tobject);
var a,bord:integer;
 xo,yo,r1,r2,xa,ya,xb,yb,xc,yc,xd,yd:real;
 xt1,yt1,xr1,yr1,xb1,yb1,xl1,yl1:real;
 xt2,yt2,xr2,yr2,xb2,yb2,xl2,yl2:real;
begin
 with Image1.Picture.Bitmap do
 begin
 Clear;
 PixelFormat:=pf24bit;
 a:=StrToInt(Edit1.Text);
 bord:=30;
 r1:=a/2;
 r2:=a*sqrt(2)/2;
 Width:=round(2*r2)+2*bord;
 Height:=round(2*r2)+2*bord;
 Canvas.Brush.Color:=RGB(255,255,255);
 Canvas.FillRect(0,0,Width,Height);
 xo:=Width/2;
 yo:=Height/2;
 xa:=xo-a/2;
 ya:=yo-a/2;
 xb:=xo+a/2;
 yb:=yo-a/2;
 xc:=xo+a/2;
 yc:=yo+a/2;
 xd:=xo-a/2;
 yd:=yo+a/2;
 xt1:=xo; yt1:=yo-r1;
 xr1:=xo+r1; yr1:=yo;
 xb1:=xo; yb1:=yo+r1;
 xl1:=xo-r1; yl1:=yo;
 xt2:=xo; yt2:=yo-r2;
 xr2:=xo+r2; yr2:=yo;
 xb2:=xo; yb2:=yo+r2;
 xl2:=xo-r2; yl2:=yo;
 canvas.Pen.Color:=RGB(127,127,127);
 canvas.line(round(xa),round(ya),round(xb),round(yb));
 canvas.line(round(xb),round(yb),round(xc),round(yc));
 canvas.line(round(xc),round(yc),round(xd),round(yd));
 canvas.line(round(xd),round(yd),round(xa),round(ya));
 canvas.Pen.Color:=RGB(191,191,255);
 arceq(xo,yo,r1,xt1,yt1,xr1,yr1,canvas);
 arceq(xo,yo,r1,xr1,yr1,xb1,yb1,canvas);
 arceq(xo,yo,r1,xb1,yb1,xl1,yl1,canvas);
 arceq(xo,yo,r1,xl1,yl1,xt1,yt1,canvas);
 arceq(xo,yo,r2,xt2,yt2,xr2,yr2,canvas);
 arceq(xo,yo,r2,xr2,yr2,xb2,yb2,canvas);
 arceq(xo,yo,r2,xb2,yb2,xl2,yl2,canvas);
 arceq(xo,yo,r2,xl2,yl2,xt2,yt2,canvas);
 canvas.Pen.Color:=RGB(255,191,191);
 arcparam(xo,yo,r1,xt1,yt1,xr1,yr1,canvas);
 arcparam(xo,yo,r1,xr1,yr1,xb1,yb1,canvas);
 arcparam(xo,yo,r1,xb1,yb1,xl1,yl1,canvas);
 arcparam(xo,yo,r1,xl1,yl1,xt1,yt1,canvas);
 arcparam(xo,yo,r2,xt2,yt2,xr2,yr2,canvas);
 arcparam(xo,yo,r2,xr2,yr2,xb2,yb2,canvas);
 arcparam(xo,yo,r2,xb2,yb2,xl2,yl2,canvas);
 arcparam(xo,yo,r2,xl2,yl2,xt2,yt2,canvas);
 canvas.Pen.Color:=RGB(191,255,191);
 arcbrez(round(xo),round(yo),round(r1),round(xt1),round(yt1),round(xr1),round(yr1),canvas);
 arcbrez(round(xo),round(yo),round(r1),round(xr1),round(yr1),round(xb1),round(yb1),canvas);
 arcbrez(round(xo),round(yo),round(r1),round(xb1),round(yb1),round(xl1),round(yl1),canvas);
 arcbrez(round(xo),round(yo),round(r1),round(xl1),round(yl1),round(xt1),round(yt1),canvas);
 arcbrez(round(xo),round(yo),round(r2),round(xt2),round(yt2),round(xr2),round(yr2),canvas);
 arcbrez(round(xo),round(yo),round(r2),round(xr2),round(yr2),round(xb2),round(yb2),canvas);
 arcbrez(round(xo),round(yo),round(r2),round(xb2),round(yb2),round(xl2),round(yl2),canvas);
 arcbrez(round(xo),round(yo),round(r2),round(xl2),round(yl2),round(xt2),round(yt2),canvas);
 canvas.Pen.Color:=RGB(127,127,127);
 canvas.Arc(round(xo-r1),round(yo-r1),round(xo+r1),round(yo+r1),round(xt1),round(yt1),round(xr1),round(yr1));
 canvas.Arc(round(xo-r1),round(yo-r1),round(xo+r1),round(yo+r1),round(xr1),round(yr1),round(xb1),round(yb1));
 canvas.Arc(round(xo-r1),round(yo-r1),round(xo+r1),round(yo+r1),round(xb1),round(yb1),round(xl1),round(yl1));
 canvas.Arc(round(xo-r1),round(yo-r1),round(xo+r1),round(yo+r1),round(xl1),round(yl1),round(xt1),round(yt1));
 canvas.Arc(round(xo-r2),round(yo-r2),round(xo+r2),round(yo+r2),round(xt2),round(yt2),round(xr2),round(yr2));
 canvas.Arc(round(xo-r2),round(yo-r2),round(xo+r2),round(yo+r2),round(xr2),round(yr2),round(xb2),round(yb2));
 canvas.Arc(round(xo-r2),round(yo-r2),round(xo+r2),round(yo+r2),round(xb2),round(yb2),round(xl2),round(yl2));
 canvas.Arc(round(xo-r2),round(yo-r2),round(xo+r2),round(yo+r2),round(xl2),round(yl2),round(xt2),round(yt2));
 end;
end;
procedure TForm1.Button2Click(Sender: TObject);   //сохранить
var img:TLazIntfImage;
begin
 if SavePictureDialog1.Execute then begin
  img:=Image1.Picture.Bitmap.CreateIntfImage;
  try
   SaveImageToPNMFile(img,ChangeFileExt(SavePictureDialog1.FileName,'.pbm'),true);
  finally
   img.Free;
  end;
 end;
end;

function svgval(s,n:string):real;
var p,q:integer;
 t:string;
begin
 p:=Pos(n+'="',s);
 if p=0 then begin
  result:=0;
  exit;
 end;
 p:=p+Length(n)+2;
 t:=Copy(s,p,Length(s));
 q:=Pos('"',t);
 t:=Copy(t,1,q-1);
 t:=StringReplace(t,'.',DecimalSeparator,[rfReplaceAll]);
 result:=StrToFloat(t);
end;
procedure TForm1.Button3Click(Sender: TObject);
var i:integer;
 a,bord:integer;
 xo,yo,r1,r2,xa,ya,xb,yb,xc,yc,xd,yd:real;
 xt1,yt1,xr1,yr1,xb1,yb1,xl1,yl1:real;
 xt2,yt2,xr2,yr2,xb2,yb2,xl2,yl2:real;
 s:string;
 f:TStringList;
begin
 if OpenDialog1.Execute then
 begin
 f:=TStringList.Create;
 f.LoadFromFile(OpenDialog1.FileName);
 a:=0;
 for i:=0 to f.Count-1 do
 begin
 s:=Trim(f[i]);
 if Pos('<rect',s)>0 then a:=round(svgval(s,'width'));
 end;
 f.Free;
 if a<=0 then begin
  ShowMessage('В SVG не найден квадрат');
  Exit;
 end;
 with Image1.Picture.Bitmap do
 begin
 Clear;
 PixelFormat:=pf24bit;
 bord:=30;
 r1:=a/2;
 r2:=a*sqrt(2)/2;
 Width:=round(2*r2)+2*bord;
 Height:=round(2*r2)+2*bord;
 Canvas.Brush.Color:=RGB(255,255,255);
 Canvas.FillRect(0,0,Width,Height);
 xo:=Width/2;
 yo:=Height/2;
 xa:=xo-a/2;
 ya:=yo-a/2;
 xb:=xo+a/2;
 yb:=yo-a/2;
 xc:=xo+a/2;
 yc:=yo+a/2;
 xd:=xo-a/2;
 yd:=yo+a/2;
 xt1:=xo; yt1:=yo-r1;
 xr1:=xo+r1; yr1:=yo;
 xb1:=xo; yb1:=yo+r1;
 xl1:=xo-r1; yl1:=yo;
 xt2:=xo; yt2:=yo-r2;
 xr2:=xo+r2; yr2:=yo;
 xb2:=xo; yb2:=yo+r2;
 xl2:=xo-r2; yl2:=yo;
 canvas.Pen.Color:=RGB(127,127,127);
 canvas.line(round(xa),round(ya),round(xb),round(yb));
 canvas.line(round(xb),round(yb),round(xc),round(yc));
 canvas.line(round(xc),round(yc),round(xd),round(yd));
 canvas.line(round(xd),round(yd),round(xa),round(ya));
 canvas.Pen.Color:=RGB(191,191,255);
 arceq(xo,yo,r1,xt1,yt1,xr1,yr1,canvas);
 arceq(xo,yo,r1,xr1,yr1,xb1,yb1,canvas);
 arceq(xo,yo,r1,xb1,yb1,xl1,yl1,canvas);
 arceq(xo,yo,r1,xl1,yl1,xt1,yt1,canvas);
 arceq(xo,yo,r2,xt2,yt2,xr2,yr2,canvas);
 arceq(xo,yo,r2,xr2,yr2,xb2,yb2,canvas);
 arceq(xo,yo,r2,xb2,yb2,xl2,yl2,canvas);
 arceq(xo,yo,r2,xl2,yl2,xt2,yt2,canvas);
 canvas.Pen.Color:=RGB(255,191,191);
 arcparam(xo,yo,r1,xt1,yt1,xr1,yr1,canvas);
 arcparam(xo,yo,r1,xr1,yr1,xb1,yb1,canvas);
 arcparam(xo,yo,r1,xb1,yb1,xl1,yl1,canvas);
 arcparam(xo,yo,r1,xl1,yl1,xt1,yt1,canvas);
 arcparam(xo,yo,r2,xt2,yt2,xr2,yr2,canvas);
 arcparam(xo,yo,r2,xr2,yr2,xb2,yb2,canvas);
 arcparam(xo,yo,r2,xb2,yb2,xl2,yl2,canvas);
 arcparam(xo,yo,r2,xl2,yl2,xt2,yt2,canvas);
 canvas.Pen.Color:=RGB(191,255,191);
 arcbrez(round(xo),round(yo),round(r1),round(xt1),round(yt1),round(xr1),round(yr1),canvas);
 arcbrez(round(xo),round(yo),round(r1),round(xr1),round(yr1),round(xb1),round(yb1),canvas);
 arcbrez(round(xo),round(yo),round(r1),round(xb1),round(yb1),round(xl1),round(yl1),canvas);
 arcbrez(round(xo),round(yo),round(r1),round(xl1),round(yl1),round(xt1),round(yt1),canvas);
 arcbrez(round(xo),round(yo),round(r2),round(xt2),round(yt2),round(xr2),round(yr2),canvas);
 arcbrez(round(xo),round(yo),round(r2),round(xr2),round(yr2),round(xb2),round(yb2),canvas);
 arcbrez(round(xo),round(yo),round(r2),round(xb2),round(yb2),round(xl2),round(yl2),canvas);
 arcbrez(round(xo),round(yo),round(r2),round(xl2),round(yl2),round(xt2),round(yt2),canvas);
 canvas.Pen.Color:=RGB(127,127,127);
 canvas.Arc(round(xo-r1),round(yo-r1),round(xo+r1),round(yo+r1),round(xt1),round(yt1),round(xr1),round(yr1));
 canvas.Arc(round(xo-r1),round(yo-r1),round(xo+r1),round(yo+r1),round(xr1),round(yr1),round(xb1),round(yb1));
 canvas.Arc(round(xo-r1),round(yo-r1),round(xo+r1),round(yo+r1),round(xb1),round(yb1),round(xl1),round(yl1));
 canvas.Arc(round(xo-r1),round(yo-r1),round(xo+r1),round(yo+r1),round(xl1),round(yl1),round(xt1),round(yt1));
 canvas.Arc(round(xo-r2),round(yo-r2),round(xo+r2),round(yo+r2),round(xt2),round(yt2),round(xr2),round(yr2));
 canvas.Arc(round(xo-r2),round(yo-r2),round(xo+r2),round(yo+r2),round(xr2),round(yr2),round(xb2),round(yb2));
 canvas.Arc(round(xo-r2),round(yo-r2),round(xo+r2),round(yo+r2),round(xb2),round(yb2),round(xl2),round(yl2));
 canvas.Arc(round(xo-r2),round(yo-r2),round(xo+r2),round(yo+r2),round(xl2),round(yl2),round(xt2),round(yt2));
 end;
 end;
end;

end.

