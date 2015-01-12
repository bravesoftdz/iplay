unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.StdCtrls, IdHTTP;

type
  TForm2 = class(TForm)
    ToolBar2: TToolBar;
    Button1: TButton;
    Label1: TLabel;
    ToolBar1: TToolBar;
    Button2: TButton;
    ListBox1: TListBox;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    //procedure showtitle;
   // procedure gettitle(s:string);
  private
    { Private declarations }
  public
    category:string;
    { Public declarations }
  end;

var
  Form2: TForm2;
  a1,a2:array of string;
  n:integer;
implementation
 uses unit1;
{$R *.fmx}
{$R *.iPhone4in.fmx IOS}
//*** Общий вывод строки из UTF-16 в UTF-8 ******///////
function utf16decode(const encode:string):string;
var
presult,psource:PChar;
s:string;
buf,code:Integer;
begin
try
SetLength(result, length(encode));
presult:=pchar(result);
psource:=pchar(encode);

while psource^<>#0 do
begin
if (psource^='\') then
begin
  inc(psource);
  if psource^='u' then
  begin
    psource^:='x';
    SetString(s,psource,5);
    Val(s,buf,code);
    if buf>=$100 then
    begin
      s:=WideChar(buf);
      presult^:=s[1];
    end
    else
      presult^:=chr(buf);
    Inc(psource,5);
  end
  else
    presult^:='\';
end
else
begin
  presult^:=psource^;
  Inc(psource);
end;

Inc(presult);
end;
SetLength(result, presult - pchar(Result));
except
result:='error';
end;
end;
///***********************/**************/////*******////

procedure gettitle(s:string);
var
  ss:string;
  i,r1,l1,r2,l2:integer;
begin
  ss:=s;
  while pos('"title":',ss)>0 do delete(ss,pos('"title":',ss),8);
  while pos('"id":',ss)>0 do delete(ss,pos('"id":',ss),5);
  n:=0;
  i:=n-1;
  while pos('"',ss)>0 do begin
   r1:=pos('"',ss);
   delete(ss,r1,1);
   l1:=pos('"',ss);
   delete(ss,l1,1);
   r2:=pos('"',ss);
   delete(ss,r2,1);
   l2:=pos('"',ss);
   delete(ss,l2,1);
   n:=n+1;
   i:=i+1;
   setlength(a1,n);
   setlength(a2,n);
   a1[i]:=copy(ss,r1,l1-r1);
   a2[i]:=copy(ss,r2,l2-r2);
  end;
end;

procedure showtitle;

  var
  j: Integer;
  Buffer: String;
  ListBoxItem : TListBoxItem;
  ListBoxGroupHeader : TListBoxGroupHeader;
begin
  form2.ListBox1.BeginUpdate;
  ListBoxGroupHeader := TListBoxGroupHeader.Create(form2.ListBox1);
  ListBoxGroupHeader.Text := 'Серии';
   form2.ListBox1.AddObject(ListBoxGroupHeader);

  for j:=0 to n-1 do
  begin
    // Add header ('A' to 'Z') to the List

    // Add items ('a', 'aa', 'aaa', 'b', 'bb', 'bbb', 'c', ...) to the list
      // StringOfChar returns a string with a specified number of repeating characters.
      Buffer := a1[j];
      // Simply add item
      // ListBox1.Items.Add(Buffer);

      // or, you can add items by creating an instance of TListBoxItem by yourself
      ListBoxItem := TListBoxItem.Create(form2.ListBox1);
      ListBoxItem.Text := utf16decode(Buffer);
      // (aNone=0, aMore=1, aDetail=2, aCheckmark=3)
      ListBoxItem.ItemData.Accessory := TListBoxItemData.TAccessory(1);
       form2.ListBox1.AddObject(ListBoxItem);
   end;
   form2.ListBox1.EndUpdate;
end;


procedure TForm2.Button2Click(Sender: TObject);
begin
form2.hide;
form1.show;
end;

procedure TForm2.FormShow(Sender: TObject);
var
  idhttp: TidHttp;
  Getfile:string;
begin
idhttp :=Tidhttp.Create;
try
  ListBox1.Clear;
  Getfile:=(idhttp.Get('http://iplay.kaztrk.kz/connect/index.php?row=title,id&table=dle_post&t=category&y=' + category));
  gettitle(Getfile);
  showtitle;
finally
  idhttp.Free;
end;

end;

end.
