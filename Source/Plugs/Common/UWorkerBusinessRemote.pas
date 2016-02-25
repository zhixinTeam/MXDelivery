{*******************************************************************************
  ����: dmzn@163.com 2016-01-15
  ����: AXҵ����������
*******************************************************************************}
unit UWorkerBusinessRemote;

{$I Link.Inc}
interface

uses
  Windows, SysUtils, Classes, Variants, NativeXml, UWorkerBusinessCommand,
  UBusinessWorker, UBusinessPacker, UBusinessConst, UMgrChannel;

type
  TAXWorkerBase = class(TMITDBWorker)
  protected
    FChannel: PChannelItem;
    //����ͨ��
    FXML: TNativeXml;
    //���ݽ���
    FCompanyID: string;
    //������ʶ
    FListA,FListB,FListC: TStrings;
    //�����б�
    procedure BuildDefaultXMLPack;
    //XMLĬ�������
    function GetSystemCompanyID: string;
    //ϵͳ���ڹ���
    procedure GetMsgNo(nPairID: string; var nMsgNo,nKey: string);
    procedure UpdateMsgStatus(const nMsgNo,nStatus: string);
    //��Ϣ��
    function DoAXWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterCallAX(var nData: string): Boolean; virtual;
    function DoAfterCallAXDone(var nData: string): Boolean; virtual;
    //AX����
    function DefaultParseError(const nData: string): Boolean;
    //Ĭ�ϴ�����
  public
    constructor Create; override;
    destructor Destroy; override;
    //�����ͷ�
    function DoDBWork(var nData: string): Boolean; override;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; override;
    //ִ��ҵ��
  end;

  TAXWorkerReadSalesInfo = class(TAXWorkerBase)
  protected
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    function GetStockType(var nData: string): Boolean;
    //��ȡ��������
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoAXWork(var nData: string): Boolean; override;
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
  end;

  TAXWorkerReadOrdersInfo = class(TAXWorkerBase)
  protected
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoAXWork(var nData: string): Boolean; override;
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    class function CallMe(const nData: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

uses
  ULibFun, UMgrDBConn, UChannelChooser, UAXService, USysDB, UFormCtrl,
  USysLoger;

constructor TAXWorkerBase.Create;
begin
  inherited;
  FXML := TNativeXml.Create;

  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create; 
end;

destructor TAXWorkerBase.Destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);

  FreeAndNil(FXML);
  inherited;
end;

