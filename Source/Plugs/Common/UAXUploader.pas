{*******************************************************************************
  ����: dmzn@163.com 2016-02-26
  ����: �����Զ�����AX
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
    //ӵ����
    FDBConn: PDBWorker;
    //���ݶ���
    FListA,FListB: TStrings;
    //�б����
    FNumUploadSale: Integer;
    FNumUploadProvide: Integer;
    FNumUploadDuanDao: Integer;
    FNumUploadWaiXie: Integer;
    //��ʱ����
    FWaiter: TWaitObject;
    //�ȴ�����
    FSyncLock: TCrossProcWaitObject;
    //ͬ������
  protected
    procedure DoUploadSale;
    procedure DoUploadProvide;
    procedure DoUploadDuanDao;
    procedure DoUploadWaiXie;
    procedure Execute; override;
    //ִ���߳�
  public
    constructor Create(AOwner: TAXUploader);
    destructor Destroy; override;
    //�����ͷ�
    procedure Wakeup;
    procedure StopMe;
    //��ֹ�߳�
  end;

  TAXUploader = class(TObject)
  private
    FThread: TAXUploadThread;
    //ɨ���߳�
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure Start;
    procedure Stop;
    //��ͣ�ϴ�
  end;

var
  gAXUploader: TAXUploader = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TAXUploader, 'AX��ʱͬ��', nMsg);
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
    //��������: 12��/Сʱ

    if FNumUploadProvide >= 10 then
      FNumUploadProvide := 0;
    //�ɹ�����: 6��/Сʱ

    if FNumUploadDuanDao >= 10 then
      FNumUploadDuanDao := 0;
    //�̵�����: 6��/Сʱ

    if FNumUploadWaiXie >= 10 then
      FNumUploadWaiXie := 0;
    //��Э����: 6��/Сʱ

    if (FNumUploadSale <> 0) and (FNumUploadProvide <> 0) and
       (FNumUploadDuanDao <> 0) and (FNumUploadWaiXie <> 0)  then
      Continue;
    //��ҵ�����

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //������������ִ��                                                          
    
    FDBConn := nil;
    try
      FDBConn := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, nErr);
      if not Assigned(FDBConn) then Continue;

      if FNumUploadSale = 0 then
      begin
        WriteLog('������������...');
        nInit := GetTickCount;
        DoUploadSale;
        WriteLog('�����������,��ʱ: ' + IntToStr(GetTickCount - nInit));
      end;

      if FNumUploadProvide = 0 then
      begin
        WriteLog('���вɹ�����...');
        nInit := GetTickCount;
        DoUploadProvide;
        WriteLog('�ɹ��������,��ʱ: ' + IntToStr(GetTickCount - nInit));
      end;

      if FNumUploadDuanDao = 0 then
      begin
        WriteLog('���ж̵�����...');
        nInit := GetTickCount;
        DoUploadDuanDao;
        WriteLog('�̵��������,��ʱ: ' + IntToStr(GetTickCount - nInit));
      end;

      if FNumUploadWaiXie = 0 then
      begin
        WriteLog('������Э����...');
        nInit := GetTickCount;
        DoUploadWaiXie;
        WriteLog('��Э�������,��ʱ: ' + IntToStr(GetTickCount - nInit));
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
//Desc: ������ͬ����AX
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
