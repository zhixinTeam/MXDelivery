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
    FListA,FListB,FListC: TStrings;
    //�����б�
    procedure GetMsgNo(nPairID: string; var nMsgNo,nKey: string);
    procedure UpdateMsgStatus(const nMsgNo,nStatus: string);
    //��Ϣ��
    function DoAXWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterCallAX(var nData: string): Boolean; virtual;
    function DoAfterCallAXDone(var nData: string): Boolean; virtual;
    //AX����
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
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoAXWork(var nData: string): Boolean; override;
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
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

function TAXWorkerReadSalesInfo.DoAXWork(var nData: string): Boolean;
var nNode: TXmlNode;
begin
  Result := False;
  nData := IWebService(FChannel.FChannel).GetSalesInfoByCustCard(FIn.FData);
  //remote call

  FXML.ReadFromString(nData);
  nNode := FXML.Root.FindNode('Item');
  
  if not Assigned(nNode) then
  begin
    nData := 'AX������Ч�ڵ�(Item Is Null).';
    Exit;
  end;

  nNode := nNode.FindNode('InvoiceCard');
  if not Assigned(nNode) then
  begin
    nData := '���ݺ���Ч,��AX���ش���(InvoiceCard Is Null).';
    Exit;
  end;

  FListA.Clear;
  with FListA,nNode do
  begin
    Values['Card'] := NodeByName('Card').ValueAsString;
    Values['CustAccount'] := NodeByName('CustAccount').ValueAsString;
    Values['DealerAccount'] := NodeByName('DealerAccount').ValueAsString;
    Values['ItemID'] := NodeByName('ItemID').ValueAsString;
    Values['ItemName'] := NodeByName('ItemName').ValueAsString;
    Values['Qty'] := NodeByName('Qty').ValueAsString;
    Values['Amount'] := NodeByName('Amount').ValueAsString;
    Values['Price'] := NodeByName('Price').ValueAsString;
  end;

  Result := True;
  FOut.FBase.FResult := True;
  FOut.FData := PackerEncodeStr(FListA.Text); 
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TAXWorkerReadSalesInfo);
end.
