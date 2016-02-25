{*******************************************************************************
  作者: dmzn@163.com 2013-12-04
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusinessOrders;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusinessCommand, UWorkerBusinessRemote;

type
  TWorkerBusinessOrders = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton

    function VerifyBeforSave(var nData: string): Boolean;
    function SaveOrder(var nData: string):Boolean;
    function DeleteOrder(var nData: string): Boolean;
    function SaveOrderCard(var nData: string): Boolean;
    function LogoffOrderCard(var nData: string): Boolean;
    function ChangeOrderTruck(var nData: string): Boolean;
    //修改车牌号
    function GetGYOrderValue(var nData: string): Boolean;
    //获取供应可收货量

    function GetPostOrderItems(var nData: string): Boolean;
    //获取岗位采购单
    function SavePostOrderItems(var nData: string): Boolean;
    //保存岗位采购单
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
    class function VerifyTruckNO(nTruck: string; var nData: string): Boolean;
    //验证车牌是否有效
  end;

implementation

//------------------------------------------------------------------------------
class function TWorkerBusinessOrders.FunctionName: string;
begin
  Result := sBus_BusinessPurchaseOrder;
end;

constructor TWorkerBusinessOrders.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessOrders.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessOrders.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessOrders.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessOrders.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveOrder            : Result := SaveOrder(nData);
   cBC_DeleteOrder          : Result := DeleteOrder(nData);
   cBC_SaveOrderCard        : Result := SaveOrderCard(nData);
   cBC_LogoffOrderCard      : Result := LogoffOrderCard(nData);
   cBC_ModifyBillTruck      : Result := ChangeOrderTruck(nData);
   cBC_GetPostOrders        : Result := GetPostOrderItems(nData);
   cBC_SavePostOrders       : Result := SavePostOrderItems(nData);
   cBC_GetGYOrderValue      : Result := GetGYOrderValue(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/20
//Parm: 供应商编号(FIn.FData); 物料编号(FIn.FExtParam);
//Desc: 获取供应可收货量
function TWorkerBusinessOrders.GetGYOrderValue(var nData: string): Boolean;
var nInt, nIdx: Integer;
    nVal, nFreezeVal: Double;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  //init

  FIn.FData := UpperCase(FIn.FData);
  FIn.FExtParam := UpperCase(FIn.FExtParam);

  if not TWorkerBusinessCommander.CallMe(cBC_GetPurchFreeze,
    FIn.FData, FIn.FExtParam, @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end;
  nFreezeVal := StrToFloat(nOut.FData);
  //获取冻结量

  if not TAXWorkerReadOrdersInfo.CallMe(FIn.FData, @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end;
  //获取可用余量

  FListB.Clear;
  FListB.Text := PackerDecodeStr(nOut.FData);
  nInt := StrToInt(FListB.Values['DataNum']);

  nVal := 0;
  for nIdx:=0 to nInt-1 do
  begin
    FListC.Text := PackerDecodeStr(FListB.Values['Data' + IntToStr(nIdx)]);
    if CompareText(FIn.FData, FListC.Values['ItemID'])=0 then
    begin
      nVal := StrToFloat(FListC.Values['Qty']);

      Break;
    end;
  end;

  nVal := nVal - nFreezeVal;
  nVal := Float2Float(nVal, cPrecision, False);

  FOut.FData := FloatToStr(nVal);
  Result := True;
end;

//Date: 2014-09-16
//Parm: 车牌号;
//Desc: 验证nTruck是否有效
class function TWorkerBusinessOrders.VerifyTruckNO(nTruck: string;
  var nData: string): Boolean;
var nIdx: Integer;
    nWStr: WideString;
begin
  Result := False;
  nIdx := Length(nTruck);
  if (nIdx < 3) or (nIdx > 10) then
  begin
    nData := '有效的车牌号长度为3-10.';
    Exit;
  end;

  nWStr := LowerCase(nTruck);
  //lower
  
  for nIdx:=1 to Length(nWStr) do
  begin
    case Ord(nWStr[nIdx]) of
     Ord('-'): Continue;
     Ord('0')..Ord('9'): Continue;
     Ord('a')..Ord('z'): Continue;
    end;

    if nIdx > 1 then
    begin
      nData := Format('车牌号[ %s ]无效.', [nTruck]);
      Exit;
    end;
  end;

  Result := True;
end;

function TWorkerBusinessOrders.VerifyBeforSave(var nData: string): Boolean;
var nIdx, nInt: Integer;
    nStr,nTruck: string;
    nFreezeVal, nRVal, nVal: Double;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nTruck := FListA.Values['Truck'];
  if not VerifyTruckNO(nTruck, nData) then Exit;

  nStr := 'Select P_ID From %s Where P_Truck=''%s'' And P_OutFact Is Null';
  nStr := Format(nStr, [sTable_PurchInfo, nTruck]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := '车辆[ %s ]在未完成[ %s ]入厂单之前禁止开单.';
    nData := Format(nStr, [nTruck, Fields[0].AsString]);
    Exit;
  end;

  if not TWorkerBusinessCommander.CallMe(cBC_GetPurchFreeze,
    FListA.Values['ProviderID'], FListA.Values['StockNo'], @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end;
  nFreezeVal := StrToFloat(nOut.FData);
  //获取冻结量

  if not TAXWorkerReadOrdersInfo.CallMe(FListA.Values['ProviderID'], @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end;
  //获取可用余量

  FListB.Clear;
  FListB.Text := PackerDecodeStr(nOut.FData);
  nInt := StrToInt(FListB.Values['DataNum']);

  nVal := StrToFloat(FListA.Values['Value']);
  for nIdx:=0 to nInt-1 do
  begin
    FListC.Text := PackerDecodeStr(FListB.Values['Data' + IntToStr(nIdx)]);
    if CompareText(FListA.Values['StockNo'], FListC.Values['ItemID'])=0 then
    begin
      nRVal := StrToFloat(FListC.Values['Qty']);
      if FloatRelation(nVal + nFreezeVal, nRVal, rtGreater) then
      begin
        nData := '订单剩余量不足,详情如下: ' + #13#10#13#10 +
                 '*.AX系统剩余量: %.2f' + #13#10 +
                 '*.DL系统冻结量: %.2f' + #13#10 +
                 '*.本次预供应量: %.2f' + #13#10 +
                 '请联系AX系统管理员,重新开单。';
        nData := Format(nData, [nRVal, nFreezeVal, nVal]);
        Exit;
      end;

      Break;
    end;
  end;

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //保存车牌号

  Result := True;
  //verify done
end;

//Date: 2015-8-5
//Desc: 保存采购单
function TWorkerBusinessOrders.SaveOrder(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nOut: TWorkerBusinessCommand;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  if not VerifyBeforSave(nData) then Exit;
  //unpack Order

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    FListC.Clear;
    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PurchInfo;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := FOut.FData + nOut.FData + ',';
    //combine Order

    nStr := MakeSQLByStr([SF('P_ID', nOut.FData),
            SF('P_ProID', FListA.Values['ProviderID']),
            SF('P_ProName', FListA.Values['ProviderName']),
            SF('P_ProPY', GetPinYinOfStr(FListA.Values['ProviderName'])),

            SF('P_Type', sFlag_San),
            SF('P_StockNo', FListA.Values['StockNO']),
            SF('P_StockName', FListA.Values['StockName']),
            SF('P_Value', FListA.Values['Value'], sfVal),

            SF('P_Truck', FListA.Values['Truck']),
            SF('P_Status', sFlag_TruckNone),
            SF('P_Man', FIn.FBase.FFrom.FUser),
            SF('P_Date', sField_SQLServer_Now, sfVal)
            ], sTable_PurchInfo, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Freeze=C_Freeze+%s, C_Count=C_Count+1 ' +
            'Where C_ID=''%s'' And C_Stock=''%s''';
    nStr := Format(nStr, [sTable_AX_OrderInfo, FListA.Values['Value'],
            FListA.Values['ProviderID'], FListA.Values['StockNo']]);

    if gDBConnManager.WorkerExec(FDBConn, nStr)<1 then
    begin
      nStr := 'Insert Into %s(C_Freeze, C_Count, C_ID, C_Stock) ' +
              'Values(%s, 1, ''%s'', ''%s'')';
      nStr := Format(nStr, [sTable_AX_OrderInfo, FListA.Values['Value'],
            FListA.Values['ProviderID'], FListA.Values['StockNo']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);      
    end;          

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx
    
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015-8-5
//Desc: 保存采购单
function TWorkerBusinessOrders.DeleteOrder(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
    nHasOut: Boolean;
begin
  Result := False;
  //init

  nStr := 'Select P_OutFact From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PurchInfo, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '采购单[ %s ]已无效.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nHasOut := FieldByName('P_OutFact').AsString <> '';
    //已出厂

    if nHasOut then
    begin
      nData := '采购单[ %s ]已出厂,不允许删除.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_PurchInfo]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('P_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $PB($FL,P_DelMan,P_DelDate) ' +
            'Select $FL,''$User'',$Now From $PP Where P_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$PB', sTable_PurchInfoBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$PP', sTable_PurchInfo), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PurchInfo, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 采购订单[FIn.FData];磁卡号[FIn.FExtParam]
//Desc: 为采购单绑定磁卡
function TWorkerBusinessOrders.SaveOrderCard(var nData: string): Boolean;
var nStr,nSQL,nTruck: string;
begin
  Result := False;
  nTruck := '';

  FListB.Text := FIn.FExtParam;
  //磁卡列表
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //采购单列表

  nSQL := 'Select P_ID,P_Card,P_Truck From %s Where P_ID In (%s)';
  nSQL := Format(nSQL, [sTable_PurchInfo, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('采购订单[ %s ]已丢失.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      nStr := FieldByName('P_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '采购单[ %s ]的车牌号不一致,不能并单.' + #13#10#13#10 +
                 '*.本单车牌: %s' + #13#10 +
                 '*.其它车牌: %s' + #13#10#13#10 +
                 '相同牌号才能并单,请修改车牌号,或者单独办卡.';
        nData := Format(nData, [FieldByName('O_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('P_Card').AsString;
      //正在使用的磁卡
        
      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nSQL := 'Select P_ID,P_Truck From %s Where P_Card In (%s)';
  nSQL := Format(nSQL, [sTable_PurchInfo, FIn.FExtParam]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    nData := '车辆[ %s ]正在使用该卡,无法并单.';
    nData := Format(nData, [FieldByName('P_Truck').AsString]);
    Exit;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
      //重新计算列表

      nSQL := 'Update %s Set P_Card=''%s'' Where P_ID In(%s)';
      nSQL := Format(nSQL, [sTable_PurchInfo, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Provide),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', nTruck),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Provide),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', nTruck),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015-8-5
//Desc: 保存采购单
function TWorkerBusinessOrders.LogoffOrderCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set P_Card=Null Where P_Card=''%s''';
    nStr := Format(nStr, [sTable_PurchInfo, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null, C_TruckNo=Null' +
            'Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

function TWorkerBusinessOrders.ChangeOrderTruck(var nData: string): Boolean;
var nStr: string;
begin
  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set P_Truck=''%s'' Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PurchInfo, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //更新修改信息

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 磁卡号[FIn.FData];岗位[FIn.FExtParam]
//Desc: 获取特定岗位所需要的交货单列表
function TWorkerBusinessOrders.GetPostOrderItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsOrder: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  {nIsOrder := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_Order]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsOrder := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //前缀和长度都满足采购单编码规则,则视为采购单号
  end;

  if not nIsOrder then
  begin
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
        nData := '磁卡[ %s ]当前状态为[ %s ],无法提货.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '磁卡[ %s ]已被冻结,无法提货.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;

  nStr := 'Select O_ID,O_Card,O_ProType,O_ProID,O_ProName,O_Type,O_StockNo,' +
          'O_StockName,O_Truck,O_Value ' +
          'From $OO oo ';
  //xxxxx

  if nIsOrder then
       nStr := nStr + 'Where O_ID=''$CD'''
  else nStr := nStr + 'Where O_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$OO', sTable_Order),MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsOrder then
           nData := '采购单[ %s ]已无效.'
      else nData := '磁卡号[ %s ]无订单';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end else
    with FListA do
    begin
      Clear;

      Values['O_ID']         := FieldByName('O_ID').AsString;
      Values['O_ProType']    := FieldByName('O_ProType').AsString;
      Values['O_ProID']      := FieldByName('O_ProID').AsString;
      Values['O_ProName']    := FieldByName('O_ProName').AsString;
      Values['O_Truck']      := FieldByName('O_Truck').AsString;

      Values['O_Type']       := FieldByName('O_Type').AsString;
      Values['O_StockNo']    := FieldByName('O_StockNo').AsString;
      Values['O_StockName']  := FieldByName('O_StockName').AsString;

      Values['O_Card']       := FieldByName('O_Card').AsString;
      Values['O_Value']      := FloatToStr(FieldByName('O_Value').AsFloat);
    end;
  end;

  nStr := 'Select D_ID,D_OID,D_PID,D_YLine,D_Status,D_NextStatus,' +
          'D_KZValue,D_Memo,D_YSResult,' +
          'P_PStation,P_PValue,P_PDate,P_PMan,' +
          'P_MStation,P_MValue,P_MDate,P_MMan ' +
          'From $OD od Left join $PD pd on pd.P_Order=od.D_ID ' +
          'Where D_OutFact Is Null And D_OID=''$OID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$OD', sTable_OrderDtl),
                            MI('$PD', sTable_PoundLog),
                            MI('$OID', FListA.Values['O_ID'])]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then
    begin
      SetLength(nBills, 1);

      with nBills[0], FListA do
      begin
        FZhiKa      := Values['O_ID'];
        FCusID      := Values['O_ProID'];
        FCusName    := Values['O_ProName'];
        FCusType    := Values['O_ProType'];
        FTruck      := Values['O_Truck'];

        FType       := Values['O_Type'];
        FStockNo    := Values['O_StockNo'];
        FStockName  := Values['O_StockName'];
        FValue      := StrToFloat(Values['O_Value']);

        FCard       := Values['O_Card'];
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;

        FSelected := True;
      end;  
    end else
    begin
      SetLength(nBills, RecordCount);

      nIdx := 0;

      First; 
      while not Eof do
      with nBills[nIdx], FListA do
      begin
        FID         := FieldByName('D_ID').AsString;
        FZhiKa      := FieldByName('D_OID').AsString;
        FPoundID    := FieldByName('D_PID').AsString;

        FCusID      := Values['O_ProID'];
        FCusName    := Values['O_ProName'];
        FCusType    := Values['O_ProType'];
        FTruck      := Values['O_Truck'];

        FType       := Values['O_Type'];
        FStockNo    := Values['O_StockNo'];
        FStockName  := Values['O_StockName'];
        FValue      := StrToFloat(Values['O_Value']);

        FCard       := Values['O_Card'];
        FStatus     := FieldByName('D_Status').AsString;
        FNextStatus := FieldByName('D_NextStatus').AsString;

        if (FStatus = '') or (FStatus = sFlag_BillNew) then
        begin
          FStatus     := sFlag_TruckNone;
          FNextStatus := sFlag_TruckNone;
        end;

        with FPData do
        begin
          FStation  := FieldByName('P_PStation').AsString;
          FValue    := FieldByName('P_PValue').AsFloat;
          FDate     := FieldByName('P_PDate').AsDateTime;
          FOperator := FieldByName('P_PMan').AsString;
        end;

        with FMData do
        begin
          FStation  := FieldByName('P_MStation').AsString;
          FValue    := FieldByName('P_MValue').AsFloat;
          FDate     := FieldByName('P_MDate').AsDateTime;
          FOperator := FieldByName('P_MMan').AsString;
        end;

        FKZValue  := FieldByName('D_KZValue').AsFloat;
        FMemo     := FieldByName('D_Memo').AsString;
        FYSValid  := FieldByName('D_YSResult').AsString;
        FSelected := True;

        Inc(nIdx);
        Next;
      end;
    end;    
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;     }
end;

//Date: 2014-09-18
//Parm: 交货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessOrders.SavePostOrderItems(var nData: string): Boolean;
var nVal, nNet: Double;
    nIdx: Integer;
    nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  {AnalyseBillItems(FIn.FData, nPound);
  //解析数据

  FListA.Clear;
  //用于存储SQL列表

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  begin
    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_OrderDtl;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
        FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([
            SF('D_ID', nOut.FData),
            SF('D_Card', FCard),
            SF('D_OID', FZhiKa),

            SF('D_ProID', FCusID),
            SF('D_ProName', FCusName),
            SF('D_ProType', FCusType),

            SF('D_Type', FType),
            SF('D_StockNo', FStockNo),
            SF('D_StockName', FStockName),

            SF('D_Truck', FTruck),
            SF('D_Status', sFlag_TruckIn),
            SF('D_NextStatus', sFlag_TruckBFP),
            SF('D_InMan', FIn.FBase.FFrom.FUser),
            SF('D_InTime', sField_SQLServer_Now, sfVal)
            ], sTable_OrderDtl, '', True);
      FListA.Add(nSQL);
    end;  
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    FListB.Clear;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        FListB.Add(Fields[0].AsString);
        Next;
      end;
    end;

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //返回榜单号,用于拍照绑定
    with nPound[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckXH;

      if FListB.IndexOf(FStockNo) >= 0 then
        FNextStatus := sFlag_TruckBFM;
      //现场不发货直接过重

      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Provide),
            SF('P_Order', FID),
            SF('P_Truck', FTruck),
            SF('P_CusID', FCusID),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_LimValue', 0),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_PDate', sField_SQLServer_Now, sfVal),
            SF('P_PMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '进厂'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_PValue', FPData.FValue, sfVal),
              SF('D_PDate', sField_SQLServer_Now, sfVal),
              SF('D_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL);
    end;  

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckXH then //验收现场
  begin
    with nPound[0] do
    begin
      FStatus := sFlag_TruckXH;
      FNextStatus := sFlag_TruckBFM;

      nStr := SF('P_Order', FID);
      //where
      nSQL := MakeSQLByStr([
                SF('P_KZValue', FKZValue, sfVal)
                ], sTable_PoundLog, nStr, False);
      //验收扣杂
     FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_YTime', sField_SQLServer_Now, sfVal),
              SF('D_YMan', FIn.FBase.FFrom.FUser),
              SF('D_KZValue', FKZValue, sfVal),
              SF('D_YSResult', FYSValid),
              SF('D_Memo', FMemo)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    with nPound[0] do
    begin
      nStr := 'Select T_CGHZValue From %s Where T_Truck=''%s''';
      nStr := Format(nStr, [sTable_Truck, FTruck]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount>0 then
           nVal := FieldByName('T_CGHZValue').AsFloat
      else nVal := 0;

      if nVal > 0 then
      begin
        if (FMData.FValue > FPData.FValue) and (FMData.FValue > nVal) then
          FMData.FValue := nVal
        else if (FPData.FValue > FMData.FValue) and (FPData.FValue > nVal) then
          FPData.FValue := nVal;
      end;  

      nStr := 'Select D_CusID,D_Value,D_Type From %s ' +
              'Where D_Stock=''%s'' And D_Valid=''%s''';
      nStr := Format(nStr, [sTable_Deduct, FStockNo, sFlag_Yes]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          if FieldByName('D_CusID').AsString = FCusID then
            Break;
          //客户+物料参数优先

          Next;
        end;

        if Eof then First;
        //使用第一条规则

        if FMData.FValue > FPData.FValue then
             nNet := FMData.FValue - FPData.FValue
        else nNet := FPData.FValue - FMData.FValue;

        nVal := 0;
        //待扣减量
        nStr := FieldByName('D_Type').AsString;

        if nStr = sFlag_DeductFix then
          nVal := FieldByName('D_Value').AsFloat;
        //定值扣减

        if nStr = sFlag_DeductPer then
        begin
          nVal := FieldByName('D_Value').AsFloat;
          nVal := nNet * nVal;
        end; //比例扣减

        if (nVal > 0) and (nNet > nVal) then
        begin
          nVal := Float2Float(nVal, cPrecision, False);
          //将暗扣量扣减为2位小数;

          if FMData.FValue > FPData.FValue then
               FMData.FValue := (FMData.FValue*1000 - nVal*1000) / 1000
          else FPData.FValue := (FPData.FValue*1000 - nVal*1000) / 1000;
        end;
      end;

      nStr := SF('P_Order', FID);
      //where

      nVal := FMData.FValue - FPData.FValue -FKZValue;
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
                ], sTable_PoundLog, nStr, False);
        //称重时,由于皮重大,交换皮毛重数据
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('D_Status', sFlag_TruckBFM),
                SF('D_NextStatus', sFlag_TruckOut),
                SF('D_PValue', FPData.FValue, sfVal),
                SF('D_PDate', sField_SQLServer_Now, sfVal),
                SF('D_PMan', FIn.FBase.FFrom.FUser),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', DateTime2Str(FMData.FDate)),
                SF('D_MMan', FMData.FOperator),
                SF('D_Value', nVal, sfVal)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);

      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('D_Status', sFlag_TruckBFM),
                SF('D_NextStatus', sFlag_TruckOut),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', sField_SQLServer_Now, sfVal),
                SF('D_MMan', FMData.FOperator),
                SF('D_Value', nVal, sfVal)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);
      end;

      if FYSValid <> sFlag_NO then  //验收成功，调整已收货量
      begin
        nSQL := 'Update $OrderBase Set B_SentValue=B_SentValue+$Val ' +
                'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'')';
        nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
                MI('$Order', sTable_Order),MI('$ID', FZhiKa),
                MI('$Val', FloatToStr(nVal))]);
        FListA.Add(nSQL);
        //调整已收货；
      end;

      nSQL := 'Update $OrderBase Set B_FreezeValue=B_FreezeValue-$KDVal ' +
              'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'''+
              ' And O_CType= ''L'') and B_Value>0';
      nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
              MI('$Order', sTable_Order),MI('$ID', FZhiKa),
              MI('$KDVal', FloatToStr(FValue))]);
      FListA.Add(nSQL);
      //调整冻结量
    end;

    nSQL := 'Select P_ID From %s Where P_Order=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nPound[0].FID]);
    //未称毛重记录

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([SF('D_Status', sFlag_TruckOut),
              SF('D_NextStatus', ''),
              SF('D_Card', ''),
              SF('D_OutFact', sField_SQLServer_Now, sfVal),
              SF('D_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL); //更新采购单
    end;    }

    {nSQL := 'Select O_CType,O_Card From %s Where O_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Order, nPound[0].FZhiKa]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      nStr := FieldByName('O_Card').AsString;
      if FieldByName('O_CType').AsString = sFlag_OrderCardL then
      if not CallMe(cBC_LogOffOrderCard, nStr, '', @nOut) then
      begin
        nData := nOut.FData;
        Exit;
      end;
    end;
    //如果是临时卡片，则注销卡片
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

  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    if Assigned(gHardShareData) then
      gHardShareData('TruckOut:' + nPound[0].FCard);
    //磅房处理自动出厂
  end;      }
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessOrders.CallMe(const nCmd: Integer;
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

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessOrders, sPlug_ModuleBus);
end.
