{*******************************************************************************
  作者: fendou116688@163.com 2015/9/19
  描述: 选择采购申请单
*******************************************************************************}
unit UFormOrdersAX;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, dxLayoutControl, StdCtrls, cxControls,
  ComCtrls, cxListView, cxButtonEdit, cxLabel, cxLookAndFeels,
  cxLookAndFeelPainters;

type
  TOrderBaseParam = record
    FProvID: string;
    FProvName: string;

    FStockNO: string;
    FStockName: string;

    FRestValue: string;
  end;
  TOrderBaseParams = array of TOrderBaseParam;

  TfFormOrdersAX = class(TfFormNormal)
    EditProvider: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    ListQuery: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListQueryKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListQueryDblClick(Sender: TObject);
  private
    { Private declarations }
    FProID, FProName, FOrder: string;
    FListA, FListB, FResults: TStrings;
    //查询数据
    FOrderItems: TOrderBaseParams;
    function LoadAXOrderInfo(const nProID: string=''): Boolean;
    //查询数据
    procedure GetResult;
    //获取结果
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UFormCtrl, UFormBase, USysGrid,
  USysConst, UBusinessPacker, USysBusiness;

class function TfFormOrdersAX.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormOrdersAX.Create(Application) do
  try
    Caption := '选择采购订单';

    if not GetProviderInfo(FProID, FProName) then Exit;
    LoadAXOrderInfo(FProID);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;

    if nP.FParamA = mrOK then
    begin
      nP.FParamB := PackerEncodeStr(FOrder);
    end;
  finally
    Free;
  end;
end;

class function TfFormOrdersAX.FormID: integer;
begin
  Result := cFI_FormOrdersAX;
end;

procedure TfFormOrdersAX.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListQuery, nIni);
  finally
    nIni.Free;
  end;

  FListA   := TStringList.Create;
  FListB   := TStringList.Create;
  FResults := TStringList.Create;
end;

procedure TfFormOrdersAX.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListQuery, nIni);
  finally
    nIni.Free;
  end;

  FListA.Free;
  FListB.Free;
  FResults.Free;
end;

//------------------------------------------------------------------------------
//Date: 2015-01-22
//Desc: 按指定类型查询
function TfFormOrdersAX.LoadAXOrderInfo(const nProID: string=''): Boolean;
var nData: string;
    nIdx, nInt: Integer;
begin
  FResults.Clear;
  Result := False;
  ListQuery.Items.Clear;

  nData := nProID;
  if not AXReadOrdersInfo(nData) then Exit;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(nData);
  nInt := StrToInt(FListA.Values['DataNum']);

  SetLength(FOrderItems, nInt);

  for nIdx:=0 to nInt-1 do
  begin
    FListB.Text := PackerDecodeStr(FListA.Values['Data' + IntToStr(nIdx)]);
    with FOrderItems[nIdx], FListB do
    begin
      FProvID   := FProID;
      FProvName := FProName;

      FStockNO  := Values['ItemID'];
      FStockName:= Values['ItemName'];
      FRestValue:= Values['Qty'];

      if FloatRelation(StrToFloat(FRestValue), 0, rtGreater) then
      with ListQuery.Items.Add do
      begin
        Caption := FStockNO;
        SubItems.Add(FStockName);
        SubItems.Add(FProvName);
        SubItems.Add(FRestValue);
        ImageIndex := cItemIconIndex;
      end;
    end;  
  end;

  ListQuery.ItemIndex := 0;
  Result := True;
end;

procedure TfFormOrdersAX.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditProvider.Text := Trim(EditProvider.Text);
  if not GetProviderInfo(FProID, FProName, EditProvider.Text) then Exit;

  LoadAXOrderInfo(FProID);
end;

//Desc: 获取结果
procedure TfFormOrdersAX.GetResult;
var nIdx: Integer;
begin
  FOrder := '';
  for nIdx:=Low(FOrderItems) to High(FOrderItems) do
  with FOrderItems[nIdx], FResults do
  begin
    if CompareText(FStockNO, ListQuery.Selected.Caption)=0 then
    begin
      Values['SQ_ProID']    := FProvID;
      Values['SQ_ProName']  := FProvName;
      Values['SQ_StockNO']  := FStockNO;
      Values['SQ_StockName']:= FStockName;
      Values['SQ_RestValue']:= FRestValue;
      Break;
    end;  
  end;

  FOrder := FResults.Text;
end;

procedure TfFormOrdersAX.ListQueryKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if ListQuery.ItemIndex > -1 then
    begin
      GetResult;
      ModalResult := mrOk;
    end;
  end;
end;

procedure TfFormOrdersAX.ListQueryDblClick(Sender: TObject);
begin
  if ListQuery.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end;
end;

procedure TfFormOrdersAX.BtnOKClick(Sender: TObject);
begin
  if ListQuery.ItemIndex > -1 then
  begin
    GetResult;
    ModalResult := mrOk;
  end else ShowMsg('请在查询结果中选择', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormOrdersAX, TfFormOrdersAX.FormID);
end.
