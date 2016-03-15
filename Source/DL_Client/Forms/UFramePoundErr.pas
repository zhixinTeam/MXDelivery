{*******************************************************************************
  作者: fendou116688@163.com 2016/3/11
  描述: 处理过磅错误
*******************************************************************************}
unit UFramePoundErr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, Menus,
  UBitmapPanel, cxSplitter, cxLookAndFeels, cxLookAndFeelPainters,
  cxCheckBox;

type
  TfFramePoundErr = class(TfFrameNormal)
    EditCus: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditLID: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    Edit1: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnEditClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
  protected
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, USysPopedom, ShellAPI, UFormWait,
  USysConst, USysDB, USysBusiness, UFormDateFilter, UBusinessConst,
  UFormCtrl;

//------------------------------------------------------------------------------
class function TfFramePoundErr.FrameID: integer;
begin
  Result := cFI_FramePoundErr;
end;

procedure TfFramePoundErr.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFramePoundErr.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 数据查询SQL
function TfFramePoundErr.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  FEnableBackDB := True;

  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From $PoundErr ';
  //提货单

  if (nWhere = '') or FUseDate then
  begin
    Result := Result + 'Where (E_Date>=''$ST'' and E_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [MI('$PoundErr', sTable_PoundErr),
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

procedure TfFramePoundErr.AfterInitFormData;
begin
  FUseDate := True;
end;

//Desc: 执行查询
procedure TfFramePoundErr.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditLID then
  begin
    EditLID.Text := Trim(EditLID.Text);
    if EditLID.Text = '' then Exit;

    FUseDate := Length(EditLID.Text) <= 3;
    FWhere := 'E_SrcID like ''%' + EditLID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'E_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FUseDate := Length(EditTruck.Text) <= 3;
    FWhere := Format('E_Truck like ''%%%s%%''', [EditTruck.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: 日期筛选
procedure TfFramePoundErr.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

procedure TfFramePoundErr.BtnEditClick(Sender: TObject);
var nInt, nIdx: Integer;
    nP: TFormCommandParam;
    nStr, nPost, nPID, nHint, nEID: string;
    nPounds, nPoundTmps: TLadingBillItems;
begin
  inherited;
  //显示通过或者不通过
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要处理的记录', sHint); Exit;
  end;

  if SQLQuery.FieldByName('E_Valid').AsString = sFlag_Yes then
  begin
    ShowMsg('错误已处理', sHint); Exit;
  end;

  nEID := SQLQuery.FieldByName('E_ID').AsString;
  nPID := SQLQuery.FieldByName('E_SrcID').AsString;
  nPost:= SQLQuery.FieldByName('E_SrcNextStatus').AsString;

  nStr := '确定开始处理编号为[ %s ]的单据吗?';
  nStr := Format(nStr, [nEID]);
  if not QueryDlg(nStr, sAsk) then Exit;

  SetLength(nPounds, 0);
  SetLength(nPoundTmps, 0);

  nStr := SQLQuery.FieldByName('E_Card').AsString;
  if not GetLadingBills(nStr, nPost , nPoundTmps) then Exit;

  nInt := 0;
  for nIdx:=Low(nPoundTmps) to High(nPoundTmps) do
  with nPoundTmps[nIdx] do
  begin
    if (FStatus <> sFlag_TruckBFP) and (FNextStatus = sFlag_TruckZT) then
      FNextStatus := sFlag_TruckBFP;
    //状态校正

    FSelected := FNextStatus = nPost;
    //可称重状态判定

    if FSelected then
    begin
      Inc(nInt);
      Continue;
    end;

    nStr := '※.单号:[ %s ] 状态:[ %-6s -> %-6s ]   ';
    if nIdx < High(nPoundTmps) then nStr := nStr + #13#10;

    nStr := Format(nStr, [FID, TruckStatusToStr(FStatus),
                               TruckStatusToStr(FNextStatus)]);
    nHint := nHint + nStr;
  end;

  if nInt = 0 then
  begin
    nHint := '该车辆当前不能放行,详情如下: ' + #13#10#13#10 + nHint;
    ShowDlg(nHint, sHint);
    Exit;
  end;

  SetLength(nPounds, nInt);
  nInt := 0;

  for nIdx:=Low(nPoundTmps) to High(nPoundTmps) do
  with nPoundTmps[nIdx] do
  begin
    if FSelected then
    begin
      FPoundID := '';
      //该标记有特殊用途
      nPounds[nInt] := nPoundTmps[nIdx];
      Inc(nInt);
    end;
  end;

  nInt := 0;
  for nIdx:=Low(nPounds) to High(nPounds) do
  with nPounds[nInt] do
  begin
    if CompareStr(FID, nPID) = 0 then
    begin
      with FPData do
      begin
        FStation := SQLQuery.FieldByName('E_PStation').AsString;
        FValue   := SQLQuery.FieldByName('E_PValue').AsFloat;
      end;  

      with FMData do
      begin
        FStation := SQLQuery.FieldByName('E_MStation').AsString;
        FValue   := SQLQuery.FieldByName('E_MValue').AsFloat;
      end;

      FPoundID := sFlag_Yes;
      Inc(nInt);
    end;
  end;

  if nInt = 0 then
  begin
    nHint := '该车辆错误信息已处理！';
    ShowDlg(nHint, sHint);
    Exit;
  end;

  nP.FParamA := CombineBillItmes(nPounds);
  nP.FParamB := SQLQuery.FieldByName('E_Memo').AsString;
  CreateBaseFormItem(cFI_FormDealPoundErr, '', @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

  if not SaveLadingBills(nPost, nPounds) then Exit;

  nStr := MakeSQLByStr([
          SF('E_Valid', sFlag_Yes),
          SF('E_DealMemo', nP.FParamB),
          SF('E_DealMan', gSysParam.FUserID),
          SF('E_DealDate', sField_SQLServer_Now, sfVal)
          ], sTable_PoundErr, SF('E_ID', nEID), False);
  FDM.ExecuteSQL(nStr);
  InitFormData('');
end;

procedure TfFramePoundErr.N1Click(Sender: TObject);
var nStr,nID,nDir: string;
    nPic: TPicture;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要查看的记录', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('E_ID').AsString;
  nDir := gSysParam.FPicPath + nID + '\';

  if DirectoryExists(nDir) then
  begin
    ShellExecute(GetDesktopWindow, 'open', PChar(nDir), nil, nil, SW_SHOWNORMAL);
    Exit;
  end else ForceDirectories(nDir);

  nPic := nil;
  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_Picture, nID]);

  ShowWaitForm(ParentForm, '读取图片', True);
  try
    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('本次称重无抓拍', sHint);
        Exit;
      end;

      nPic := TPicture.Create;
      First;

      While not eof do
      begin
        nStr := nDir + Format('%s_%s.jpg', [FieldByName('P_ID').AsString,
                FieldByName('R_ID').AsString]);
        //xxxxx

        FDM.LoadDBImage(FDM.SqlTemp, 'P_Picture', nPic);
        nPic.SaveToFile(nStr);
        Next;
      end;
    end;

    ShellExecute(GetDesktopWindow, 'open', PChar(nDir), nil, nil, SW_SHOWNORMAL);
    //open dir
  finally
    nPic.Free;
    CloseWaitForm;
    FDM.SqlTemp.Close;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFramePoundErr, TfFramePoundErr.FrameID);
end.
