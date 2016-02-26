{*******************************************************************************
  作者: dmzn@163.com 2016-01-15
  描述: AX业务处理工作对象
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
    //数据通道
    FXML: TNativeXml;
    //数据解析
    FCompanyID: string;
    //工厂标识
    FListA,FListB,FListC,FListD: TStrings;
    //数据列表
    procedure BuildDefaultXMLPack;
    //XML默认请求包
    function GetSystemCompanyID: string;
    //系统所在工厂
    procedure GetMsgNo(nPairID: string; var nMsgNo,nKey: string);
    procedure UpdateMsgStatus(const nMsgNo,nStatus: string);
    //消息号
    function DoAXWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterCallAX(var nData: string): Boolean; virtual;
    function DoAfterCallAXDone(var nData: string): Boolean; virtual;
    //AX调用
    function DefaultParseError(const nData: string): Boolean;
    //默认错误处理
  public
    constructor Create; override;
    destructor Destroy; override;
    //创建释放
    function DoDBWork(var nData: string): Boolean; override;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; override;
    //执行业务
  end;

  TAXWorkerReadSalesInfo = class(TAXWorkerBase)
  protected
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    function GetStockType(var nData: string): Boolean;
    //获取物料类型
    procedure LoadCardFreezeList(const nCard: string);
    //载入冻结项
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoAXWork(var nData: string): Boolean; override;
  public
	function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
  end;

  TAXWorkerPickBill = class(TAXWorkerBase)
  protected
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoAXWork(var nData: string): Boolean; override;
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
  end;

  TAXWorkerSyncBill = class(TAXWorkerBase)
  protected
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoAXWork(var nData: string): Boolean; override; 
  public                                       
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; override;
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

  TAXWorkerSaveOrdersInfo = class(TAXWorkerBase)
  protected
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoAXWork(var nData: string): Boolean; override;

    function BuildBusinessXMLPack(var nData: string): Boolean;
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    class function CallMe(const nData: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

function CallRemoteWorker(const nWorkerName: string; const nData,nExt,nMsgNo: string;
 const nOut: PWorkerBusinessCommand; const nCmd: Integer = 0): Boolean;
//入口函数

implementation

uses
  ULibFun, UMgrDBConn, UChannelChooser, UAXService, USysDB, UFormCtrl,
  USysLoger;

//Date: 2014-09-15
//Parm: 对象;命令;数据;参数;输出
//Desc: 本地调用业务对象
function CallRemoteWorker(const nWorkerName: string; const nData,nExt,nMsgNo: string;
 const nOut: PWorkerBusinessCommand; const nCmd: Integer): Boolean;
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
    nIn.FBase.FMsgNO := nMsgNo;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nPacker.InitData(@nIn, True, False);
    //init

    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(nWorkerName);
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
constructor TAXWorkerBase.Create;
begin
  inherited;
  FXML := TNativeXml.Create;

  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
end;

destructor TAXWorkerBase.Destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  
  FreeAndNil(FXML);
  inherited;
end;

//Date: 2016-01-15
//Parm: 匹配号;消息号;重复标记
//Desc: 获取nPairID对应的nMsg和nKey
procedure TAXWorkerBase.GetMsgNo(nPairID: string; var nMsgNo, nKey: string);
var nStr: string;
begin
  if Pos(sFlag_ManualNo, nPairID) = 1 then
  begin
    nMsgNo := nPairID;
    System.Delete(nMsgNo, 1, Length(sFlag_ManualNo));
    Exit;
  end;
  //用户指定编号,系统不做任何动作

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
  //任意编号模式,除前缀外都是0

  if Pos(sFlag_FixedNo, nPairID) = 1 then
  begin
    nStr := 'Select Top 1 S_SerailID From %s ' +
            'Where S_PairID=''%s'' And S_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialStatus, nPairID, sFlag_AXMsgNo]);
  end else
  //指定编号模式,使用相同的编号

  if Pos(sFlag_ForceDone, nPairID) = 1 then
  begin
    nStr := 'Select Top 1 S_SerailID From %s ' +
            'Where S_Status=''%s'' And S_PairID=''%s'' And S_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialStatus, sFlag_Unknow,
            nPairID, sFlag_AXMsgNo]);
  end else
  //强制完成模式,完成前(Unknow)使用相同编号

  begin
    nStr := 'Select Top 1 S_SerailID From %s Where S_Date>%s-1 And ' +
            'S_Status=''%s'' And S_Object=''%s'' And S_PairID=''%s''';
    nStr := Format(nStr, [sTable_SerialStatus, sField_SQLServer_Now,
            sFlag_Unknow, sFlag_AXMsgNo, nPairID]);
  end;
  //常规模式,完成前(Unknow)编号一天内匹配

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
//Parm: 消息号;状态
//Desc: 更新nMsgNo的状态为nStatus
procedure TAXWorkerBase.UpdateMsgStatus(const nMsgNo, nStatus: string);
var nStr: string;
begin
  if (Pos(sFlag_NotMatter, nMsgNo) = 1) and (Pos('NT', nMsgNo) <> 1) then
  begin
    Exit;
  end;
  //任意编号模式无需更新

  nStr := 'Update %s Set S_Status=''%s'' ' +
          'Where S_SerailID=''%s'' And S_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialStatus, nStatus, nMsgNo, sFlag_AXMsgNo]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
