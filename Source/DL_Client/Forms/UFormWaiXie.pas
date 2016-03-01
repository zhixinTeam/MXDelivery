{*******************************************************************************
  作者: dmzn@163.com 2016-02-27
  描述: 办理外协称重业务
*******************************************************************************}
unit UFormWaiXie;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit, cxLabel, ExtCtrls;

type
  TfFormWaiXie = class(TfFormNormal)
    EditTruck: TcxButtonEdit;
    dxlytmLayout1Item12: TdxLayoutItem;
    dxLayout1Item11: TdxLayoutItem;
    EditCusID: TcxComboBox;
    dxLayout1Item12: TdxLayoutItem;
    EditCusName: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditSender: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditSenderName: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditStock: TcxComboBox;
    dxLayout1Item6: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    Bevel1: TBevel;
    dxLayout1Item7: TdxLayoutItem;
    Bevel2: TBevel;
    dxLayout1Item9: TdxLayoutItem;
    Bevel3: TBevel;
    dxLayout1Item10: TdxLayoutItem;
    EditLine: TcxComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditCusIDPropertiesEditValueChanged(Sender: TObject);
  protected
    { Protected declarations }
    FListA: TStrings;
    //字符列表
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

class function TfFormWaiXie.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  with TfFormWaiXie.Create(Application) do
  try
    Caption := '外协入厂单';
    InitFormData;
    ActiveControl := EditTruck;
    
    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormWaiXie.FormID: integer;
begin
  Result := cFI_FormWaiXie;
end;

procedure TfFormWaiXie.FormCreate(Sender: TObject);
begin
  FListA := TStringList.Create;
  AdjustCtrlData(Self);
  LoadFormConfig(Self);
end;

procedure TfFormWaiXie.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIni.WriteInteger(Name, 'Customer', EditCusID.ItemIndex);
    nIni.WriteInteger(Name, 'Sender', EditSender.ItemIndex);
    nIni.WriteInteger(Name, 'ProductLine', EditLine.ItemIndex);

    SaveFormConfig(Self, nIni);
    ReleaseCtrlData(Self);
    FListA.Free;
  finally
    nIni.Free;
  end;
end;

//Desc: 回车键
procedure TfFormWaiXie.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
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

procedure TfFormWaiXie.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nChar: Char;
begin
  nChar := Char(VK_SPACE);
  EditLadingKeyPress(EditTruck, nChar);
end;

//------------------------------------------------------------------------------
procedure TfFormWaiXie.InitFormData;
var nStr: string;
    nIdx: Integer;
    nIni: TIniFile;
begin
  nStr := 'M_ID=Select M_ID,M_Name From %s Order By M_ID DESC';
  nStr := Format(nStr, [sTable_Materails]);

  FDM.FillStringsData(EditStock.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditStock, False);

  nStr := 'P_ID=Select P_ID,P_Name From %s Order By P_Name DESC';
  nStr := Format(nStr, [sTable_Provider]);

  FDM.FillStringsData(EditCusID.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditCusID, False);

  FDM.FillStringsData(EditSender.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditSender, False);

  nStr := 'Select P_Name From %s Order By P_Name DESC';
  nStr := Format(nStr, [sTable_Provider]);
  FDM.FillStringsData(EditLine.Properties.Items, nStr);

  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    nIdx := nIni.ReadInteger(Name, 'Customer', 0);
    if EditCusID.Properties.Items.Count > nIdx then
      EditCusID.ItemIndex := nIdx;
    //xxxxx

    nIdx := nIni.ReadInteger(Name, 'Sender', 0);
    if EditSender.Properties.Items.Count > nIdx then
      EditSender.ItemIndex := nIdx;
    //xxxxx

    nIdx := nIni.ReadInteger(Name, 'ProductLine', 0);
    if EditLine.Properties.Items.Count > nIdx then
      EditLine.ItemIndex := nIdx;
    //xxxxx
  finally
    nIni.Free;
  end;
end;

procedure TfFormWaiXie.EditCusIDPropertiesEditValueChanged(Sender: TObject);
var nStr: string;
    nCom: TcxComboBox;
begin
  nCom := Sender as TcxComboBox;
  nStr := nCom.Text;
  System.Delete(nStr, 1, Length(GetCtrlData(nCom)) + 1);

  if Sender = EditCusID then
    EditCusName.Text := nStr else
  if Sender = EditSender then
    EditSenderName.Text := nStr else
  if Sender = EditStock then
    EditStockName.Text := nStr;
  //xxxxx
end;

function TfFormWaiXie.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '车牌号长度应大于2位';
  end else

  if Sender = EditCusID then
  begin
    Result := EditCusID.ItemIndex >= 0;
    nHint := '请选择客户';
  end else

  if Sender = EditSender then
  begin
    Result := EditSender.ItemIndex >= 0;
    nHint := '请选择运输单位';
  end else

  if Sender = EditLine then
  begin
    EditLine.Text := Trim(EditLine.Text);
    Result := EditLine.Text <> '';
    nHint := '请填写产品线';
  end else

  if Sender = EditStock then
  begin
    Result := EditStock.ItemIndex >= 0;
    nHint := '请选择物料';
  end;
end;

//Desc: 保存
procedure TfFormWaiXie.BtnOKClick(Sender: TObject);
var nID: string;
begin
  if not IsDataValid then Exit;
  //check valid

  with FListA do
  begin
    Clear;
    Values['CusID'] := GetCtrlData(EditCusID);
    Values['CusName'] := EditCusName.Text;
    Values['Sender'] := GetCtrlData(EditSender);
    Values['SenderName'] := EditSenderName.Text;
    Values['ProductLine'] := EditLine.Text;
    Values['Stock'] := GetCtrlData(EditStock);
    Values['StockName'] := EditStockName.Text;
    Values['Truck'] := EditTruck.Text;
  end;

  nID := SaveWaiXie(PackerEncodeStr(FListA.Text));
  if nID = '' then Exit;
  SetWaiXieCard(nID, FListA.Values['Truck']);

  ModalResult := mrOK;
  ShowMsg('采购入厂单保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormWaiXie, TfFormWaiXie.FormID);
end.