//Date: 2016-01-15
//Parm: ƥ���;��Ϣ��;�ظ����
//Desc: ��ȡnPairID��Ӧ��nMsg��nKey
procedure TAXWorkerBase.GetMsgNo(nPairID: string; var nMsgNo, nKey: string);
var nStr: string;
begin
  if Pos(sFlag_ManualNo, nPairID) = 1 then
  begin
    nMsgNo := nPairID;
    System.Delete(nMsgNo, 1, Length(sFlag_ManualNo));
    Exit;
  end;
  //�û�ָ�����,ϵͳ�����κζ���

  if Pos(sFlag_NotMatter, nPairID) = 1 then
  begin
    nStr := 'Select B_Prefix,B_IDLen From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, sFlag_SerialAX, sFlag_AXMsgNo]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      nKey := Fields[0].AsString;
      nStr := StringOfChar('0', Fields[1].AsInteger-Length(nKey));

      nMsgNo := nKey + nStr;
      nKey := '0';
      Exit;
    end;
  end;
  //������ģʽ,��ǰ׺�ⶼ��0

  if Pos(sFlag_FixedNo, nPairID) = 1 then
  begin
    nStr := 'Select Top 1 S_SerailID From %s ' +
            'Where S_PairID=''%s'' And S_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialStatus, nPairID, sFlag_AXMsgNo]);
  end else
  //ָ�����ģʽ,ʹ����ͬ�ı��

  if Pos(sFlag_ForceDone, nPairID) = 1 then
  begin
    nStr := 'Select Top 1 S_SerailID From %s ' +
            'Where S_Status=''%s'' And S_PairID=''%s'' And S_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialStatus, sFlag_Unknow,
            nPairID, sFlag_AXMsgNo]);
  end else
  //ǿ�����ģʽ,���ǰ(Unknow)ʹ����ͬ���

  begin
    nStr := 'Select Top 1 S_SerailID From %s Where S_Date>%s-1 And ' +
            'S_Status=''%s'' And S_Object=''%s'' And S_PairID=''%s''';
    nStr := Format(nStr, [sTable_SerialStatus, sField_SQLServer_Now,
            sFlag_Unknow, sFlag_AXMsgNo, nPairID]);
  end;
  //����ģʽ,���ǰ(Unknow)���һ����ƥ��

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nMsgNo := Fields[0].AsString;
    nKey := '3';
    Exit;
  end;

  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set B_Base=B_Base+1 ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, sFlag_SerialAX, sFlag_AXMsgNo]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Select B_Prefix,B_IDLen,B_Base From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, sFlag_SerialAX, sFlag_AXMsgNo]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      nKey := Fields[0].AsString;
      nMsgNo := Fields[2].AsString;
      nStr := StringOfChar('0', Fields[1].AsInteger-Length(nKey)-Length(nMsgNo));

      nMsgNo := nKey + nStr + nMsgNo;
      nKey := '0';
    end;

    nStr := MakeSQLByStr([SF('S_Object', sFlag_AXMsgNo), SF('S_PairID', nPairID),
            SF('S_SerailID', nMsgNo), SF('S_Status', sFlag_Unknow),
            SF('S_Date', sField_SQLServer_Now, sfVal)
            ],sTable_SerialStatus, '', True);
    //xxxxx

    gDBConnManager.WorkerExec(FDBConn, nStr);
    FDBConn.FConn.CommitTrans;
  except
    FDBConn.FConn.RollbackTrans;
  end;
end;

//Date: 2016-01-15
//Parm: ��Ϣ��;״̬
//Desc: ����nMsgNo��״̬ΪnStatus
procedure TAXWorkerBase.UpdateMsgStatus(const nMsgNo, nStatus: string);
var nStr: string;
begin
  if (Pos(sFlag_NotMatter, nMsgNo) = 1) and (Pos('NT', nMsgNo) <> 1) then
  begin
    Exit;
  end;
  //������ģʽ�������

  nStr := 'Update %s Set S_Status=''%s'' ' +
          'Where S_SerailID=''%s'' And S_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialStatus, nStatus, nMsgNo, sFlag_AXMsgNo]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
end;

//Date: 2016-01-28
//Desc: ��AX��������ʱ��XMLĬ�Ͻڵ�
procedure TAXWorkerBase.BuildDefaultXMLPack;
begin
  with FXML do
  begin
    Clear;
    VersionString := '1.0';
    EncodingString := 'utf-8';

    XmlFormat := xfCompact;
    Root.Name := 'DATA';
    //first node
    
    with Root.NodeNew('HEAD') do
    begin
      NodeNew('CompanyID').ValueAsString := GetSystemCompanyID;
      NodeNew('MsgNo').ValueAsString := FDataIn.FMsgNO;

      if FDataIn.FKey = '0' then
           NodeNew('MsgStatus').ValueAsString := 'Y'
      else NodeNew('MsgStatus').ValueAsString := 'E'
    end;
  end;
end;

//Date: 2016-01-28
//Desc: ��ȡ��ǰϵͳ���ڵĹ�����ʶ
function TAXWorkerBase.GetSystemCompanyID: string;
var nStr: string;
begin
  if FCompanyID = '' then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_CompanyID]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
     if RecordCount > 0 then
      FCompanyID := Fields[0].AsString;
    //xxxxx
  end;

  Result := FCompanyID;
end;

//Date: 2016-01-15
//Parm: ����;���
//Desc: ����ҵ��������,ִ�н��
function TAXWorkerBase.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
  if not nResult then
  begin
    UpdateMsgStatus(FDataIn.FMSGNO, sFlag_No);
    Exit;
  end;

  Result := DoAfterCallAX(nData);
  if not Result then Exit;

  if FDataOut.FResult then
  begin
    Result := DoAfterCallAXDone(nData);
    if not Result then Exit;
  end; //business is done

  if FDataOut.FResult then
       FDataIn.FKEY := sFlag_Yes
  else FDataIn.FKEY := sFlag_No;

  UpdateMsgStatus(FDataIn.FMsgNO, FDataIn.FKEY);
  //update status
