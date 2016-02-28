{*******************************************************************************
  ����: dmzn@163.com 2013-12-04
  ����: ģ��ҵ�����
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
    //�޸ĳ��ƺ�
    function GetGYOrderValue(var nData: string): Boolean;
    //��ȡ��Ӧ���ջ���
    function GetPostOrderItems(var nData: string): Boolean;
    //��ȡ��λ�ɹ���
    function SavePostOrderItems(var nData: string): Boolean;
    //�����λ�ɹ���
    function AXSyncOrder(var nData: string): Boolean;
    //ͬ�����ݵ�AX
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
    //��֤�����Ƿ���Ч
  end;

implementation

//Date: 2016-02-28
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
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
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessOrders.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
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
   cBC_AXSyncOrder          : Result := AXSyncOrder(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2016-02-27
//Parm: �ɹ�����[FIn.FData]
//Desc: ͬ���ɹ�����AX
function TWorkerBusinessOrders.AXSyncOrder(var nData: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := sFlag_FixedNo + 'SO' + FIn.FData;
  Result := CallRemoteWorker(sAX_SyncOrder, FIn.FData, '', nStr, @nOut);

  if not Result then
    nData := nOut.FData;
  //xxxxx
end;

//Date: 2015/9/20
//Parm: ��Ӧ�̱��(FIn.FData); ���ϱ��(FIn.FExtParam);
//Desc: ��ȡ��Ӧ���ջ���
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
  //��ȡ������

  if not TAXWorkerReadOrdersInfo.CallMe(FIn.FData, @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end;
  //��ȡ��������

  FListB.Clear;
  FListB.Text := PackerDecodeStr(nOut.FData);
  nInt := StrToInt(FListB.Values['DataNum']);

  nVal := 0;
  for nIdx:=0 to nInt-1 do
  begin
    FListC.Text := PackerDecodeStr(FListB.Values['Data' + IntToStr(nIdx)]);
    if CompareText(FIn.FExtParam, FListC.Values['ItemID'])=0 then
    begin
      nVal := StrToFloat(FListC.Values['Qty']);

      Break;
    end;
  end;

  nVal := nVal - nFreezeVal;
  nVal := Float2Float(nVal, cPrecision, False);

  FOut.FExtParam := FloatToStr(nFreezeVal);
  FOut.FData := FloatToStr(nVal);
  Result := True;
end;

//Date: 2014-09-16
//Parm: ���ƺ�;
//Desc: ��֤nTruck�Ƿ���Ч
class function TWorkerBusinessOrders.VerifyTruckNO(nTruck: string;
  var nData: string): Boolean;
var nIdx: Integer;
    nWStr: WideString;
begin
  Result := False;
  nIdx := Length(nTruck);
  if (nIdx < 3) or (nIdx > 10) then
  begin
    nData := '��Ч�ĳ��ƺų���Ϊ3-10.';
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
      nData := Format('���ƺ�[ %s ]��Ч.', [nTruck]);
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
    nStr := '����[ %s ]��δ���[ %s ]�볧��֮ǰ��ֹ����.';
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
  //��ȡ������

  if not TAXWorkerReadOrdersInfo.CallMe(FListA.Values['ProviderID'], @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end;
  //��ȡ��������

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
        nData := '����ʣ��������,��������: ' + #13#10#13#10 +
                 '*.AXϵͳʣ����: %.2f' + #13#10 +
                 '*.DLϵͳ������: %.2f' + #13#10 +
                 '*.����Ԥ��Ӧ��: %.2f' + #13#10 +
                 '����ϵAXϵͳ����Ա,���¿�����';
        nData := Format(nData, [nRVal, nFreezeVal, nVal]);
        Exit;
      end;

      Break;
    end;
  end;

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //���泵�ƺ�

  Result := True;
  //verify done
end;

//Date: 2015-8-5
//Desc: ����ɹ���
function TWorkerBusinessOrders.SaveOrder(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
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
      nStr := 'Insert Into %s(C_Freeze, C_Count, C_HasDone, C_ID, C_Stock) ' +
              'Values(%s, 1, 0, ''%s'', ''%s'')';
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
//Desc: ����ɹ���
function TWorkerBusinessOrders.DeleteOrder(var nData: string): Boolean;
var nStr,nP,nSN, nPN, nCard: string;
    nOut: TWorkerBusinessCommand;
    nHasOut: Boolean;
    nIdx: Integer;
    nVal: Double;
begin
  Result := False;
  //init

  nStr := 'Select P_StockNo,P_Value,P_ProID,P_OutFact,P_Card ' +
          'From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_PurchInfo, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '�ɹ���[ %s ]����Ч.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nHasOut := FieldByName('P_OutFact').AsString <> '';
    //�ѳ���

    if nHasOut then
    begin
      nData := '�ɹ���[ %s ]�ѳ���,������ɾ��.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nCard := FieldByName('P_Card').AsString;
    nVal:= FieldByName('P_Value').AsFloat;
    nSN := FieldByName('P_StockNo').AsString;
    nPN := FieldByName('P_ProID').AsString;
  end;

  if not CallMe(cBC_LogOffOrderCard, nCard, '', @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end;  

  FDBConn.FConn.BeginTrans;
  try
    if nHasOut then
    begin
      nStr := 'Update %s Set C_HasDone=C_HasDone-(%.2f) ' +
              'Where C_ID=''%s'' and C_Stock=''%s''';
      nStr := Format(nStr, [sTable_AX_OrderInfo, nVal, nPN, nSN]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //�ͷŷ�����
    end else
    begin
      nStr := 'Update %s Set C_Freeze=C_Freeze-(%.2f), C_Count=C_Count-1 ' +
              'Where C_ID=''%s'' and C_Stock=''%s''';
      nStr := Format(nStr, [sTable_AX_OrderInfo, nVal, nPN, nSN]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //�ͷŶ�����
    end;
    
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
      //�����ֶ�,������ɾ��

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
//Parm: �ɹ�����[FIn.FData];�ſ���[FIn.FExtParam]
//Desc: Ϊ�ɹ����󶨴ſ�
function TWorkerBusinessOrders.SaveOrderCard(var nData: string): Boolean;
var nStr,nSQL,nTruck: string;
begin
  Result := False;
  nTruck := '';

  FListB.Text := FIn.FExtParam;
  //�ſ��б�
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //�ɹ����б�

  nSQL := 'Select P_ID,P_Card,P_Truck From %s Where P_ID In (%s)';
  nSQL := Format(nSQL, [sTable_PurchInfo, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('�ɹ�����[ %s ]�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      nStr := FieldByName('P_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '�ɹ���[ %s ]�ĳ��ƺŲ�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.��������: %s' + #13#10 +
                 '*.��������: %s' + #13#10#13#10 +
                 '��ͬ�ƺŲ��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
        nData := Format(nData, [FieldByName('O_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('P_Card').AsString;
      //����ʹ�õĴſ�
        
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
    nData := '����[ %s ]����ʹ�øÿ�,�޷�����.';
    nData := Format(nData, [FieldByName('P_Truck').AsString]);
    Exit;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
      //���¼����б�

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
//Desc: ����ɹ���
function TWorkerBusinessOrders.LogoffOrderCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set P_Card=Null Where P_Card=''%s''';
    nStr := Format(nStr, [sTable_PurchInfo, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null, C_TruckNo=Null ' +
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
    //�����޸���Ϣ

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: �ſ���[FIn.FData];��λ[FIn.FExtParam]
//Desc: ��ȡ�ض���λ����Ҫ�Ľ������б�
function TWorkerBusinessOrders.GetPostOrderItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsOrder: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  nIsOrder := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_PurchInfo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsOrder := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //ǰ׺�ͳ��ȶ�����ɹ����������,����Ϊ�ɹ�����
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
        nData := Format('�ſ�[ %s ]��Ϣ�Ѷ�ʧ.', [FIn.FData]);
        Exit;
      end;

      if Fields[0].AsString <> sFlag_CardUsed then
      begin
        nData := '�ſ�[ %s ]��ǰ״̬Ϊ[ %s ],�޷�ʹ��.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '�ſ�[ %s ]�ѱ�����,�޷�ʹ��.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;

  nStr := 'Select b.P_ID,b.P_ProID,b.P_ProName,b.P_Type,b.P_StockNo,' +
          'b.P_StockName,b.P_Truck,b.P_Value,b.P_Status,P_NextStatus,' +
          'b.P_Memo, b.P_KZValue, b.P_YSResult,' +
          'b.P_Card, b.P_PValue, b.P_MValue,' +
          'p.P_PDate, p.P_PStation, p.P_PMan ' +
          'From $Bill b ' +
          'Left Join $Pound p on b.P_ID=p.P_Order ';
  //xxxxx

  if nIsOrder then
       nStr := nStr + 'Where b.P_ID=''$CD'''
  else nStr := nStr + 'Where b.P_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$Bill', sTable_PurchInfo),
          MI('$Pound', sTable_PoundLog),MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsOrder then
           nData := '�볧��[ %s ]����Ч.'
      else nData := '�ſ���[ %s ]û���볧��.';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with nBills[nIdx] do
    begin
      FID         := FieldByName('P_ID').AsString;
      FCusID      := FieldByName('P_ProID').AsString;
      FCusName    := FieldByName('P_ProName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;

      FType       := FieldByName('P_Type').AsString;
      FStockNo    := FieldByName('P_StockNo').AsString;
      FStockName  := FieldByName('P_StockName').AsString;
      FValue      := FieldByName('P_Value').AsFloat;

      FCard       := FieldByName('P_Card').AsString;
      FStatus     := FieldByName('P_Status').AsString;
      FNextStatus := FieldByName('P_NextStatus').AsString;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      with FPData do
      begin
        FDate   := FieldByName('P_PDate').AsDateTime;
        FValue  := FieldByName('P_PValue').AsFloat;
        FStation:= FieldByName('P_PStation').AsString;
        FOperator := FieldByName('P_PMan').AsString;
      end;

      FMemo         := FieldByName('P_Memo').AsString;
      FKZValue      := FieldByName('P_KZValue').AsFloat;
      FYSValid      := FieldByName('P_YSResult').AsString;
      FSelected := True;

      Inc(nIdx);
      Next;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
function TWorkerBusinessOrders.SavePostOrderItems(var nData: string): Boolean;
var nVal, f, m: Double;
    nInt, nIdx: Integer;
    nStr, nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nPound);
  nInt := Length(nPound);
  //��������

  if nInt < 1 then
  begin
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '��λ[ %s ]�ύ��ԭ���Ϻϵ�,��ҵ��ϵͳ��ʱ��֧��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  FListA.Clear;
  //���ڴ洢SQL�б�

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
  begin
    with nPound[0] do
    begin
      nStr := SF('P_ID', FID);
      nSQL := MakeSQLByStr([
              SF('P_Status', sFlag_TruckIn),
              SF('P_NextStatus', sFlag_TruckBFP),
              SF('P_InTime', sField_SQLServer_Now, sfVal),
              SF('P_InMan', FIn.FBase.FFrom.FUser)
              ], sTable_PurchInfo, nStr, False);
      FListA.Add(nSQL);
    end;  
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //����Ƥ��
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
    //���ذ񵥺�,�������հ�
    with nPound[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckXH;

      if FListB.IndexOf(FStockNo) >= 0 then
        FNextStatus := sFlag_TruckBFM;
      //�ֳ�������ֱ�ӹ���

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
            SF('P_LimValue', FValue),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_PDate', sField_SQLServer_Now, sfVal),
            SF('P_PMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '����'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('P_Status', FStatus),
              SF('P_NextStatus', FNextStatus),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_PurchInfo, SF('P_ID', FID), False);
      FListA.Add(nSQL);
    end;  

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckXH then //�����ֳ�
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
      //���տ���
     FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('P_Status', FStatus),
              SF('P_NextStatus', FNextStatus),
              SF('P_YTime', sField_SQLServer_Now, sfVal),
              SF('P_YMan', FIn.FBase.FFrom.FUser),
              SF('P_KZValue', FKZValue, sfVal),
              SF('P_YSResult', FYSValid),
              SF('P_Memo', FMemo)
              ], sTable_PurchInfo, SF('P_ID', FID), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    with nPound[0] do
    begin 
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
        //����ʱ,����Ƥ�ش�,����Ƥë������
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('P_Status', sFlag_TruckBFM),
                SF('P_NextStatus', sFlag_TruckOut),
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator)
                ], sTable_PurchInfo, SF('P_ID', FID), False);
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
                SF('P_Status', sFlag_TruckBFM),
                SF('P_NextStatus', sFlag_TruckOut),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FMData.FOperator)
                ], sTable_PurchInfo, SF('P_ID', FID), False);
        FListA.Add(nSQL);
      end;

      f := Float2Float(nVal - FValue, cPrecision, True);
      if FYSValid <> sFlag_No then
      begin
        if FloatRelation(f, 0, rtGreater) then //����>Ʊ��
        begin
          if not CallMe(cBC_GetGYOrderValue, FCusID, FStockNo, @nOut) then
             raise Exception.Create(nOut.FData);

          m := StrToFloat(nOut.FData);
          if FloatRelation(f, m, rtGreater) then
          begin
            nData := '�볧�ɹ�������, ��������:' + #13#10#13#10 +
                     '*.��Ӧ��: %s ' + #13#10 +
                     '*.��Ӧ�̱��: %s ' + #13#10#13#10 +
                     '*.ԭ����: %s ' + #13#10 +
                     '*.ԭ���ϱ��: %s ' + #13#10#13#10 +
                     '*.����: %.2f ' + #13#10 +
                     '*.�ɷ���: %.2f ' + #13#10 +
                     '*.������: %.2f ' + #13#10#13#10 +
                     '����ϵ����Ա����';
            nData := Format(nData, [FCusName, FCusID, FStockName, FStockNo,
                     nVal, m+StrToFloat(nOut.FExtParam), f-m]);
            Exit;
          end;  
        end;

        nSQL := 'Update %s Set P_Value=P_Value+(%s) Where P_ID=''%s''';
        nSQL := Format(nSQL, [sTable_PurchInfo, FloatToStr(f), FID]);
        FListA.Add(nSQL);

        nSQL := 'Update %s Set C_Freeze=C_Freeze+(%s) ' +
                'Where C_ID=''%s'' And C_Stock=''%s''';
        nSQL := Format(nSQL, [sTable_AX_OrderInfo, FloatToStr(f), FCusID, FStockNo]);
        FListA.Add(nSQL);
        //���ճɹ�����֤���ϲɹ���
      end else

      begin
        nSQL := 'Update %s Set P_Value=P_Value-%s Where P_ID=''%s''';
        nSQL := Format(nSQL, [sTable_PurchInfo, FloatToStr(FValue), FID]);
        FListA.Add(nSQL);

        nSQL := 'Update %s Set C_Freeze=C_Freeze-%s ' +
                'Where C_ID=''%s'' And C_Stock=''%s''';
        nSQL := Format(nSQL, [sTable_AX_OrderInfo, FloatToStr(FValue), FCusID, FStockNo]);
        FListA.Add(nSQL);
        //����ʧ�ܣ��ͷŶ�����
      end;
    end;

    nSQL := 'Select P_ID From %s Where P_Order=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nPound[0].FID]);
    //δ��ë�ؼ�¼

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
      nSQL := MakeSQLByStr([SF('P_Status', sFlag_TruckOut),
              SF('P_NextStatus', ''),
              SF('P_Card', ''),
              SF('P_OutFact', sField_SQLServer_Now, sfVal),
              SF('P_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_PurchInfo, SF('P_ID', FID), False);
      FListA.Add(nSQL); //���²ɹ���

      nSQL := 'Update %s Set C_Freeze=C_Freeze-%s, C_HasDone=C_HasDone+%s, ' +
              'C_Count=C_Count-1 Where C_ID=''%s'' And C_Stock=''%s''';
      nSQL := Format(nSQL, [sTable_AX_OrderInfo, FloatToStr(FValue),
              FloatToStr(FValue), FCusID, FStockNo]);
      FListA.Add(nSQL);
    end;
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
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessOrders, sPlug_ModuleBus);
end.
