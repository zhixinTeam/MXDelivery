{*******************************************************************************
  作者: dmzn@163.com 2010-3-3
  描述: 系统日志浏览
*******************************************************************************}
unit UFrameSysErrLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, cxMaskEdit, cxButtonEdit,
  dxLayoutControl, cxTextEdit, ADODB, cxContainer, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxLookAndFeels, cxLookAndFeelPainters;

type
  TfFrameSysErrLog = class(TfFrameNormal)
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit5: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditItem: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    procedure EditManPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //时间间隔
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //查询语句
  public
    { Public declarations }
    class function FrameID: integer; override;
    function DealCommand(Sender: TObject; const nCmd: integer): integer; override;
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UFormCtrl, UMgrControl, UFormDateFilter, UFrameBase,
  USysConst, USysDB;

class function TfFrameSysErrLog.FrameID: integer;
begin
  Result := cFI_FrameSysErrLog;
end;

procedure TfFrameSysErrLog.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameSysErrLog.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameSysErrLog.DealCommand(Sender: TObject; const nCmd: integer): integer;
var nParam: PFrameCommandParam;
begin
  Result := -1;
  nParam := Pointer(nCmd);

  if nParam.FCommand = cCmd_ViewSysLog then
  begin
    BringToFront;
    Application.ProcessMessages;

    FStart := Str2Date(nParam.FParamA);
    FEnd := Str2Date(nParam.FParamB);

    FWhere := nParam.FParamC;
    InitFormData(FWhere);
  end;
end;

function TfFrameSysErrLog.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  
  Result := 'Select * From %s Where E_Date>=''%s'' And E_Date<''%s''';
  Result := Format(Result, [sTable_SysErrLog, DateToStr(FStart), DateToStr(FEnd+1)]);
  if nWhere <> '' then Result := Result + ' And (' + nWhere + ')';
end;

//Desc: 执行查询
procedure TfFrameSysErrLog.EditManPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'E_KeyID like ''%' + EditTruck.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditItem then
  begin
    EditItem.Text := Trim(EditItem.Text);
    if EditItem.Text = '' then Exit;

    FWhere := 'E_ItemID like ''%' + EditItem.Text + '%''';
    InitFormData(FWhere);
  end;
end;

//Desc: 日期筛选
procedure TfFrameSysErrLog.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

initialization
  gControlManager.RegCtrl(TfFrameSysErrLog, TfFrameSysErrLog.FrameID);
end.
