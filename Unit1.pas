unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Memo, FMX.StdCtrls, IdTCPConnection, IdTCPClient, IdHTTP, System.JSON,IdSSLOpenSSL,
  FMX.ListBox ;

type
  TForm1 = class(TForm)
    ToolBar2: TToolBar;
    Button1: TButton;
    ToolBar1: TToolBar;
    Button2: TButton;
    Label1: TLabel;
    ListBox1: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListBox1ItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  a1,a2:array of string;
  n:integer;
implementation
uses unit2;
{$R *.fmx}
{$R *.iPhone4in.fmx IOS}
{$R *.iPhone.fmx IOS}
{$R *.NmXhdpiPh.fmx ANDROID}

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

//** Вывод ссылки на MP4 файл ***////////
function getmp4(s:string):string;
var
  i,l:integer;
  ss:string;
begin
  ss:='none';
  l:=pos('mp4',s);
  if l>0 then begin
    i:=l;
    while s[i]<>'|' do i:=i-1;
    ss:=copy(s,i+1,l-i+2);
  end;
  result:=ss;
end;
//******************//////////////***************//////////

//** Начала вывода таблицы категорий *********////////
procedure getcategory(s:string);
var
  ss:string;
  i,r1,l1,r2,l2:integer;
begin
  ss:=s;
  while pos('"name":',ss)>0 do delete(ss,pos('"name":',ss),7);
  while pos('"id":',ss)>0 do delete(ss,pos('"id":',ss),5);
  while pos('\\\"',ss)>0 do delete(ss,pos('\\\"',ss),4);

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

//*** JSON запрос на сервер ***///
procedure TForm1.Button1Click(Sender: TObject);
var
  idhttp: TidHttp;
  JSON:  TJsonValue;
  Getfile: string;
  Obj: TJSONObject;
  Pair: TJSONPair;
begin
  idhttp :=Tidhttp.Create;
  try
  Getfile:=(idhttp.Get('http://iplay.kaztrk.kz/connect/index2.php?row=name,id&table=dle_category'));
//    Getfile:=(idhttp.Get('http://iplay.kaztrk.kz/connect/index.php?row=id&table=dle_post&t=category&y=8'));
   // Getfile:=(idhttp.Get('http://iplay.kaztrk.kz/connect/index.php?row=xfields&table=dle_post&t=id&y=29'));
    Obj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(GetFile), 0) as TJSONObject;
  {  Invent := Obj.Get('id').JsonValue;
    size := TJSONArray(Invent).size;
    for i := 0 to size - 1 do
    begin
      Inv := TJSONArray(Invent).Get(i);
      Pair := TJSONPair(Inv);
      Memo1.Lines.Add(Format('id #%s', [Pair.JsonString.Value]));
    end;}
//  label1.Text:=getmp4(getfile);
   getcategory(getfile);
//   label1.Text:='YEAP!!!';
//   label1.Text:=a1[1];
  finally
  Obj.Free;
  idhttp.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  j: Integer;
  Buffer: String;
  ListBoxItem : TListBoxItem;
  ListBoxGroupHeader : TListBoxGroupHeader;
begin
  ListBox1.BeginUpdate;
  ListBoxGroupHeader := TListBoxGroupHeader.Create(ListBox1);
  ListBoxGroupHeader.Text := 'Категории';
  ListBox1.AddObject(ListBoxGroupHeader);

  for j:=0 to n-1 do
  begin
    // Add header ('A' to 'Z') to the List

    // Add items ('a', 'aa', 'aaa', 'b', 'bb', 'bbb', 'c', ...) to the list
      // StringOfChar returns a string with a specified number of repeating characters.
      Buffer := a1[j];
      // Simply add item
      // ListBox1.Items.Add(Buffer);

      // or, you can add items by creating an instance of TListBoxItem by yourself
      ListBoxItem := TListBoxItem.Create(ListBox1);
      ListBoxItem.Text := utf16decode(Buffer);
      // (aNone=0, aMore=1, aDetail=2, aCheckmark=3)
      ListBoxItem.ItemData.Accessory := TListBoxItemData.TAccessory(1);
      ListBox1.AddObject(ListBoxItem);
   end;
  ListBox1.EndUpdate;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
 ListBox1.Clear;
 label1.Visible:=false;
 Button1Click(sender);
 Button2Click(sender);
end;
////**** Конец вывода категории *********///

//  http://iplay.kaztrk.kz/connect/index.php?row=title,id&table=dle_post&t=category&y=' + a2[q];

procedure TForm1.ListBox1ItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
//  label1.Text:=a2[item.Index-1];
unit2.Form2.category:=a2[item.Index-1];
form1.Visible:=false;
form2.Show;
end;

end.