end;

//Date: 2016-01-28
//Desc: 向AX发送请求时的XML默认节点
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
//Desc: 获取当前系统所在的工厂标识
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
//Parm: 数据;结果
//Desc: 数据业务调用完毕,执行结果
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
//Parm: 入参数据
//Desc: AX调用结束后
function TAXWorkerBase.DoAfterCallAX(var nData: string): Boolean;
begin
  Result := True;
end;

//Date: 2016-01-15
//Parm: 入参数据
//Desc: AX调用成功后
function TAXWorkerBase.DoAfterCallAXDone(var nData: string): Boolean;
begin
  Result := True;
end;

//Date: 2016-01-15
//Parm: 入参数据
//Desc: 获取连接SAP时所需的资源
function TAXWorkerBase.DoDBWork(var nData: string): Boolean;
var nInit: Int64;
begin
  FChannel := nil;
  try
    Result := False;
    //default return

    if FDataIn.FMSGNO = '' then
    begin
      nData := '无效的业务操作编号(MsgNo Invalid).';
      Exit;
    end;

    FChannel := gChannelManager.LockChannel(cBus_Channel_Business, mtSoap);
    if not Assigned(FChannel) then
    begin
      nData := '连接AX服务失败(BUS-MIT No Channel).';
      Exit;
    end;

    GetMsgNo(FDataIn.FMsgNO, FDataIn.FMsgNO, FDataIn.FKEY);
    //get serial message no

    with FChannel^ do
    begin
      if not Assigned(FChannel) then
        FChannel := CoWebService.Create(FMsg, FHttp);
      FHttp.TargetURL := gChannelChoolser.ActiveURL;

      nInit := GetTickCount;
      Result := DoAXWork(nData);
      WriteLog(Format('对象: %s 执行: %d毫秒', [FunctionName, GetTickCount-nInit]));
    end;
  finally
    gChannelManager.ReleaseChannel(FChannel);
  end;
end;

//Date: 2016-01-28
//Desc: 解析AX返回的数据中的错误描述节点
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