end;

//Date: 2016-01-15
//Parm: �������
//Desc: AX���ý�����
function TAXWorkerBase.DoAfterCallAX(var nData: string): Boolean;
begin
  Result := True;
end;

//Date: 2016-01-15
//Parm: �������
//Desc: AX���óɹ���
function TAXWorkerBase.DoAfterCallAXDone(var nData: string): Boolean;
begin
  Result := True;
end;

//Date: 2016-01-15
//Parm: �������
//Desc: ��ȡ����SAPʱ�������Դ
function TAXWorkerBase.DoDBWork(var nData: string): Boolean;
begin
  FChannel := nil;
  try
    Result := False;
    //default return

    if FDataIn.FMSGNO = '' then
    begin
      nData := '��Ч��ҵ��������(MsgNo Invalid).';
      Exit;
    end;

    FChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(FChannel) then
    begin
      nData := '����AX����ʧ��(BUS-MIT No Channel).';
      Exit;
    end;

    GetMsgNo(FDataIn.FMsgNO, FDataIn.FMsgNO, FDataIn.FKEY);
    //get serial message no

    with FChannel^ do
    begin
      if not Assigned(FChannel) then
        FChannel := CoWebService.Create(FMsg, FHttp);
      //xxxxx

      FHttp.TargetURL := gChannelChoolser.ActiveURL;
      Result := DoAXWork(nData);
    end;
  finally
    gChannelManager.ReleaseChannel(FChannel);
  end;
end;

//Date: 2016-01-28
//Desc: ����AX���ص������еĴ��������ڵ�
function TAXWorkerBase.DefaultParseError(const nData: string): Boolean;
var nIdx: Integer;
    nItem: TXmlNode;
begin
  with FXML,FDataOut^ do
  begin
    Result := False;
    nItem := Root.FindNode('EXMG');
    if not (Assigned(nItem) and (nItem.NodeCount > 0)) then Exit;

    FErrCode := '';
    FErrDesc := '';

    for nIdx:=0 to nItem.NodeCount - 1 do
    with nItem.Nodes[nIdx] do
    begin
      FErrCode := FErrCode + NodeByName('MsgType').ValueAsString + '.' + '00' + #9;
      FErrDesc := FErrDesc + NodeByName('MsgTxt').ValueAsString + #9;
    end;

    Result := True;
  end;
end;

//------------------------------------------------------------------------------
class function TAXWorkerReadSalesInfo.FunctionName: string;
begin
  Result := sAX_ReadSaleOrder;
end;

function TAXWorkerReadSalesInfo.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TAXWorkerReadSalesInfo.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

