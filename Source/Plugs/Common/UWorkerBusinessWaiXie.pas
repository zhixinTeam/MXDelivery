{*******************************************************************************
  ����: dmzn@163.com 2016-02-28
  ����: ��Э����ҵ�����
*******************************************************************************}
unit UWorkerBusinessWaiXie;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusinessCommand, UWorkerBusinessRemote;

type
  TWorkerBusinessWaiXie = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function SaveWaiXie(var nData: string): Boolean;
    //������Э��
    function SaveWaiXieCard(var nData: string): Boolean;
    //������Э�ſ�
    function ChangeWaiXieTruck(var nData: string): Boolean;
    //�޸���Э����
    function DeleteWaiXie(var nData: string): Boolean;
    //ɾ����Э��
    function GetPostItems(var nData: string): Boolean;
    //��ȡ��λ����
    function SavePostItems(var nData: string): Boolean;
    //�����λ����
    function AXSyncWaiXie(var nData: string): Boolean;
    //ͬ������
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
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TWorkerBusinessWaiXie.CallMe(const nCmd: Integer;
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
class function TWorkerBusinessWaiXie.FunctionName: string;
begin
  Result := sBus_BusinessWaiXie;
end;

constructor TWorkerBusinessWaiXie.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessWaiXie.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessWaiXie.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessWaiXie.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessWaiXie.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_SaveWaiXie          : Result := SaveWaiXie(nData);
   cBC_SaveWaiXieCard      : Result := SaveWaiXieCard(nData);
   cBC_ModifyWaiXieTruck   : Result := ChangeWaiXieTruck(nData);
   cBC_DeleteWaiXie        : Result := DeleteWaiXie(nData);
   cBC_GetPostBills        : Result := GetPostItems(nData);
   cBC_SavePostBills       : Result := SavePostItems(nData);
   cBC_AXSyncWaiXie        : Result := AXSyncWaiXie(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------ 
//Date: 2016-02-27
//Parm: ��Э����[FIn.FData]
//Desc: ͬ����Э����AX
function TWorkerBusinessWaiXie.AXSyncWaiXie(var nData: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := sFlag_FixedNo + 'SW' + FIn.FData;
  Result := CallRemoteWorker(sAX_SyncWaiXie, FIn.FData, '', nStr, @nOut);

  if not Result then
    nData := nOut.FData;
  //xxxxx
end;

//Date: 2016-02-27
//Desc: ������Э��
function TWorkerBusinessWaiXie.SaveWaiXie(var nData: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);

  nStr := 'Select W_ID From %s Where W_Truck=''%s'' And W_OutFact2 Is Null';
  nStr := Format(nStr, [sTable_WaiXieInfo, FListA.Values['Truck']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nData := '����[ %s ]��δ��ɵ���Э����[ %s ],���ȴ���.';
    nData := Format(nData, [FListA.Values['Truck'], Fields[0].AsString]);
    Exit;
  end;

  with FListC do
  begin
    Clear;
    Values['Group'] :=sFlag_BusGroup;
    Values['Object'] := sFlag_WaiXieNo;
  end;

  if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
        FListC.Text, sFlag_Yes, @nOut) then  //to get serial no
  begin
    nData := nOut.FData;
    Exit;
  end;

  FOut.FData := nOut.FData;
  //id

  with FListA do
  begin
    nStr := MakeSQLByStr([SF('W_ID', nOut.FData),
            SF('W_Truck', Values['Truck']),
            SF('W_ProID', Values['CusID']),
            SF('W_ProName', Values['CusName']),
            SF('W_ProPY', GetPinYinOfStr(Values['CusName'])),
            SF('W_TransID', Values['Sender']),
            SF('W_TransName', Values['SenderName']),
            SF('W_TransPY', GetPinYinOfStr(Values['SenderName'])),
            SF('W_ProductLine', Values['ProductLine']),
            SF('W_OutXH', Values['OutXH']),
            SF('W_StockNo', Values['Stock']),
            SF('W_StockName', Values['StockName']),

            SF('W_Status', sFlag_BillNew),
            SF('W_Man', FIn.FBase.FFrom.FUser),
            SF('W_Date', sField_SQLServer_Now, sfVal)
            ], sTable_WaiXieInfo, '', True);
    //xxxxx

    gDBConnManager.WorkerExec(FDBConn, nStr);
    Result := True;
  end;
end;

//Date: 2016-02-27
//Parm: ����[FIn.FData];�ſ�[FIn.FExtParam]
//Desc: ������Э���ſ�
function TWorkerBusinessWaiXie.SaveWaiXieCard(var nData: string): Boolean;
var nStr,nTruck: string;
    nIdx: Integer;
begin
  Result := False;
  nStr := 'Select W_Card,W_Truck From %s Where W_ID=''%s''';
  nStr := Format(nStr, [sTable_WaiXieInfo, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '��Э����[ %s ]�Ѷ�ʧ.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FListA.Clear;
    nTruck := Fields[1].AsString;
    
    if Fields[0].AsString <> '' then
    begin
      nStr := 'Update %s set C_TruckNo=Null,C_Status=''%s'' Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, sFlag_CardIdle, Fields[0].AsString]);
      FListA.Add(nStr); //�ſ�״̬
    end;
  end;

  nStr := 'Update %s Set W_Card=''%s'' Where W_ID=''%s''';
  nStr := Format(nStr, [sTable_WaiXieInfo, FIn.FExtParam, FIn.FData]);
  FListA.Add(nStr);

  nStr := 'Select Count(*) From %s Where C_Card=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if Fields[0].AsInteger < 1 then
  begin
    nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
            SF('C_Status', sFlag_CardUsed),
            SF('C_Used', sFlag_WaiXie),
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
            SF('C_Used', sFlag_WaiXie),
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
//Parm: ��Э��[FIn.FData];���ƺ�[FIn.FExtParm]
//Desc: �޸ĵ��ݵĳ���
function TWorkerBusinessWaiXie.ChangeWaiXieTruck(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  Result := False;
  nStr := 'Select W_PDate,W_MDate,W_Card From %s Where W_ID=''%s''';
  nStr := Format(nStr, [sTable_WaiXieInfo, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '��Э����[ %s ]�Ѷ�ʧ.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FListA.Clear;
    if (Fields[0].AsFloat > 0) or (Fields[1].AsFloat > 0) then
    begin
      nStr := 'Update %s set P_Truck=''%s'' Where P_Bill=''%s''';
      nStr := Format(nStr, [sTable_PoundLog, FIn.FExtParam, FIn.FData]);
      FListA.Add(nStr); //���ؼ�¼
    end;

    if Fields[2].AsString <> '' then
    begin
      nStr := 'Update %s set C_TruckNo=''%s'' Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, FIn.FExtParam, Fields[2].AsString]);
      FListA.Add(nStr); //�ſ���¼
    end;
  end;

  nStr := 'Update %s set W_Truck=''%s'' Where W_ID=''%s''';
  nStr := Format(nStr, [sTable_WaiXieInfo, FIn.FExtParam, FIn.FData]);
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
//Parm: ��Э��[FIn.FData]
//Desc: ɾ����Э��
function TWorkerBusinessWaiXie.DeleteWaiXie(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  nStr := 'Select W_Card From %s Where W_ID=''%s''';
  nStr := Format(nStr, [sTable_WaiXieInfo, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '��Э����[ %s ]�Ѷ�ʧ.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    FListA.Clear;
    if Fields[0].AsString <> '' then
    begin
      nStr := 'Update %s set C_TruckNo=Null,C_Status=''%s'' Where C_Card=''%s''';
      nStr := Format(nStr, [sTable_Card, sFlag_CardIdle, Fields[0].AsString]);
      FListA.Add(nStr); //�ſ�״̬
    end; 
  end;

  //--------------------------------------------------------------------------
  nStr := Format('Select * From %s Where 1<>1', [sTable_WaiXieInfo]);
  //only for fields
  nP := '';

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    for nIdx:=0 to FieldCount - 1 do
     if (Fields[nIdx].DataType <> ftAutoInc) and
        (Pos('W_Del', Fields[nIdx].FieldName) < 1) then
      nP := nP + Fields[nIdx].FieldName + ',';
    //�����ֶ�,������ɾ��

    System.Delete(nP, Length(nP), 1);
  end;

  nStr := 'Insert Into $WB($FL,W_DelMan,W_DelDate) ' +
          'Select $FL,''$User'',$Now From $WX Where W_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$WB', sTable_WaiXieBak),
          MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
          MI('$Now', sField_SQLServer_Now),
          MI('$WX', sTable_WaiXieInfo), MI('$ID', FIn.FData)]);
  FListA.Add(nStr);

  nStr := 'Delete From %s Where W_ID=''%s''';
  nStr := Format(nStr, [sTable_WaiXieInfo, FIn.FData]);
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
//Parm: �ſ���[FIn.FData];��λ[FIn.FExtParam]
//Desc: ��ȡ�ض���λ����Ҫ�Ľ������б�
function TWorkerBusinessWaiXie.GetPostItems(var nData: string): Boolean;
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

  nStr := 'Select b.*,p.P_ID,p.P_PStation ' +
          'From $Bill b ' +
          '  Left Join $Pound p on p.P_Bill=b.W_ID ' +
          'Where b.W_Card=''$CD''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$Bill', sTable_WaiXieInfo),
          MI('$Pound', sTable_PoundLog),MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '��Э�ſ�[ %s ]û�й�����Ч����.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with nBills[nIdx] do
    begin
      FID         := FieldByName('W_ID').AsString;
      FCusID      := FieldByName('W_ProID').AsString;
      FCusName    := FieldByName('W_ProName').AsString;
      FTruck      := FieldByName('W_Truck').AsString;

      FType       := FieldByName('W_Type').AsString;
      FStockNo    := FieldByName('W_StockNo').AsString;
      FStockName  := FieldByName('W_StockName').AsString;
      FValue      := 0;

      FCard       := FieldByName('W_Card').AsString;
      FStatus     := FieldByName('W_Status').AsString;
      FNextStatus := FieldByName('W_NextStatus').AsString;

      FYSValid    := FieldByName('W_OutXH').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      with FPData do
      begin
        FDate   := FieldByName('W_PDate').AsDateTime;
        FValue  := FieldByName('W_PValue').AsFloat;
        FStation:= FieldByName('P_PStation').AsString;
        FOperator := FieldByName('W_PMan').AsString;
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
//Parm: ��Э��[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
function TWorkerBusinessWaiXie.SavePostItems(var nData: string): Boolean;
var nInt,nIdx: Integer;
    nSQL: string;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nBills);
  nInt := Length(nBills);
  //��������

  if nInt < 1 then
  begin
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '��λ[ %s ]�ύ����Э�ϵ�,��ҵ��ϵͳ��ʱ��֧��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  FListA.Clear;
  //���ڴ洢SQL�б�
  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
  with nBills[0] do
  begin
    if FYSValid = sFlag_Yes then //����ж��ģʽ,��������
    begin
      if FPoundID = '' then //�״ν���
      begin
        nSQL := MakeSQLByStr([
                SF('W_Status', sFlag_TruckIn),
                SF('W_NextStatus', sFlag_TruckBFP),
                SF('W_InTime1', sField_SQLServer_Now, sfVal),
                SF('W_InMan1', FIn.FBase.FFrom.FUser)
                ], sTable_WaiXieInfo, SF('W_ID', FID), False);
        FListA.Add(nSQL);
      end else
      begin
        nSQL := MakeSQLByStr([
                SF('W_Status', sFlag_TruckIn),
                SF('W_NextStatus', sFlag_TruckBFM),
                SF('W_InTime2', sField_SQLServer_Now, sfVal),
                SF('W_InMan2', FIn.FBase.FFrom.FUser)
                ], sTable_WaiXieInfo, SF('W_ID', FID), False);
        FListA.Add(nSQL);
      end;
    end else

    //����ж��ģʽ,��������
    begin
      nSQL := MakeSQLByStr([
              SF('W_Status', sFlag_TruckIn),
              SF('W_NextStatus', sFlag_TruckBFP),
              SF('W_InTime1', sField_SQLServer_Now, sfVal),
              SF('W_InMan1', FIn.FBase.FFrom.FUser),
              SF('W_InTime2', sField_SQLServer_Now, sfVal),
              SF('W_InMan2', FIn.FBase.FFrom.FUser)
              ], sTable_WaiXieInfo, SF('W_ID', FID), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //����Ƥ��
  begin
    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //���ذ񵥺�,�������հ�
    with nBills[0] do
    begin
      FStatus := sFlag_TruckBFP;
      if FYSValid = sFlag_Yes then //����ж��
           FNextStatus := sFlag_TruckOut
      else FNextStatus := sFlag_TruckBFM;

      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_WaiXie),
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
            SF('P_Direction', '����'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('W_Status', FStatus),
              SF('W_NextStatus', FNextStatus),
              SF('W_PValue', FPData.FValue, sfVal),
              SF('W_PDate', sField_SQLServer_Now, sfVal),
              SF('W_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_WaiXieInfo, SF('W_ID', FID), False);
      FListA.Add(nSQL);
    end; 
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
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
        //����ʱ,����Ƥ�ش�,����Ƥë������

        nSQL := MakeSQLByStr([
                SF('W_Status', sFlag_TruckBFM),
                SF('W_NextStatus', sFlag_TruckOut),
                SF('W_PValue', FPData.FValue, sfVal),
                SF('W_PDate', sField_SQLServer_Now, sfVal),
                SF('W_PMan', FIn.FBase.FFrom.FUser),
                SF('W_MValue', FMData.FValue, sfVal),
                SF('W_MDate', DateTime2Str(FMData.FDate)),
                SF('W_MMan', FMData.FOperator)
                ], sTable_WaiXieInfo, SF('W_ID', FID), False);
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
                SF('W_Status', sFlag_TruckBFM),
                SF('W_NextStatus', sFlag_TruckOut),
                SF('W_MValue', FMData.FValue, sfVal),
                SF('W_MDate', sField_SQLServer_Now, sfVal),
                SF('W_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_WaiXieInfo, SF('W_ID', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    nSQL := 'Select P_ID From %s Where P_Bill=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nBills[0].FID]);
    //δ��ë�ؼ�¼

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
    if FYSValid = sFlag_Yes then //����ж��ģʽ,��������
    begin
      if FStatus = sFlag_TruckBFP then //�״γ���
      begin
        nSQL := MakeSQLByStr([SF('W_Status', sFlag_TruckOut),
                SF('W_NextStatus', sFlag_TruckIn),
                SF('W_OutFact1', sField_SQLServer_Now, sfVal),
                SF('W_OutMan1', FIn.FBase.FFrom.FUser)
                ], sTable_WaiXieInfo, SF('W_ID', FID), False);
        FListA.Add(nSQL);
      end else
      begin
        nSQL := MakeSQLByStr([SF('W_Status', sFlag_TruckOut),
                SF('W_NextStatus', ''),
                SF('W_Card', ''),
                SF('W_OutFact2', sField_SQLServer_Now, sfVal),
                SF('W_OutMan2', FIn.FBase.FFrom.FUser)
                ], sTable_WaiXieInfo, SF('W_ID', FID), False);
        FListA.Add(nSQL);

        nSQL := 'Update %s Set C_Status=''%s'',C_TruckNo=Null Where C_Card=''%s''';
        nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, nBills[0].FCard]);
        FListA.Add(nSQL); //�ſ�
      end;
    end else

    //����ж��ģʽ,
    begin
      nSQL := MakeSQLByStr([SF('W_Status', sFlag_TruckOut),
              SF('W_NextStatus', ''),
              SF('W_Card', ''),
              SF('W_OutFact1', sField_SQLServer_Now, sfVal),
              SF('W_OutMan1', FIn.FBase.FFrom.FUser),
              SF('W_OutFact2', sField_SQLServer_Now, sfVal),
              SF('W_OutMan2', FIn.FBase.FFrom.FUser)
              ], sTable_WaiXieInfo, SF('W_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set C_Status=''%s'',C_TruckNo=Null Where C_Card=''%s''';
      nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, nBills[0].FCard]);
      FListA.Add(nSQL); //�ſ�
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
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessWaiXie, sPlug_ModuleBus);
end.
