unit UFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    Memo2: TMemo;
    Button3: TButton;
    Button4: TButton;
    Button1: TButton;
    procedure FormResize(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
uses
  ULibFun, UFormCtrl;

const
  sTable_Dict = 'Sys_Dict';

procedure TForm1.FormResize(Sender: TObject);
begin
  Memo1.Height := Trunc( (ClientHeight - Panel1.Height) / 2 );
end;

function AdjustStr(const nStr: string): string;
begin
  Result := StringReplace(nStr, '"', '', [rfReplaceAll]);
end;

procedure TForm1.Button3Click(Sender: TObject);
var nStr,nType: string;
    nIdx,nLen: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    Memo2.Text := 'Delete From Sys_Dict Where D_Name=''StockItem''';
    //xxxxx

    for nIdx:=0 to Memo1.Lines.Count - 1 do
    begin
      nStr := Trim(Memo1.Lines[nIdx]);
      if not SplitStr(nStr, nList, 2, #9) then Continue;
      //xxxxx

      nLen := Length(nList[1]);
      if Copy(nList[1], nLen, 1) = '?' then
        nList[1] := Copy(nList[1], 1, nLen - 1);
      //xxxxx

      nList.Text := StringReplace(nList.Text, '"', '', [rfReplaceAll]);
      //xxxxx

      if (Pos('袋装', nList[1]) > 0) then
           nType := 'D'
      else nType := 'S';

      nStr := MakeSQLByStr([SF('D_Name', 'StockItem'),
              SF('D_Desc', '水泥类型'),
              SF('D_Value', nList[1]),
              SF('D_Memo', nType),
              SF('D_ParamB', nList[0])
              ], 'Sys_Dict', '', True);
      Memo2.Lines.Add(nStr);
    end;
  finally
    nList.Free;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    Memo2.Text := 'Delete From S_Card';
    //xxxxx

    for nIdx:=0 to Memo1.Lines.Count - 1 do
    begin
      nStr := Trim(Memo1.Lines[nIdx]);
      if not SplitStr(nStr, nList, 2, ',') then Continue;
      //xxxxx

      nStr := MakeSQLByStr([SF('C_Card2', nList[1]),
              SF('C_Card3', nList[0]),
              SF('C_Status', 'I'),
              SF('C_Freeze', 'N'),
              SF('C_Man', 'admin'),
              SF('C_Date', 'getDate()', sfVal),
              SF('C_Used', 'S')
              ], 'S_Card', '', True);
      Memo2.Lines.Add(nStr);
    end;
  finally
    nList.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var nStr,nType: string;
    nIdx,nLen: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    Memo2.Text := 'Delete From Sys_Dict Where D_Name=''PackerItem''';
    //xxxxx

    for nIdx:=0 to Memo1.Lines.Count - 1 do
    begin
      nStr := Trim(Memo1.Lines[nIdx]);

      nStr := MakeSQLByStr([SF('D_Name', 'PackerItem'),
              SF('D_Desc', '包装机名称'),
              SF('D_Value', nStr)
              ], 'Sys_Dict', '', True);
      Memo2.Lines.Add(nStr);
    end;
  finally
    nList.Free;
  end;
end;

end.