function TAXWorkerReadSalesInfo.GetStockType(var nData: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  with TWorkerBusinessCommander do
    Result := CallMe(cBC_GetStockItemInfo, nData, '', @nOut);
  //xxxxx
  
  if Result then
  begin
    FListC.Text := PackerDecodeStr(nOut.FData);
    nData := FListC.Values['Type'];
  end else
  begin
    nData := nOut.FData;
    Exit;
  end;
end;

function TAXWorkerReadSalesInfo.DoAXWork(var nData: string): Boolean;
var nIdx: Integer;
    nNode: TXmlNode;
begin
  Result := False;
  BuildDefaultXMLPack;

  with FXML.Root.NodeByName('HEAD') do
    NodeNew('CardNo').ValueAsString := FIn.FData;
  //xxxxx

  nData := IWebService(FChannel.FChannel).GetSalesInfoByCustCard(FXML.WriteToString);
  //remote call

  {$IFDEF DEBUG}
  WriteLog('TAXWorkerReadSalesInfo --> AX ::: ' + FXML.WriteToString);
  WriteLog('TAXWorkerReadSalesInfo <-- AX ::: ' + nData);
  {$ENDIF}

  FXML.ReadFromString(nData);
  if DefaultParseError(nData) then
  begin
    Result := True;
    Exit;
  end; //has any error

  FListA.Clear;
  nNode := FXML.Root.FindNode('Head');

  with FListA,nNode do
  begin
    Values['Card'] := NodeByName('Card').ValueAsString;
    Values['Amount'] := NodeByName('Amount').ValueAsString;
  end;

  nNode := FXML.Root.FindNode('Items');
  FListA.Values['DataNum'] := IntToStr(nNode.NodeCount);
  FListB.Clear;

  for nIdx:=0 to nNode.NodeCount - 1 do
  with FListB,nNode.Nodes[nIdx] do
  begin
    Values['Card'] := NodeByName('Card').ValueAsString;
    Values['CustAccount'] := NodeByName('CustAccount').ValueAsString;
    Values['CustName'] := NodeByName('CustName').ValueAsString;

    Values['DealerAccount'] := NodeByName('DealerAccount').ValueAsString;
    Values['DealerName'] := NodeByName('DealerName').ValueAsString;
    Values['ItemID'] := NodeByName('ItemID').ValueAsString;
    Values['ItemName'] := NodeByName('ItemName').ValueAsString;
    Values['Qty'] := NodeByName('Qty').ValueAsString;
    Values['Amount'] := NodeByName('Amount').ValueAsString;
    Values['Price'] := NodeByName('Price').ValueAsString;

    nData := Values['ItemID'];
    if not GetStockType(nData) then Exit;
    Values['ItemType'] := nData;

    FListA.Values['Data' + IntToStr(nIdx)] := PackerEncodeStr(FListB.Text);
    //
  end;

  Result := True;
  FOut.FBase.FResult := True;
  FOut.FData := PackerEncodeStr(FListA.Text); 
end;

//------------------------------------------------------------------------------
class function TAXWorkerReadOrdersInfo.FunctionName: string;
begin
  Result := sAX_ReadPuchaseOrder;
end;

function TAXWorkerReadOrdersInfo.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TAXWorkerReadOrdersInfo.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

function TAXWorkerReadOrdersInfo.DoAXWork(var nData: string): Boolean;
var nIdx: Integer;
    nNode: TXmlNode;
begin
  BuildDefaultXMLPack;

  with FXML.Root.NodeByName('HEAD') do
    NodeNew('VendAccount').ValueAsString := FIn.FData;
  //xxxxx

  nData := IWebService(FChannel.FChannel).GetPurchInfoByVendAccount(FXML.WriteToString);
  //remote call

  {$IFDEF DEBUG}
  WriteLog('TAXWorkerReadOrdersInfo --> AX ::: ' + FXML.WriteToString);
  WriteLog('TAXWorkerReadOrdersInfo <-- AX ::: ' + nData);
  {$ENDIF}

  FXML.ReadFromString(nData);
  if DefaultParseError(nData) then
  begin
    Result := True;
    Exit;
  end; //has any error

  FListA.Clear;
  nNode := FXML.Root.FindNode('Items');
  FListA.Values['DataNum'] := IntToStr(nNode.NodeCount);

  for nIdx:=0 to nNode.NodeCount - 1 do
  with FListB,nNode.Nodes[nIdx] do
  begin
    FListB.Clear;

    Values['VendAccount'] := NodeByName('VendAccount').ValueAsString;
    Values['ItemName'] := NodeByName('ItemName').ValueAsString;
    Values['ItemID'] := NodeByName('ItemID').ValueAsString;
    Values['Qty'] := NodeByName('Qty').ValueAsString;

    FListA.Values['Data' + IntToStr(nIdx)] := PackerEncodeStr(FListB.Text);
  end;

  Result := True;
  FOut.FBase.FResult := True;
  FOut.FData := PackerEncodeStr(FListA.Text); 
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TAXWorkerReadOrdersInfo.CallMe(const nData: string;
    const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FData := nData;
    nIn.FBase.FMsgNO := sFlag_NotMatter;
    nIn.FBase.FParam := sParam_NoHintOnError;

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
  gBusinessWorkerManager.RegisteWorker(TAXWorkerReadSalesInfo);
  gBusinessWorkerManager.RegisteWorker(TAXWorkerReadOrdersInfo);
end.
