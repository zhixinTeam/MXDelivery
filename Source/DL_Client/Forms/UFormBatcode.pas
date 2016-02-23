{*******************************************************************************
  ����: dmzn@163.com 2015-01-16
  ����: ���ε�������
*******************************************************************************}
unit UFormBatcode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxCheckBox, cxTextEdit,
  dxLayoutControl, StdCtrls, cxMaskEdit, cxDropDownEdit, cxLabel;

type
  TfFormBatcode = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditPrefix: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    EditStock: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    dxLayout1Item6: TdxLayoutItem;
    EditInc: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditBase: TcxTextEdit;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Item8: TdxLayoutItem;
    EditLen: TcxTextEdit;
    Check1: TcxCheckBox;
    dxLayout1Item10: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    EditLow: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditHigh: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    CheckAutoNew: TcxCheckBox;
    dxLayout1Item13: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    cxLabel1: TcxLabel;
    dxLayout1Item14: TdxLayoutItem;
    dxLayout1Group7: TdxLayoutGroup;
    cxLabel2: TcxLabel;
    dxLayout1Item15: TdxLayoutItem;
    dxLayout1Group8: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item16: TdxLayoutItem;
    cxLabel3: TcxLabel;
    dxLayout1Item17: TdxLayoutItem;
    dxLayout1Group9: TdxLayoutGroup;
    EditWeek: TcxTextEdit;
    dxLayout1Item18: TdxLayoutItem;
    dxLayout1Group10: TdxLayoutGroup;
    cxLabel4: TcxLabel;
    dxLayout1Item19: TdxLayoutItem;
    dxLayout1Group11: TdxLayoutGroup;
    dxLayout1Group6: TdxLayoutGroup;
    procedure BtnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  protected
    { Protected declarations }
    FRecordID: string;
    //��¼���
    procedure LoadFormData(const nID: string);
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    //��֤����
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UAdjustForm, UFormCtrl, USysDB, USysConst;

class function TfFormBatcode.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormBatcode.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '���� - ���';
      FRecordID := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '���� - �޸�';
      FRecordID := nP.FParamA;
    end;

    LoadFormData(FRecordID); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBatcode.FormID: integer;
begin
  Result := cFI_FormBatch;
end;

procedure TfFormBatcode.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ReleaseCtrlData(Self);
end;

procedure TfFormBatcode.LoadFormData(const nID: string);
var nStr: string;
begin
  nStr := 'D_ParamB=Select D_ParamB,D_Value From %s Where D_Name=''%s'' ' +
          'And D_Index>=0 Order By D_Index DESC';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

  FDM.FillStringsData(EditStock.Properties.Items, nStr, 0, '.');
  AdjustCXComboBoxItem(EditStock, False);

  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Batcode, nID]);
    FDM.QueryTemp(nStr);

    with FDM.SqlTemp do
    begin
      nStr := FieldByName('B_Stock').AsString;
      SetCtrlData(EditStock, nStr);

      EditName.Text := FieldByName('B_Name').AsString;
      EditBase.Text := FieldByName('B_Base').AsString;
      EditLen.Text := FieldByName('B_Length').AsString;

      EditPrefix.Text := FieldByName('B_Prefix').AsString;
      EditInc.Text := FieldByName('B_Incement').AsString;
      Check1.Checked := FieldByName('B_UseDate').AsString = sFlag_Yes;

      EditValue.Text := FieldByName('B_Value').AsString;
      EditLow.Text := FieldByName('B_Low').AsString;
      EditHigh.Text := FieldByName('B_High').AsString;
      EditWeek.Text := FieldByName('B_Week').AsString;
      CheckAutoNew.Checked := FieldByName('B_AutoNew').AsString = sFlag_Yes;
    end;
  end;
end;

function TfFormBatcode.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditBase then
  begin
    Result := IsNumber(EditBase.Text, False);
    nHint := '���������';
  end else

  if Sender = EditInc then
  begin
    Result := IsNumber(EditInc.Text, False);
    nHint := '����������';
  end else

  if Sender = EditLen then
  begin
    Result := IsNumber(EditLen.Text, False);
    nHint := '�����볤��';
  end else

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text) > 0);
    nHint := '����������';
  end else

  if Sender = EditLow then
  begin
    Result := IsNumber(EditLow.Text, True) and (StrToFloat(EditLow.Text) >= 0);
    nHint := '�����볬������';
  end else

  if Sender = EditHigh then
  begin
    Result := IsNumber(EditHigh.Text, True) and (StrToFloat(EditHigh.Text) >= 0);
    nHint := '�����볬������';
  end else

  if Sender = EditWeek then
  begin
    Result := IsNumber(EditWeek.Text, False) and (StrToFloat(EditWeek.Text) >= 0);
    nHint := '����������ֵ';
  end;
end;

//Desc: ����
procedure TfFormBatcode.BtnOKClick(Sender: TObject);
var nStr,nU: string;
begin
  if not IsDataValid then Exit;
  //��֤��ͨ��

  if Check1.Checked then
       nU := sFlag_Yes
  else nU := sFlag_No;

  if FRecordID = '' then
       nStr := ''
  else nStr := SF('R_ID', FRecordID, sfVal);

  nStr := MakeSQLByStr([SF('B_Stock', GetCtrlData(EditStock)),
          SF('B_Name', EditName.Text),
          SF('B_Prefix', EditPrefix.Text),
          SF('B_Base', EditBase.Text, sfVal),
          SF('B_Length', EditLen.Text, sfVal),

          SF('B_Interval', EditInter.Text, sfVal),
          SF('B_Incement', EditInc.Text, sfVal),
          SF('B_UseDate', nU),
          SF('B_LastDate', sField_SQLServer_Now, sfVal)
          ], sTable_Batcode, nStr, FRecordID = '');
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOk;
  ShowMsg('���α���ɹ�', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormBatcode, TfFormBatcode.FormID);
end.
