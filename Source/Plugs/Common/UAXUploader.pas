{*******************************************************************************
  作者: dmzn@163.com 2016-02-26
  描述: 数据自动上行AX
*******************************************************************************}
unit UAXUploader;

interface

uses
  Windows, Classes, SysUtils, UBusinessConst, UWorkerBusinessRemote, UMgrDBConn,
  UWaitItem, ULibFun, USysDB, UMITConst, USysLoger;

type
  TAXUploader = class;
  TAXUploadThread = class(TThread)
  private
    FOwner: TAXUploader;
    //拥有者
    FDBConn: PDBWorker;
    //数据对象
    FListA,FListB: TStrings;
    //列表对象
    FNumUploadSale: Integer;
    FNumUploadProvide: Integer;
    FNumUploadDuanDao: Integer;
    FNumUploadWaiXie: Integer;
    //计时计数
    FWaiter: TWaitObject;
    //等待对象
    FSyncLock: TCrossProcWaitObject;
    //同步锁定
  protected
    procedure DoUploadSale;
    procedure DoUploadProvide;
    procedure DoUploadDuanDao;
    procedure DoUploadWaiXie;
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TAXUploader);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启止线程
  end;

  TAXUploader = class(TObject)
  private
    FThread: TAXUploadThread;
    //扫描线程
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure Start;
    procedure Stop;
    //起停上传
  end;

var
  gAXUploader: TAXUploader = nil;
  //全局使用

implementation

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TAXUploader, 'AX延时同步', nMsg);
end;

constructor TAXUploader.Create;
begin
  FThread := nil;
end;

destructor TAXUploader.Destroy;
begin
  Stop;
  inherited;
end;

procedure TAXUploader.Start;
begin
  if not Assigned(FThread) then
    FThread := TAXUploadThread.Create(Self);
  FThread.Wakeup;
end;

procedure TAXUploader.Stop;
begin
  if Assigned(FThread) then
    FThread.StopMe;
  FThread := nil;
end;

//------------------------------------------------------------------------------
constructor TAXUploadThread.Create(AOwner: TAXUploader);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  FListB := TStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 1000;
  //1 minute

  FSyncLock := TCrossProcWaitObject.Create('BusMIT_AXUpload_Sync');
  //process sync
end;

destructor TAXUploadThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TAXUploadThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TAXUploadThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TAXUploadThread.Execute;
var nErr: Integer;
    nInit: Int64;
begin
  FNumUploadSale    := 0;
  FNumUploadProvide := 0;
  FNumUploadDuanDao := 0;
  FNumUploadWaiXie  := 0;
  //init counter

  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Inc(FNumUploadSale);
    Inc(FNumUploadProvide);
    Inc(FNumUploadDuanDao);
    Inc(FNumUploadWaiXie);
    //inc counter

    if FNumUploadSale >= 5 then
      FNumUploadSale := 0;
    //销售上行: 12次/小时

    if FNumUploadProvide >= 10 then
      FNumUploadProvide := 0;
    //采购上行: 6次/小时

    if FNumUploadDuanDao >= 10 then
      FNumUploadDuanDao := 0;
    //短导上行: 6次/小时

    if FNumUploadWaiXie >= 10 then
      FNumUploadWaiXie := 0;
    //外协上行: 6次/小时

    if (FNumUploadSale <> 0) and (FNumUploadProvide <> 0) and
       (FNumUploadDuanDao <> 0) and (FNumUploadWaiXie <> 0)  then
      Continue;
    //无业务可做

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //其它进程正在执行                                                          
    
    FDBConn := nil;
    try
      FDBConn := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, nErr);
      if not Assigned(FDBConn) then Continue;

      if FNumUploadSale = 0 then
      begin
        WriteLog('上行销售数据...');
        nInit := GetTickCount;
        DoUploadSale;
        WriteLog('销售上行完毕,耗时: ' + IntToStr(GetTickCount - nInit));
      end;

      if FNumUploadProvide = 0 then
      begin
        WriteLog('上行采购数据...');
        nInit := GetTickCount;
        DoUploadProvide;
        WriteLog('采购上行完毕,耗时: ' + IntToStr(GetTickCount - nInit));
      end;

      if FNumUploadDuanDao = 0 then
      begin
        WriteLog('上行短倒数据...');
        nInit := GetTickCount;
        DoUploadDuanDao;
        WriteLog('短倒上行完毕,耗时: ' + IntToStr(GetTickCount - nInit));
      end;

      if FNumUploadWaiXie = 0 then
      begin
        WriteLog('上行外协数据...');
        nInit := GetTickCount;
        DoUploadWaiXie;
        WriteLog('外协上行完毕,耗时: ' + IntToStr(GetTickCount - nInit));
      end;
    finally
      FSyncLock.SyncLockLeave();
      gDBConnManager.ReleaseConnection(FDBConn);
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Date: 2016-02-26
//Desc: 交货单同步到AX
procedure TAXUploadThread.DoUploadSale;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := 'Select L_ID From %s ' +
          'Where L_SyncDate Is Null And L_SyncNum<=3 And L_OutFact Is Not null';
  nStr := Format(nStr, [sTable_Bill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := Fields[0].AsString;
      CallRemoteWorker(sAX_SyncBill, nStr, '', sFlag_FixedNo+'SL'+nStr, @nOut);
      Next;
    end;
  end;
end;

procedure TAXUploadThread.DoUploadProvide;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := 'Select P_ID From %s ' +
          'Where P_SyncDate Is Null And P_SyncNum<=3 And P_OutFact Is Not null';
  nStr := Format(nStr, [sTable_PurchInfo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := Fields[0].AsString;
      CallRemoteWorker(sAX_SyncOrder, nStr, '', sFlag_FixedNo+'SO'+nStr, @nOut);
      Next;
    end;
  end;
end;

procedure TAXUploadThread.DoUploadWaiXie;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := 'Select W_ID From %s ' +
          'Where W_SyncDate Is Null And W_SyncNum<=3 And W_OutFact2 Is Not null';
  nStr := Format(nStr, [sTable_WaiXieInfo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := Fields[0].AsString;
      CallRemoteWorker(sAX_SyncWaiXie, nStr, '', sFlag_FixedNo+'SW'+nStr, @nOut);
      Next;
    end;
  end;
end;

procedure TAXUploadThread.DoUploadDuanDao;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := 'Select T_ID From %s Where ' +
          'T_SyncDate Is Null And T_SyncNum<=3';
  nStr := Format(nStr, [sTable_Transfer]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := Fields[0].AsString;
      CallRemoteWorker(sAX_SyncDuanDao, nStr, '', sFlag_FixedNo+'SD'+nStr, @nOut);
      Next;
    end;
  end;
end;

initialization
  gAXUploader := nil;
finalization
  FreeAndNil(gAXUploader);
end.
