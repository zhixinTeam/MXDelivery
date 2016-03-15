{*******************************************************************************
  作者: fendou116688@163.com 2016/3/11
  描述: 处理过磅错误
*******************************************************************************}
unit UFormPoundErr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, ComCtrls, cxContainer, cxEdit, cxTextEdit,
  cxListView, cxMCListBox, dxLayoutControl, UBusinessConst, StdCtrls;

type
  TfFormPoundErr = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    ListInfo: TcxMCListBox;
    dxLayout1Item3: TdxLayoutItem;
    ListBill: TcxListView;
    dxLayout1Item7: TdxLayoutItem;
    EditCus: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditBill: TcxTextEdit;
    LayItem1: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    MemoErr: TMemo;
    dxLayout1Item4: TdxLayoutItem;
    MemoDeal: TMemo;
    dxLayout1Item6: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBillSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListInfoClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FBillItems: TLadingBillItems;
    procedure InitFormData;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysGrid, UFormBase,
  USysBusiness, USysDB, USysConst;

class function TfFormPoundErr.FormID: integer;
begin
  Result := cFI_FormDealPoundErr;
end;

class function TfFormPoundErr.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;

  with TfFormPoundErr.Create(Application) do
  begin
    Caption := '错误处理';


    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      AnalyseBillItems(FParamA, FBillItems);
      MemoErr.Text := FParamB;
      
      InitFormData;
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;
      FParamB := Trim(MemoDeal.Text);
    end else ShowModal;

    Free;
  end;
end;

procedure TfFormPoundErr.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  dxGroup1.AlignVert := avClient;
  dxLayout1Item3.AlignVert := avClient;
  //client align

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadMCListBoxConfig(Name, ListInfo, nIni);
    LoadcxListViewConfig(Name, ListBill, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormPoundErr.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SaveMCListBoxConfig(Name, ListInfo, nIni);
    SavecxListViewConfig(Name, ListBill, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormPoundErr.InitFormData;
var nIdx: Integer;
begin
  ListBill.Clear;

  for nIdx:=Low(FBillItems) to High(FBillItems) do
  with ListBill.Items.Add,FBillItems[nIdx] do
  begin
    Caption := FID;
    SubItems.Add(Format('%.3f', [FValue]));
    SubItems.Add(FStockName);

    ImageIndex := 11;
    Data := Pointer(nIdx);
  end;

  ListBill.ItemIndex := 0;
end;

procedure TfFormPoundErr.ListBillSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var nIdx: Integer;
begin
  if Selected and Assigned(Item) then
  begin
    nIdx := Integer(Item.Data);

    with FBillItems[nIdx] do
    begin
      EditBill.Text := FID;
      EditCus.Text := FCusName;
      LoadBillItemToMC(FBillItems[nIdx], ListInfo.Items, ListInfo.Delimiter); 
    end;
  end;
end;

procedure TfFormPoundErr.ListInfoClick(Sender: TObject);
var nStr: string;
    nPos: Integer;
begin
  if ListInfo.ItemIndex > -1 then
  begin
    nStr := ListInfo.Items[ListInfo.ItemIndex];
    nPos := Pos(':', nStr);
    if nPos < 1 then Exit;

    LayItem1.Caption := Copy(nStr, 1, nPos);
    nPos := Pos(ListInfo.Delimiter, nStr);

    System.Delete(nStr, 1, nPos);
    EditBill.Text := Trim(nStr);
  end;
end;

procedure TfFormPoundErr.BtnOKClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormPoundErr, TfFormPoundErr.FormID);
end.