procedure TAXWorkerReadSalesInfo.LoadCardFreezeList(const nCard: string);
var nStr: string;
begin
  FListD.Clear;
  nStr := 'Select * From %s Where C_Card=''%s''';
  nStr := Format(nStr, [sTable_AX_CardInfo, nCard]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('C_Stock').AsString;
      FListD.Values[nStr] := FloatToStr(FieldByName('C_Freeze').AsFloat);
      
      Next;
    end;
  end;
end;

function TAXWorkerReadSalesInfo.DoAXWork(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nVal: Double;
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

  LoadCardFreezeList(FIn.FData);
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

    nStr := FListD.Values[Values['ItemID']];
    if IsNumber(nStr, True) then
    begin
      nVal := StrToFloat(Values['Qty']) - StrToFloat(nStr);
      //订单量 - 冻结量
      nVal := Float2Float(nVal, cPrecision, False);
      Values['Qty'] := FloatToStr(nVal);
    end;

    FListA.Values['Data' + IntToStr(nIdx)] := PackerEncodeStr(FListB.Text);
    //大卡明细
  end;

  Result := True;
  FOut.FBase.FResult := True;
  FOut.FData := PackerEncodeStr(FListA.Text); 
end;

//------------------------------------------------------------------------------
class function TAXWorkerPickBill.FunctionName: string;
begin
  Result := sAX_PickBill;
end;

function TAXWorkerPickBill.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TAXWorkerPickBill.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

function TAXWorkerPickBill.DoAXWork(var nData: string): Boolean;
var nStr: string;
    nNode: TXmlNode;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  BuildDefaultXMLPack;

  with FXML.Root.NodeByName('HEAD'),FListA do
  begin
    NodeNew('InvoiceCardId').ValueAsString := Values['Order'];
    NodeNew('ItemID').ValueAsString := Values['Stock'];
    NodeNew('Qty').ValueAsString := Values['Value'];
  end;

  nData := IWebService(FChannel.FChannel).CheckPassByQtyAmount(FXML.WriteToString);
  //remote call

  {$IFDEF DEBUG}
  WriteLog('TAXWorkerPickBill --> AX ::: ' + FXML.WriteToString);
  WriteLog('TAXWorkerPickBill <-- AX ::: ' + nData);
  {$ENDIF}

  FXML.ReadFromString(nData);
  nNode := FXML.Root.FindNode('HEAD');
  nStr := nNode.NodeByName('MsgStatus').ValueAsString;
  
  Result := CompareText(nStr, 'E') <> 0;
  //拣配错误标记为E.

  if not Result then
    if DefaultParseError(nData) then
         nData := FOut.FBase.FErrDesc
    else nData := '单据拣配失败,请联系管理员.';
  //xxxxx
end;

//------------------------------------------------------------------------------
class function TAXWorkerSyncBill.FunctionName: string;
begin
  Result := sAX_SyncBill;
end;

function TAXWorkerSyncBill.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TAXWorkerSyncBill.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

function TAXWorkerSyncBill.DoAXWork(var nData: string): Boolean;
var nStr: string;
    nNode,nTmp: TXmlNode;
begin
  Result := False;
  BuildDefaultXMLPack;

  nStr := 'Select * From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('交货单[ %s ]已无效.', [FIn.FData]);
      Exit;
    end;
            
    with FXML.Root.NodeByName('HEAD') do
    begin
      NodeNew('BizID').ValueAsString := FieldByName('L_ID').AsString;
      NodeNew('InvoiceCardId').ValueAsString := FieldByName('L_ZhiKa').AsString;
      NodeNew('ItemID').ValueAsString := FieldByName('L_StockNo').AsString;
      NodeNew('ItemType').ValueAsString := FieldByName('L_Type').AsString;
      NodeNew('VehicleNum').ValueAsString := FieldByName('L_Truck').AsString;
      NodeNew('PresetVolume').ValueAsString := FieldByName('L_Value').AsString;
      NodeNew('CarSenderUnit').ValueAsString := FieldByName('L_SaleMan').AsString;
      NodeNew('IssueCardDateTime').ValueAsString := FieldByName('L_Date').AsString;
      NodeNew('TareDateTime').ValueAsString := FieldByName('L_PDate').AsString;
      NodeNew('PacklistDateTime').ValueAsString := FieldByName('L_LadeTime').AsString;
      NodeNew('GrossDateTime').ValueAsString := FieldByName('L_MDate').AsString;
      NodeNew('PackSlipDateTime').ValueAsString := FieldByName('L_OutFact').AsString;
      NodeNew('TareVolume').ValueAsString := FieldByName('L_PValue').AsString;
      NodeNew('GrossVolume').ValueAsString := FieldByName('L_MValue').AsString;
      NodeNew('BagQty').ValueAsString := FieldByName('L_DaiTotal').AsString;
      NodeNew('BadBagQty').ValueAsString := FieldByName('L_DaiBuCha').AsString;
      NodeNew('CheckBatchID').ValueAsString := FieldByName('L_HYDan').AsString;
      NodeNew('ProportionID').ValueAsString := '?';
      NodeNew('WrkCtrId').ValueAsString := FieldByName('L_LadeLine').AsString;
    end;
  end;

  nData := IWebService(FChannel.FChannel).SetSalesPackingSlip(FXML.WriteToString);
  //remote call

  {$IFDEF DEBUG}
  WriteLog('TAXWorkerSyncBill --> AX ::: ' + FXML.WriteToString);
  WriteLog('TAXWorkerSyncBill <-- AX ::: ' + nData);
  {$ENDIF}

  FXML.ReadFromString(nData);
  nNode := FXML.Root.FindNode('EXMG');
  if not (Assigned(nNode) and Assigned(nNode.FindNode('Item'))) then
  begin
    nData := 'AX返回无效节点(EXMG.Item Null).';
    Exit;
  end;

  nNode := nNode.NodeByName('Item');
  Result := nNode.NodeByName('MsgType').ValueAsString = '1';
  nTmp := nNode.FindNode('MsgTxt');

  if Assigned(nTmp) then
       nData := nTmp.ValueAsString
  else nData := 'AX未描述的错误.';
end;

function TAXWorkerSyncBill.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
var nStr: string;
begin
  Result := inherited DoAfterDBWork(nData, nResult);
  //parent default

  if nResult then //同步成功
  begin
    nStr := 'Update %s Set L_SyncNum=L_SyncNum+1,L_SyncDate=%s,L_SyncMemo=Null ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, sField_SQLServer_Now, FIn.FData]);
  end else
  begin
    nStr := 'Update %s Set L_SyncNum=L_SyncNum+1,L_SyncMemo=''%s'' ' +
            'Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nData, FIn.FData]);
  end;

  gDBConnManager.WorkerExec(FDBConn, nStr);
  //write sync status
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
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
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

//------------------------------------------------------------------------------
class function TAXWorkerSaveOrdersInfo.FunctionName: string;
begin
  Result := sAX_SavePuchaseOrder;
end;

function TAXWorkerSaveOrdersInfo.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TAXWorkerSaveOrdersInfo.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

function TAXWorkerSaveOrdersInfo.BuildBusinessXMLPack(var nData: string): Boolean;
var nSQL, nID: string;
begin
  Result := False;
  nID := UpperCase(FIn.FData);

  nSQL := 'Select * From %s Where P_ID=''%s''';
  nSQL := Format(nSQL, [sTable_PurchInfo, nID]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL),FXML.Root.NodeByName('HEAD') do
  begin
    if RecordCount < 1 then
    begin
      nData := '入厂单[ %s ]数据已丢失.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    NodeNew('BizID').ValueAsString := FieldByName('P_ID').AsString;
    NodeNew('ItemID').ValueAsString := FieldByName('P_StockID').AsString;
    NodeNew('VehicleNum').ValueAsString  := FieldByName('P_Truck').AsString;
    NodeNew('VendAccount').ValueAsString := FieldByName('P_ProID').AsString;
    NodeNew('CarrierVendAccount').ValueAsString := FieldByName('P_TransID').AsString;

    NodeNew('TareDateTime').ValueAsString := FieldByName('P_PDate').AsString;
    NodeNew('GrossDateTime').ValueAsString := FieldByName('P_MDate').AsString;
    NodeNew('IssueCardDateTime').ValueAsString := FieldByName('P_Date').AsString;
    NodeNew('PackSlipDateTime').ValueAsString := FieldByName('P_OutFact').AsString;

    NodeNew('TareVolume').ValueAsString := FieldByName('P_PValue').AsString;
    NodeNew('PresetVolume').ValueAsString := FieldByName('P_Value').AsString;
    NodeNew('GrossVolume').ValueAsString := FieldByName('P_MValue').AsString;
  end;

  Result := True;
end;

function TAXWorkerSaveOrdersInfo.DoAXWork(var nData: string): Boolean;
begin
  Result := False;
  BuildDefaultXMLPack;

  if not BuildBusinessXMLPack(nData) then Exit;

  nData := IWebService(FChannel.FChannel).SetPurchPackingSlip(FXML.WriteToString);
  //remote call

  {$IFDEF DEBUG}
  WriteLog('TAXWorkerSaveOrdersInfo --> AX ::: ' + FXML.WriteToString);
  WriteLog('TAXWorkerSaveOrdersInfo <-- AX ::: ' + nData);
  {$ENDIF}

  FXML.ReadFromString(nData);
  if DefaultParseError(nData) then
  begin
    Result := True;
    Exit;
  end; //has any error

  Result := True;
  FOut.FBase.FResult := True;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TAXWorkerSaveOrdersInfo.CallMe(const nData: string;
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
    nIn.FBase.FMsgNO := sFlag_ForceDone;
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
  gBusinessWorkerManager.RegisteWorker(TAXWorkerPickBill);
  gBusinessWorkerManager.RegisteWorker(TAXWorkerSyncBill);
  gBusinessWorkerManager.RegisteWorker(TAXWorkerReadOrdersInfo);
  gBusinessWorkerManager.RegisteWorker(TAXWorkerSaveOrdersInfo);
end.
