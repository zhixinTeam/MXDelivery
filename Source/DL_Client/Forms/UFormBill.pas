{*******************************************************************************
  ����: dmzn@163.com 2014-09-01
  ����: �������
*******************************************************************************}
unit UFormBill;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit;

type
  TfFormBill = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditCus: TcxTextEdit;
    dxlytmLayout1Item3: TdxLayoutItem;
    EditCName: TcxTextEdit;
    dxlytmLayout1Item4: TdxLayoutItem;
    EditJXMan: TcxTextEdit;
    dxlytmLayout1Item5: TdxLayoutItem;
    EditDate: TcxTextEdit;
    dxlytmLayout1Item6: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxlytmLayout1Item9: TdxLayoutItem;
    EditSName: TcxTextEdit;
    dxlytmLayout1Item10: TdxLayoutItem;
    EditMax: TcxTextEdit;
    dxlytmLayout1Item11: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxlytmLayout1Item12: TdxLayoutItem;
    dxlytmLayout1Item13: TdxLayoutItem;
    EditType: TcxComboBox;
    dxlytmLayout1Item14: TdxLayoutItem;
    EditFQ: TcxTextEdit;
    dxGroupLayout1Group6: TdxLayoutGroup;
    dxGroupLayout1Group4: TdxLayoutGroup;
    dxGroupLayout1Group7: TdxLayoutGroup;
    dxGroupLayout1Group3: TdxLayoutGroup;
    EditMan: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    ListStock: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditCard: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListStockPropertiesChange(Sender: TObject);
  protected
    { Protected declarations }
    FCardData,FListA: TStrings;
    //��Ƭ����
    FNewBillID: string;
    //���ᵥ��
    FBuDanFlag: string;
    //�������
    procedure InitFormData;
    //��ʼ������
    procedure LoadCardInfo(const nIdx: Integer);
    //��ȡ��Ƭ��Ϣ
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

class function TfFormBill.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr: string;
    nP: PFormCommandParam;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  try
    CreateBaseFormItem(cFI_FormBillNew, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nStr := nP.FParamB;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormBill.Create(Application) do
  try
    Caption := '����';
    ActiveControl := EditTruck;

    FCardData.Text := PackerDecodeStr(nStr);
    InitFormData;

    if nPopedom = 'MAIN_D04' then //����
         FBuDanFlag := sFlag_Yes
    else FBuDanFlag := sFlag_No;

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

class function TfFormBill.FormID: integer;
begin
  Result := cFI_FormBill;
end;

procedure TfFormBill.FormCreate(Sender: TObject);
begin
  FCardData := TStringList.Create;
  FListA := TStringList.Create;

  AdjustCtrlData(Self);
  LoadFormConfig(Self);
end;

procedure TfFormBill.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);

  FCardData.Free;
  FListA.Free;
end;

//Desc: �س���
procedure TfFormBill.EditLadingKeyPress(Sender: TObject; var Key: Char);
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

procedure TfFormBill.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nChar: Char;
begin
  nChar := Char(VK_SPACE);
  EditLadingKeyPress(EditTruck, nChar);
end;

procedure TfFormBill.ListStockPropertiesChange(Sender: TObject);
begin
  LoadCardInfo(ListStock.ItemIndex);
end;

//------------------------------------------------------------------------------
procedure TfFormBill.InitFormData;
var nIdx,nNum: Integer;
begin
  with FCardData,ListStock do
  begin
    Properties.Items.Clear;
    nNum := StrToInt(Values['DataNum']);
                                            
    for nIdx:=0 to nNum-1 do
    begin
      FListA.Text := PackerDecodeStr(Values['Data' + IntToStr(nIdx)]);
      Properties.Items.Add(FListA.Values['ItemID'] + FListA.Values['ItemName']);
    end;

    {$IFDEF DEBUG}
    if nNum > 0 then
      ItemIndex := 0;
    {$ELSE}
    ItemIndex := -1;
    {$ENDIF}
    ListStock.SelStart := 1;
  end;
end;

//Date: 2016-01-30
//Parm: ��ϸ����
//Desc: ��ȡnIdx����Ƭ��Ϣ������
procedure TfFormBill.LoadCardInfo(const nIdx: Integer);
begin
  if nIdx < 0 then Exit;
  FCardData.Values['DataIndex'] := IntToStr(nIdx);
  FListA.Text := PackerDecodeStr(FCardData.Values['Data' + IntToStr(nIdx)]);

  with FListA do
  begin
    EditCard.Text   := Values['Card'];
    EditCus.Text    := Values['CustAccount'];
    EditCName.Text  := Values['CustName'];
    EditJXMan.Text  := Values['DealerAccount'] + '.' + Values['DealerName'];
    EditMan.Text    := gSysParam.FUserID;
    EditDate.Text   := DateTime2Str(Now);

    EditStock.Text  := Values['ItemID'];
    EditSName.Text  := Values['ItemName'];
    EditMax.Text    := Values['Qty'];
    EditFQ.Text     := GetStockBatcode(EditStock.Text, 0);
  end;
end;

function TfFormBill.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = ListStock then
  begin
    Result := ListStock.ItemIndex >= 0;
    nHint := '����ѡ������';
  end;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '���ƺų���Ӧ����2λ';
  end else

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    nHint := '����д��Ч�İ�����';
  end else

  if Sender = EditFQ then
  begin
    Result := Trim(EditFQ.Text) <> '';
    nHint := '���κ���Ч,�޷�����';
  end;
end;

//Desc: ����
procedure TfFormBill.BtnOKClick(Sender: TObject);
var nStr: string;
    nPrint: Boolean;
    nList,nStocks: TStrings;
begin
  if not IsDataValid then Exit;
  //check valid

  nStocks := TStringList.Create;
  nList := TStringList.Create;
  try
    nList.Clear;
    nPrint := False;
    LoadSysDictItem(sFlag_PrintBill, nStocks);
    //���ӡƷ��

    nStr := 'Data' + FCardData.Values['DataIndex'];
    FListA.Text := PackerDecodeStr(FCardData.Values[nStr]);
     
    with nList do
    begin
      Values['ZhiKa'] := PackerEncodeStr(FCardData.Text);
      Values['DataIndex'] := FCardData.Values['DataIndex'];
      //ѡ��Ʒ������

      Values['StockNO'] := FListA.Values['ItemID'];
      Values['StockName'] := FListA.Values['ItemName'];
      Values['Type'] := FListA.Values['ItemType'];
      Values['Value'] := EditValue.Text;

      Values['Truck'] := EditTruck.Text;
      Values['Lading'] := sFlag_TiHuo;
      Values['IsVIP'] := GetCtrlData(EditType);
      Values['HYDan'] := EditFQ.Text;
      Values['BuDan'] := FBuDanFlag;
    end;

    if (not nPrint) and (FBuDanFlag <> sFlag_Yes) then
      nPrint := nStocks.IndexOf(FListA.Values['ItemID']) >= 0;
    //xxxxx

    FNewBillID := SaveBill(PackerEncodeStr(nList.Text));
    //call mit bus
    if FNewBillID = '' then Exit;
  finally
    nList.Free;
  end;

  if FBuDanFlag <> sFlag_Yes then
    SetBillCard(FNewBillID, EditTruck.Text, True);
  //����ſ�

  if nPrint then
    PrintBillReport(FNewBillID, True);
  //print report

  ModalResult := mrOk;
  ShowMsg('���������ɹ�', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormBill, TfFormBill.FormID);
end.
