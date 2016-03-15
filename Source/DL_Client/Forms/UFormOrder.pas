{*******************************************************************************
  作者: fendou116688@163.com 2015/9/19
  描述: 办理采购入厂单绑定磁卡
*******************************************************************************}
unit UFormOrder;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit, cxLabel;

type
  TfFormOrder = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditMate: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditProvider: TcxTextEdit;
    dxlytmLayout1Item3: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxlytmLayout1Item12: TdxLayoutItem;
    EditMateID: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditProID: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Group2: TdxLayoutGroup;
    EditFreeze: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditRest: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditFreeTruck: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditEnd: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    EditCYS: TcxComboBox;
    dxLayout1Item11: TdxLayoutItem;
    EditCYName: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    EditLineID: TcxComboBox;
    dxLayout1Item13: TdxLayoutItem;
    EditLine: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditCYSPropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FCardData, FListA: TStrings;
    //卡片数据
    FNewBillID: string;
    //新提单号
    FBuDanFlag: string;
    //补单标记
    procedure InitFormData;
    //初始化界面
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, DB, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker,
  UDataModule, USysBusiness, USysDB, USysGrid, USysConst;

class function TfFormOrder.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr, nFreeV, nFreeC: string;
    nP: PFormCommandParam;
begin
  Result := nil;
  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  try
    CreateBaseFormItem(cFI_FormOrdersAX, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nStr := nP.FParamB;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormOrder.Create(Application) do
  try
    Caption := '开采购入厂单';
    ActiveControl := EditTruck;

    FCardData.Text := PackerDecodeStr(nStr);

    nFreeV := FCardData.Values['SQ_ProID'];
    nFreeC := FCardData.Values['SQ_StockNo'];
    if not GetPurchFreeze(nFreeV, nFreeC) then Exit;

    FCardData.Values['SQ_Freeze'] := nFreeV;
    FCardData.Values['SQ_FreeCount'] := nFreeC;

    InitFormData;
    //xxxx

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := FNewBillID
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormOrder.FormID: integer;
begin
  Result := cFI_FormOrder;
end;

procedure TfFormOrder.FormCreate(Sender: TObject);
begin
  FListA    := TStringList.Create;
  FCardData := TStringList.Create;
  AdjustCtrlData(Self);
  LoadFormConfig(Self);
end;

procedure TfFormOrder.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);

  FListA.Free;
  FCardData.Free;
end;

//Desc: 回车键
procedure TfFormOrder.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditValue then
         BtnOK.Click
    else Perform(WM_NEXTDLGCTL, 0, 0);
  end;

  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

procedure TfFormOrder.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nChar: Char;
begin
  nChar := Char(VK_SPACE);
  EditLadingKeyPress(EditTruck, nChar);
end;

//------------------------------------------------------------------------------
procedure TfFormOrder.InitFormData;
var nStr: string;
begin
  with FCardData do
  begin
    EditProID.Text    := Values['SQ_ProID'];
    EditProvider.Text := Values['SQ_ProName'];
    EditMateID.Text   := Values['SQ_StockNo'];
    EditMate.Text     := Values['SQ_StockName'];
    EditRest.Text     := Values['SQ_RestValue'];

    EditFreeze.Text   := Values['SQ_Freeze'];
    EditFreeTruck.Text:= Values['SQ_FreeCount'];

    EditEnd.Text      := FloatToStr(Float2Float(StrToFloat(Values['SQ_RestValue']) -
                         StrToFloat(Values['SQ_Freeze']), cPrecision, False));
  end;

  nStr := 'P_ID=Select P_ID,P_Name From %s Where P_Type=''%s'' Order By P_Name DESC';
  nStr := Format(nStr, [sTable_Provider, sFlag_ProvideC]);

  FDM.FillStringsData(EditCYS.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditCYS, False);
  if EditCYS.Properties.Items.Count>0 then EditCYS.ItemIndex := 0;

  nStr := 'D_Value=Select D_Value,D_Memo From %s Where D_Name=''%s'' Order By D_Value';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PurchLineItem]);

  FDM.FillStringsData(EditLineID.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditLineID, False);
  EditLineID.ItemIndex := -1;
end;

function TfFormOrder.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '车牌号长度应大于2位';
  end else

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    nHint := '请填写有效的办理量';
    if not Result then Exit;

    nVal := StrToFloat(EditValue.Text);
    Result := FloatRelation(nVal, StrToFloat(EditEnd.Text),
              rtLE);
    nHint := '已超出可提货量';
  end;
end;

//Desc: 保存
procedure TfFormOrder.BtnOKClick(Sender: TObject);
var nOrder: string;
begin
  if not IsDataValid then Exit;
  //check valid

  with FListA do
  begin
    Clear;
    Values['Truck']         := Trim(EditTruck.Text);

    Values['ProviderID']    := FCardData.Values['SQ_ProID'];
    Values['ProviderName']  := FCardData.Values['SQ_ProName'];

    Values['ChengYunID']    := GetCtrlData(EditCYS);
    Values['ChengYunName']  := EditCYName.Text;

    Values['LineID']        := GetCtrlData(EditLineID);
    Values['LineName']      := EditLine.Text;

    Values['StockNO']       := FCardData.Values['SQ_StockNo'];
    Values['StockName']     := FCardData.Values['SQ_StockName'];
    Values['Value']         := Trim(EditValue.Text);
  end;

  nOrder := SaveOrder(PackerEncodeStr(FListA.Text));
  if nOrder='' then Exit;
  SetOrderCard(nOrder, FListA.Values['Truck']);

  ModalResult := mrOK;
  ShowMsg('采购入厂单保存成功', sHint);
end;

procedure TfFormOrder.EditCYSPropertiesChange(Sender: TObject);
var nStr: string;
    nCom: TcxComboBox;
begin
  nCom := Sender as TcxComboBox;
  nStr := nCom.Text;
  System.Delete(nStr, 1, Length(GetCtrlData(nCom)) + 1);

  if Sender = EditCYS then
    EditCYName.Text := nStr
  else if Sender = EditLineID then
    EditLine.Text := nStr; 
  //xxxxx  
end;

initialization
  gControlManager.RegCtrl(TfFormOrder, TfFormOrder.FormID);
end.
