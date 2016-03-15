{*******************************************************************************
  作者: fendou116688@163.com 2016/3/8
  描述: 获取收料口ID
*******************************************************************************}
unit UFormGetPurchLine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, cxMaskEdit, cxDropDownEdit;

type
  TfFormGetPurchLine = class(TfFormNormal)
    cxLabel1: TcxLabel;
    dxLayout1Item5: TdxLayoutItem;
    EditLineName: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditLineID: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditLineNameKeyPress(Sender: TObject; var Key: Char);
    procedure EditLineIDPropertiesChange(Sender: TObject);
  private
    { Private declarations }
    FParam: PFormCommandParam;
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
  IniFiles, ULibFun, UMgrControl, USysBusiness, USmallFunc, USysConst, USysDB,
  UAdjustForm, UDataModule;

class function TfFormGetPurchLine.FormID: integer;
begin
  Result := cFI_FormGetPurchLine;
end;

class function TfFormGetPurchLine.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;

  with TfFormGetPurchLine.Create(Application) do
  try
    FParam := nParam;
    InitFormData;

    FParam.FCommand := cCmd_ModalResult;
    FParam.FParamA := ShowModal;
  finally
    Free;
  end;
end;

procedure TfFormGetPurchLine.FormCreate(Sender: TObject);
begin
  inherited;
  AdjustCtrlData(Self);
  LoadFormConfig(Self);
end;

procedure TfFormGetPurchLine.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);
end;

procedure TfFormGetPurchLine.InitFormData;
var nStr: string;
begin
  nStr := 'D_Value=Select D_Value,D_Memo From %s Where D_Name=''%s'' Order By D_Value';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PurchLineItem]);

  FDM.FillStringsData(EditLineID.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditLineID, False);
  if EditLineID.Properties.Items.Count>0 then EditLineID.ItemIndex := 0;
end;

procedure TfFormGetPurchLine.EditLineNameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    BtnOK.Click;
  end else OnCtrlKeyPress(Sender, Key);
end;

//Desc: 保存磁卡
procedure TfFormGetPurchLine.BtnOKClick(Sender: TObject);
begin
  FParam.FParamB := GetCtrlData(EditLineID);
  FParam.FParamC := Trim(EditLineName.Text);
  ModalResult := mrOk;
  //done
end;

procedure TfFormGetPurchLine.EditLineIDPropertiesChange(Sender: TObject);
var nStr: string;
    nCom: TcxComboBox;
begin
  nCom := Sender as TcxComboBox;
  nStr := nCom.Text;
  System.Delete(nStr, 1, Length(GetCtrlData(nCom)) + 1);

  if Sender = EditLineID then
    EditLineName.Text := nStr;
end;

initialization
  gControlManager.RegCtrl(TfFormGetPurchLine, TfFormGetPurchLine.FormID);
end.
