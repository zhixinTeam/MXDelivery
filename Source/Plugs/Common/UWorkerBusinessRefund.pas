{*******************************************************************************
  作者: fendou116688@163.com 2016/3/25
  描述: 销售退货称重业务对象
*******************************************************************************}
unit UWorkerBusinessRefund;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusinessCommand, UWorkerBusinessRemote, DateUtils;

type
  TWorkerBusinessRefund = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function SaveRefund(var nData: string): Boolean;
    //保存销售退货单
    function SaveRefundCard(var nData: string): Boolean;
    //保存销售退货磁卡
    function ChangeRefundTruck(var nData: string): Boolean;
    //修改销售退货车牌
    function DeleteRefund(var nData: string): Boolean;
    //删除销售退货单
    function GetPostItems(var nData: string): Boolean;
    //获取岗位单据
    function SavePostItems(var nData: string): Boolean;
    //保存岗位单据
    function AXSyncRefund(var nData: string): Boolean;
    //同步单据
    function VerifyBeforSave(var nData: string): Boolean;
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessRefund.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nPacker.InitData(@nIn, True, False);
    //init
    
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//------------------------------------------------------------------------------
class function TWorkerBusinessRefund.FunctionName: string;
begin
  Result := sBus_BusinessRefund;
end;

constructor TWorkerBusinessRefund.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessRefund.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessRefund.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessRefund.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessRefund.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveRefund          : Result := SaveRefund(nData);
   cBC_SaveRefundCard      : Result := SaveRefundCard(nData);
   cBC_ModifyRefundTruck   : Result := ChangeRefundTruck(nData);
   cBC_DeleteRefund        : Result := DeleteRefund(nData);
   cBC_GetPostBills        : Result := GetPostItems(nData);
   cBC_SavePostBills       : Result := SavePostItems(nData);
   cBC_AXSyncRefund        : Result := AXSyncRefund(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------ 
//Date: 2016-02-27
//Parm: 销售退货单号[FIn.FData]
//Desc: 同步销售退货单到AX
function TWorkerBusinessRefund.AXSyncRefund(var nData: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := sFlag_FixedNo + 'RF' + FIn.FData;
  Result := CallRemoteWorker(sAX_SyncRefund, FIn.FData, '', nStr, @nOut);

  if not Result then
    nData := nOut.FData;
  //xxxxx
end;

function TWorkerBusinessRefund.VerifyBeforSave(var nData: string): Boolean;
var nInt: Integer;
    nStr: string;
    nOutFact, nToday: TDateTime;
begin
  Result := False;

  nStr := 'Select F_ID From %s Where F_Truck=''%s'' And F_OutFact Is Null';
  nStr := Format(nStr, [sTable_Refund, FListA.Values['Truck']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nData := '车辆[ %s ]有未完成的销售退货单据[ %s ],请先处理.';
    nData := Format(nData, [FListA.Values['Truck'], Fields[0].AsString]);
    Exit;
  end;

  nStr := 'Select F_ID From %s Where F_LID=''%s''';
  nStr := Format(nStr, [sTable_Refund, FListA.Values['BillNO']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nData := '提货单[ %s ]已完成的销售退货单据[ %s ],不允许重复退货.';
    nData := Format(nData, [FListA.Values['BillNO'], Fields[0].AsString]);
    Exit;
  end;

  nStr := 'Select * From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FListA.Values['BillNO']]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr),FListA do
  begin
    Values['BillNO']   := FieldByName('L_ID').AsString;
    Values['BOutFact'] := FieldByName('L_OutFact').AsString;

    Values['CusID']    := FieldByName('L_CusID').AsString;
    Values['CusName']  := FieldByName('L_CusName').AsString;
    Values['CusPY']    := FieldByName('L_CusPY').AsString;

    Values['SaleID']   := FieldByName('L_SaleID').AsString;
    Values['SaleMan']  := FieldByName('L_SaleMan').AsString;
    
    Values['Type']     := FieldByName('L_Type').AsString;
    Values['StockNo']  := FieldByName('L_StockNo').AsString;
    Values['StockName']:= FieldByName('L_StockName').AsString;

    Values['Price']    := FieldByName('L_Price').AsString;
    Values['LimValue'] := FieldByName('L_Value').AsString;
  end;

  if FloatRelation(StrToFloat(FListA.Values['Value']),
    StrToFloat(FListA.Values['LimValue']), rtGreater) then
  begin
    nData := '禁止提货单[ %s ]退货量超出原提货量[ %s ]吨.';
    nData := Format(nData, [FListA.Values['BillNO'], FListA.Values['LimValue']]);
    Exit;
  end;    

  nToday   := Today;
  nOutFact := Str2DateTime(FListA.Values['BOutFact']);

  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_OutOfRefund]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
       nInt := Fields[0].AsInteger
  else nInt := 30;
  //默认30天

  if DaysBetween(nOutFact, nToday) > nInt then
  begin
    nData := '提货单[ %s ]出厂时间已超出退货时间限制[ %d ]天,不允许退货.';
    nData := Format(nData, [FListA.Values['BillNO'], nInt]);
    Exit;
  end;  


  Result := True;
  //verify done
end;

//Date: 2016-02-27
//Desc: 生成销售退货单
function TWorkerBusinessRefund.SaveRefund(var nData: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if not VerifyBeforSave(nData) then Exit;

  with FListC do
  begin
    Clear;
    Values['Group'] :=sFlag_BusGroup;
    Values['Object'] := sFlag_RefundNo;
  end;

  if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
        FListC.Text, sFlag_Yes, @nOut) then  //to get serial no
  begin
    nData := nOut.FData;
    Exit;
  end;

  FOut.FData := nOut.FData;
  //id

  FDBConn.FConn.BeginTrans;
  with FListA do
  try
    nStr := MakeSQLByStr([SF('F_ID', nOut.FData),
            SF('F_LID', Values['BillNO']),
            SF('F_LOutFact', Values['BOutFact']),

            SF('F_Truck', Values['Truck']),
            SF('F_CusID', Values['CusID']),
            SF('F_CusName', Values['CusName']),
            SF('F_CusPY', Values['CusPY']),

            SF('F_SaleID', Values['SaleID']),
            SF('F_SaleMan', Values['SaleMan']),
            SF('F_Type', Values['Type']),
            SF('F_StockNo', Values['StockNo']),
            SF('F_StockName', Values['StockName']),
            SF('F_Value', StrToFloat(Values['Value']), sfVal),
            SF('F_Price', StrToFloat(Values['Price']), sfVal),
            SF('F_LimValue', StrToFloat(Values['LimValue']), sfVal),

            SF('F_Status', sFlag_BillNew),
            SF('F_Man', FIn.FBase.FFrom.FUser),
            SF('F_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Refund, '', True);
    //xxxxx
    gDBConnManager.WorkerExec(FDBConn, nStr);

    if Values['Type'] = sFlag_Dai then
    begin
      nStr := MakeSQLByStr([SF('F_Status', sFlag_TruckOut),
              SF('F_InTime', sField_SQLServer_Now, sfVal),
              SF('F_PValue', 1, sfVal),
              SF('F_PDate', sField_SQLServer_Now, sfVal),
              SF('F_PMan', FIn.FBase.FFrom.FUser),
              SF('F_MValue', StrToFloat(FListA.Values['Value']) + 1, sfVal),
              SF('F_MDate', sField_SQLServer_Now, sfVal),
              SF('F_MMan', FIn.FBase.FFrom.FUser),
              SF('F_LadeTime', sField_SQLServer_Now, sfVal),
              SF('F_LadeMan', FIn.FBase.FFrom.FUser),
              SF('F_OutFact', sField_SQLServer_Now, sfVal),
              SF('F_OutMan', FIn.FBase.FFrom.FUser),
              SF('F_Card', '')
              ], sTable_Refund, SF('F_ID', nOut.FData), False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;
    //袋装直接完成退货  

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;


end;

//Date: 2016-02-27
//Parm: 单据[FIn.FData];磁卡[FIn.FExtParam]
//Desc: 保存销售退货单磁卡
function TWorkerBusinessRefund.SaveRefundCard(var nData: string): Boolean;
var nStr,nTruck: string;
    nIdx: Integer;
begin
  Result := False;
  nStr := 'Select F_Card,F_Truck From %s Where F_ID=''%s''';
  nStr := Format(nStr, [sTable_Refund, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '销售退货单据[ %s ]已丢失.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FListA.Clear;
    nTruck := Fields[1].AsString;
    
    if Fields[0].AsString <> '' then
    begin
      nStr := 'Update %s set C_TruckNo=Null,C_Status=''%s'' Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, sFlag_CardIdle, Fields[0].AsString]);
      FListA.Add(nStr); //磁卡状态
    end;
  end;

  nStr := 'Update %s Set F_Card=''%s'' Where F_ID=''%s''';
  nStr := Format(nStr, [sTable_Refund, FIn.FExtParam, FIn.FData]);
  FListA.Add(nStr);

  nStr := 'Select Count(*) From %s Where C_Card=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if Fields[0].AsInteger < 1 then
  begin
    nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
            SF('C_Status', sFlag_CardUsed),
            SF('C_Used', sFlag_Refund),
            SF('C_TruckNo', nTruck),
            SF('C_Freeze', sFlag_No),
            SF('C_Man', FIn.FBase.FFrom.FUser),
            SF('C_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Card, '', True);
    FListA.Add(nStr);
  end else
  begin
    nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
    nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
            SF('C_Used', sFlag_Refund),
            SF('C_TruckNo', nTruck),
            SF('C_Freeze', sFlag_No),
            SF('C_Man', FIn.FBase.FFrom.FUser),
            SF('C_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Card, nStr, False);
    FListA.Add(nStr);
  end;

  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=FListA.Count - 1 downto 0 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    on E: Exception do
    begin
      FDBConn.FConn.RollbackTrans;
      nData := E.Message;
    end;
  end;
end;

//Date: 2016-02-27
//Parm: 销售退货单[FIn.FData];车牌号[FIn.FExtParm]
//Desc: 修改单据的车牌
function TWorkerBusinessRefund.ChangeRefundTruck(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  Result := False;
  nStr := 'Select F_PDate,F_MDate,F_Card From %s Where F_ID=''%s''';
  nStr := Format(nStr, [sTable_Refund, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '销售退货单据[ %s ]已丢失.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FListA.Clear;
    if (Fields[0].AsFloat > 0) or (Fields[1].AsFloat > 0) then
    begin
      nStr := 'Update %s set P_Truck=''%s'' Where P_Bill=''%s''';
      nStr := Format(nStr, [sTable_PoundLog, FIn.FExtParam, FIn.FData]);
      FListA.Add(nStr); //称重记录
    end;

    if Fields[2].AsString <> '' then
    begin
      nStr := 'Update %s set C_TruckNo=''%s'' Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, FIn.FExtParam, Fields[2].AsString]);
      FListA.Add(nStr); //磁卡记录
    end;
  end;

  nStr := 'Update %s set F_Truck=''%s'' Where F_ID=''%s''';
  nStr := Format(nStr, [sTable_Refund, FIn.FExtParam, FIn.FData]);
  FListA.Add(nStr);

  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=FListA.Count - 1 downto 0 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    on E: Exception do
    begin
      FDBConn.FConn.RollbackTrans;
      nData := E.Message;
    end;
  end;
end;

//Date: 2016-02-27
//Parm: 销售退货单[FIn.FData]
//Desc: 删除销售退货单
function TWorkerBusinessRefund.DeleteRefund(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  nStr := 'Select F_Card From %s Where F_ID=''%s''';
  nStr := Format(nStr, [sTable_Refund, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '销售退货单据[ %s ]已丢失.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FListA.Clear;
    if Fields[0].AsString <> '' then
    begin
      nStr := 'Update %s set C_TruckNo=Null,C_Status=''%s'' Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, sFlag_CardIdle, Fields[0].AsString]);
      FListA.Add(nStr); //磁卡状态
    end; 
  end;

  //--------------------------------------------------------------------------
  nStr := Format('Select * From %s Where 1<>1', [sTable_Refund]);
  //only for fields
  nP := '';

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    for nIdx:=0 to FieldCount - 1 do
     if (Fields[nIdx].DataType <> ftAutoInc) and
        (Pos('F_Del', Fields[nIdx].FieldName) < 1) then
      nP := nP + Fields[nIdx].FieldName + ',';
    //所有字段,不包括删除

    System.Delete(nP, Length(nP), 1);
  end;

  nStr := 'Insert Into $RB($FL,F_DelMan,F_DelDate) ' +
          'Select $FL,''$User'',$Now From $RF Where F_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$RB', sTable_RefundBak),
          MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
          MI('$Now', sField_SQLServer_Now),
          MI('$RF', sTable_Refund), MI('$ID', FIn.FData)]);
  FListA.Add(nStr);

  nStr := 'Delete From %s Where F_ID=''%s''';
  nStr := Format(nStr, [sTable_Refund, FIn.FData]);
  FListA.Add(nStr);

  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    on E: Exception do
    begin
      FDBConn.FConn.RollbackTrans;
      nData := E.Message;
    end;
  end;
end;

//Date: 2016-02-28
//Parm: 磁卡号[FIn.FData];岗位[FIn.FExtParam]
//Desc: 获取特定岗位所需要的交货单列表
function TWorkerBusinessRefund.GetPostItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nBills: TLadingBillItems;
begin
  Result := False;
  nStr := 'Select C_Status,C_Freeze From %s Where C_Card=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FData]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('磁卡[ %s ]信息已丢失.', [FIn.FData]);
      Exit;
    end;

    if Fields[0].AsString <> sFlag_CardUsed then
    begin
      nData := '磁卡[ %s ]当前状态为[ %s ],无法使用.';
      nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
      Exit;
    end;

    if Fields[1].AsString = sFlag_Yes then
    begin
      nData := '磁卡[ %s ]已被冻结,无法使用.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  nStr := 'Select b.*,p.P_ID,p.P_PStation ' +
          'From $Bill b ' +
          '  Left Join $Pound p on p.P_Bill=b.F_ID ' +
          'Where b.F_Card=''$CD''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Refund),
          MI('$Pound', sTable_PoundLog),MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '销售退货磁卡[ %s ]没有关联有效单据.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with nBills[nIdx] do
    begin
      FID         := FieldByName('F_ID').AsString;
      FCusID      := FieldByName('F_CusID').AsString;
      FCusName    := FieldByName('F_CusName').AsString;
      FTruck      := FieldByName('F_Truck').AsString;

      FType       := FieldByName('F_Type').AsString;
      FStockNo    := FieldByName('F_StockNo').AsString;
      FStockName  := FieldByName('F_StockName').AsString;
      FValue      := FieldByName('F_StockName').AsFloat;

      FCard       := FieldByName('F_Card').AsString;
      FStatus     := FieldByName('F_Status').AsString;
      FNextStatus := FieldByName('F_NextStatus').AsString;

      FPoundID    := FieldByName('P_ID').AsString;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      with FPData do
      begin
        FDate   := FieldByName('F_PDate').AsDateTime;
        FValue  := FieldByName('F_PValue').AsFloat;
        FStation:= FieldByName('P_PStation').AsString;
        FOperator := FieldByName('F_PMan').AsString;
      end;

      FSelected := True; 
      Inc(nIdx);
      Next;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2016-02-28
//Parm: 销售退货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessRefund.SavePostItems(var nData: string): Boolean;
var nInt,nIdx: Integer;
    nSQL: string;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nBills);
  nInt := Length(nBills);
  //解析数据

  if nInt < 1 then
  begin
    nData := '岗位[ %s ]提交的单据为空.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '岗位[ %s ]提交了销售退货合单,该业务系统暂时不支持.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  FListA.Clear;
  //用于存储SQL列表
  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  with nBills[0] do
  begin
    FStatus := sFlag_TruckIn;
    FNextStatus := sFlag_TruckBFP;

    if FType = sFlag_Dai then
    begin
      nSQL := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nSQL := Format(nSQL, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
       if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
        FNextStatus := sFlag_TruckOut;
      //袋装不过磅
    end;

    nSQL := MakeSQLByStr([
            SF('F_Status', sFlag_TruckIn),
            SF('F_NextStatus', sFlag_TruckBFP),
            SF('F_InTime', sField_SQLServer_Now, sfVal),
            SF('F_InMan', FIn.FBase.FFrom.FUser)
            ], sTable_Refund, SF('F_ID', FID), False);
    FListA.Add(nSQL);
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //返回榜单号,用于拍照绑定
    with nBills[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;

      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Refund),
            SF('P_Bill', FID),
            SF('P_Truck', FTruck),
            SF('P_CusID', FCusID),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_LimValue', FValue),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_PDate', sField_SQLServer_Now, sfVal),
            SF('P_PMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '退货'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('F_Status', FStatus),
              SF('F_NextStatus', FNextStatus),
              SF('F_PValue', FPData.FValue, sfVal),
              SF('F_PDate', sField_SQLServer_Now, sfVal),
              SF('F_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Refund, SF('F_ID', FID), False);
      FListA.Add(nSQL);
    end; 
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    with nBills[0] do
    begin
      if FNextStatus = sFlag_TruckBFP then
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
        //称重时,由于皮重大,交换皮毛重数据

        nSQL := MakeSQLByStr([
                SF('F_Status', sFlag_TruckBFM),
                SF('F_NextStatus', sFlag_TruckOut),
                SF('F_PValue', FPData.FValue, sfVal),
                SF('F_PDate', sField_SQLServer_Now, sfVal),
                SF('F_PMan', FIn.FBase.FFrom.FUser),
                SF('F_MValue', FMData.FValue, sfVal),
                SF('F_MDate', DateTime2Str(FMData.FDate)),
                SF('F_MMan', FMData.FOperator)
                ], sTable_Refund, SF('F_ID', FID), False);
        FListA.Add(nSQL);

      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('F_Status', sFlag_TruckBFM),
                SF('F_NextStatus', sFlag_TruckOut),
                SF('F_MValue', FMData.FValue, sfVal),
                SF('F_MDate', sField_SQLServer_Now, sfVal),
                SF('F_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_Refund, SF('F_ID', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    nSQL := 'Select P_ID From %s Where P_Bill=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nBills[0].FID]);
    //未称毛重记录

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  with nBills[0] do
  begin
    nSQL := MakeSQLByStr([SF('F_Status', sFlag_TruckOut),
            SF('F_NextStatus', ''),
            SF('F_Card', ''),
            SF('F_OutFact', sField_SQLServer_Now, sfVal),
            SF('F_OutMan', FIn.FBase.FFrom.FUser)
            ], sTable_Refund, SF('F_ID', FID), False);
    FListA.Add(nSQL);

    nSQL := 'Update %s Set C_Status=''%s'',C_TruckNo=Null Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, nBills[0].FCard]);
    FListA.Add(nSQL); //磁卡
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessRefund, sPlug_ModuleBus);
end.
