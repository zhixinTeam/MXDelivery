unit UAXService;

{----------------------------------------------------------------------------}
{ This unit was automatically generated by the RemObjects SDK after reading  }
{ the RODL file associated with this project .                               }
{                                                                            }
{ Do not modify this unit manually, or your changes will be lost when this   }
{ unit is regenerated the next time you compile the project.                 }
{----------------------------------------------------------------------------}

{$I RemObjects.inc}

interface

uses
  {vcl:} Classes, TypInfo,
  {RemObjects:} uROXMLIntf, uROClasses, uROClient, uROTypes, uROClientIntf;

const
  { Library ID }
  LibraryUID = '{00E8A6F8-9FF7-470D-9790-651DE0738279}';
  WSDLLocation = 'http://10.9.1.97/CardTransToERP/webService.asmx?WSDL';
  TargetNamespace = 'http://tempuri.org/';

  { Service Interface ID's }
  IWebService_IID : TGUID = '{D83E801E-FD56-461B-A537-79CF88AFC5B1}';
  WebService_EndPointURI = 'http://10.9.1.97/CardTransToERP/webService.asmx';

  { Event ID's }

type
  { Forward declarations }
  IWebService = interface;


  { IWebService }
  IWebService = interface
    ['{D83E801E-FD56-461B-A537-79CF88AFC5B1}']
    function HelloWorld: WideString;
    function test: WideString;
    function GetSalesInfoByCustCard(const _xml: WideString): WideString;
    function GetPurchInfoByVendAccount(const _xml: WideString): WideString;
    function CheckPassByQtyAmount(const _xml: WideString): WideString;
    function SetSalesPackingSlip(const _xml: WideString): WideString;
    function SetPurchPackingSlip(const _xml: WideString): WideString;
    function SetOutSourceWeight(const _xml: WideString): WideString;
    function SetItemTransfer(const _xml: WideString): WideString;
  end;

  { CoWebService }
  CoWebService = class
    class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): IWebService;
  end;

  { TWebService_Proxy }
  TWebService_Proxy = class(TROProxy, IWebService)
  protected
    function __GetInterfaceName:string; override;

    function HelloWorld: WideString;
    function test: WideString;
    function GetSalesInfoByCustCard(const _xml: WideString): WideString;
    function GetPurchInfoByVendAccount(const _xml: WideString): WideString;
    function CheckPassByQtyAmount(const _xml: WideString): WideString;
    function SetSalesPackingSlip(const _xml: WideString): WideString;
    function SetPurchPackingSlip(const _xml: WideString): WideString;
    function SetOutSourceWeight(const _xml: WideString): WideString;
    function SetItemTransfer(const _xml: WideString): WideString;
  end;

implementation

uses
  {vcl:} SysUtils,
  {RemObjects:} uROEventRepository, uROSerializer, uRORes;

{ CoWebService }

class function CoWebService.Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): IWebService;
begin
  result := TWebService_Proxy.Create(aMessage, aTransportChannel);
end;

{ TWebService_Proxy }

function TWebService_Proxy.__GetInterfaceName:string;
begin
  result := 'WebService';
end;

function TWebService_Proxy.HelloWorld: WideString;
begin
    __Message.SetAttributes(__TransportChannel, ['Action', 'Location', 'remap_CheckPassByQtyAmount', 'remap_GetPurchInfoByVendAccount', 'remap_GetSalesInfoByCustCard', 'remap_HelloWorld', 'remap_SetItemTransfer'
      , 'remap_SetOutSourceWeight', 'remap_SetPurchPackingSlip', 'remap_SetSalesPackingSlip', 'remap_test', 'SOAPInputNameOverride', 'SOAPOutputNameOverride', 'Style', 'TargetNamespace'
      , 'Type', 'Use', 'Wsdl'], 
      ['http://tempuri.org/HelloWorld', 'http://10.9.1.97/CardTransToERP/webService.asmx', 'http://tempuri.org/CheckPassByQtyAmount', 'http://tempuri.org/GetPurchInfoByVendAccount', 'http://tempuri.org/GetSalesInfoByCustCard', 'http://tempuri.org/HelloWorld', 'http://tempuri.org/SetItemTransfer'
      , 'http://tempuri.org/SetOutSourceWeight', 'http://tempuri.org/SetPurchPackingSlip', 'http://tempuri.org/SetSalesPackingSlip', 'http://tempuri.org/test', 'HelloWorld', 'HelloWorldResponse', 'document', TargetNamespace
      , 'SOAP', 'literal', WSDLLocation]);
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'HelloWorld');
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('HelloWorldResult', TypeInfo(WideString), result, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TWebService_Proxy.test: WideString;
begin
    __Message.SetAttributes(__TransportChannel, ['Action', 'Location', 'remap_CheckPassByQtyAmount', 'remap_GetPurchInfoByVendAccount', 'remap_GetSalesInfoByCustCard', 'remap_HelloWorld', 'remap_SetItemTransfer'
      , 'remap_SetOutSourceWeight', 'remap_SetPurchPackingSlip', 'remap_SetSalesPackingSlip', 'remap_test', 'SOAPInputNameOverride', 'SOAPOutputNameOverride', 'Style', 'TargetNamespace'
      , 'Type', 'Use', 'Wsdl'], 
      ['http://tempuri.org/test', 'http://10.9.1.97/CardTransToERP/webService.asmx', 'http://tempuri.org/CheckPassByQtyAmount', 'http://tempuri.org/GetPurchInfoByVendAccount', 'http://tempuri.org/GetSalesInfoByCustCard', 'http://tempuri.org/HelloWorld', 'http://tempuri.org/SetItemTransfer'
      , 'http://tempuri.org/SetOutSourceWeight', 'http://tempuri.org/SetPurchPackingSlip', 'http://tempuri.org/SetSalesPackingSlip', 'http://tempuri.org/test', 'test', 'testResponse', 'document', TargetNamespace
      , 'SOAP', 'literal', WSDLLocation]);
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'test');
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('testResult', TypeInfo(WideString), result, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TWebService_Proxy.GetSalesInfoByCustCard(const _xml: WideString): WideString;
begin
    __Message.SetAttributes(__TransportChannel, ['Action', 'Location', 'remap_CheckPassByQtyAmount', 'remap_GetPurchInfoByVendAccount', 'remap_GetSalesInfoByCustCard', 'remap_HelloWorld', 'remap_SetItemTransfer'
      , 'remap_SetOutSourceWeight', 'remap_SetPurchPackingSlip', 'remap_SetSalesPackingSlip', 'remap_test', 'SOAPInputNameOverride', 'SOAPOutputNameOverride', 'Style', 'TargetNamespace'
      , 'Type', 'Use', 'Wsdl'], 
      ['http://tempuri.org/GetSalesInfoByCustCard', 'http://10.9.1.97/CardTransToERP/webService.asmx', 'http://tempuri.org/CheckPassByQtyAmount', 'http://tempuri.org/GetPurchInfoByVendAccount', 'http://tempuri.org/GetSalesInfoByCustCard', 'http://tempuri.org/HelloWorld', 'http://tempuri.org/SetItemTransfer'
      , 'http://tempuri.org/SetOutSourceWeight', 'http://tempuri.org/SetPurchPackingSlip', 'http://tempuri.org/SetSalesPackingSlip', 'http://tempuri.org/test', 'GetSalesInfoByCustCard', 'GetSalesInfoByCustCardResponse', 'document', TargetNamespace
      , 'SOAP', 'literal', WSDLLocation]);
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'GetSalesInfoByCustCard');
    __Message.Write('_xml', TypeInfo(WideString), _xml, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('GetSalesInfoByCustCardResult', TypeInfo(WideString), result, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TWebService_Proxy.GetPurchInfoByVendAccount(const _xml: WideString): WideString;
begin
    __Message.SetAttributes(__TransportChannel, ['Action', 'Location', 'remap_CheckPassByQtyAmount', 'remap_GetPurchInfoByVendAccount', 'remap_GetSalesInfoByCustCard', 'remap_HelloWorld', 'remap_SetItemTransfer'
      , 'remap_SetOutSourceWeight', 'remap_SetPurchPackingSlip', 'remap_SetSalesPackingSlip', 'remap_test', 'SOAPInputNameOverride', 'SOAPOutputNameOverride', 'Style', 'TargetNamespace'
      , 'Type', 'Use', 'Wsdl'], 
      ['http://tempuri.org/GetPurchInfoByVendAccount', 'http://10.9.1.97/CardTransToERP/webService.asmx', 'http://tempuri.org/CheckPassByQtyAmount', 'http://tempuri.org/GetPurchInfoByVendAccount', 'http://tempuri.org/GetSalesInfoByCustCard', 'http://tempuri.org/HelloWorld', 'http://tempuri.org/SetItemTransfer'
      , 'http://tempuri.org/SetOutSourceWeight', 'http://tempuri.org/SetPurchPackingSlip', 'http://tempuri.org/SetSalesPackingSlip', 'http://tempuri.org/test', 'GetPurchInfoByVendAccount', 'GetPurchInfoByVendAccountResponse', 'document', TargetNamespace
      , 'SOAP', 'literal', WSDLLocation]);
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'GetPurchInfoByVendAccount');
    __Message.Write('_xml', TypeInfo(WideString), _xml, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('GetPurchInfoByVendAccountResult', TypeInfo(WideString), result, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TWebService_Proxy.CheckPassByQtyAmount(const _xml: WideString): WideString;
begin
    __Message.SetAttributes(__TransportChannel, ['Action', 'Location', 'remap_CheckPassByQtyAmount', 'remap_GetPurchInfoByVendAccount', 'remap_GetSalesInfoByCustCard', 'remap_HelloWorld', 'remap_SetItemTransfer'
      , 'remap_SetOutSourceWeight', 'remap_SetPurchPackingSlip', 'remap_SetSalesPackingSlip', 'remap_test', 'SOAPInputNameOverride', 'SOAPOutputNameOverride', 'Style', 'TargetNamespace'
      , 'Type', 'Use', 'Wsdl'], 
      ['http://tempuri.org/CheckPassByQtyAmount', 'http://10.9.1.97/CardTransToERP/webService.asmx', 'http://tempuri.org/CheckPassByQtyAmount', 'http://tempuri.org/GetPurchInfoByVendAccount', 'http://tempuri.org/GetSalesInfoByCustCard', 'http://tempuri.org/HelloWorld', 'http://tempuri.org/SetItemTransfer'
      , 'http://tempuri.org/SetOutSourceWeight', 'http://tempuri.org/SetPurchPackingSlip', 'http://tempuri.org/SetSalesPackingSlip', 'http://tempuri.org/test', 'CheckPassByQtyAmount', 'CheckPassByQtyAmountResponse', 'document', TargetNamespace
      , 'SOAP', 'literal', WSDLLocation]);
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'CheckPassByQtyAmount');
    __Message.Write('_xml', TypeInfo(WideString), _xml, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('CheckPassByQtyAmountResult', TypeInfo(WideString), result, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TWebService_Proxy.SetSalesPackingSlip(const _xml: WideString): WideString;
begin
    __Message.SetAttributes(__TransportChannel, ['Action', 'Location', 'remap_CheckPassByQtyAmount', 'remap_GetPurchInfoByVendAccount', 'remap_GetSalesInfoByCustCard', 'remap_HelloWorld', 'remap_SetItemTransfer'
      , 'remap_SetOutSourceWeight', 'remap_SetPurchPackingSlip', 'remap_SetSalesPackingSlip', 'remap_test', 'SOAPInputNameOverride', 'SOAPOutputNameOverride', 'Style', 'TargetNamespace'
      , 'Type', 'Use', 'Wsdl'], 
      ['http://tempuri.org/SetSalesPackingSlip', 'http://10.9.1.97/CardTransToERP/webService.asmx', 'http://tempuri.org/CheckPassByQtyAmount', 'http://tempuri.org/GetPurchInfoByVendAccount', 'http://tempuri.org/GetSalesInfoByCustCard', 'http://tempuri.org/HelloWorld', 'http://tempuri.org/SetItemTransfer'
      , 'http://tempuri.org/SetOutSourceWeight', 'http://tempuri.org/SetPurchPackingSlip', 'http://tempuri.org/SetSalesPackingSlip', 'http://tempuri.org/test', 'SetSalesPackingSlip', 'SetSalesPackingSlipResponse', 'document', TargetNamespace
      , 'SOAP', 'literal', WSDLLocation]);
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'SetSalesPackingSlip');
    __Message.Write('_xml', TypeInfo(WideString), _xml, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('SetSalesPackingSlipResult', TypeInfo(WideString), result, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TWebService_Proxy.SetPurchPackingSlip(const _xml: WideString): WideString;
begin
    __Message.SetAttributes(__TransportChannel, ['Action', 'Location', 'remap_CheckPassByQtyAmount', 'remap_GetPurchInfoByVendAccount', 'remap_GetSalesInfoByCustCard', 'remap_HelloWorld', 'remap_SetItemTransfer'
      , 'remap_SetOutSourceWeight', 'remap_SetPurchPackingSlip', 'remap_SetSalesPackingSlip', 'remap_test', 'SOAPInputNameOverride', 'SOAPOutputNameOverride', 'Style', 'TargetNamespace'
      , 'Type', 'Use', 'Wsdl'], 
      ['http://tempuri.org/SetPurchPackingSlip', 'http://10.9.1.97/CardTransToERP/webService.asmx', 'http://tempuri.org/CheckPassByQtyAmount', 'http://tempuri.org/GetPurchInfoByVendAccount', 'http://tempuri.org/GetSalesInfoByCustCard', 'http://tempuri.org/HelloWorld', 'http://tempuri.org/SetItemTransfer'
      , 'http://tempuri.org/SetOutSourceWeight', 'http://tempuri.org/SetPurchPackingSlip', 'http://tempuri.org/SetSalesPackingSlip', 'http://tempuri.org/test', 'SetPurchPackingSlip', 'SetPurchPackingSlipResponse', 'document', TargetNamespace
      , 'SOAP', 'literal', WSDLLocation]);
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'SetPurchPackingSlip');
    __Message.Write('_xml', TypeInfo(WideString), _xml, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('SetPurchPackingSlipResult', TypeInfo(WideString), result, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TWebService_Proxy.SetOutSourceWeight(const _xml: WideString): WideString;
begin
    __Message.SetAttributes(__TransportChannel, ['Action', 'Location', 'remap_CheckPassByQtyAmount', 'remap_GetPurchInfoByVendAccount', 'remap_GetSalesInfoByCustCard', 'remap_HelloWorld', 'remap_SetItemTransfer'
      , 'remap_SetOutSourceWeight', 'remap_SetPurchPackingSlip', 'remap_SetSalesPackingSlip', 'remap_test', 'SOAPInputNameOverride', 'SOAPOutputNameOverride', 'Style', 'TargetNamespace'
      , 'Type', 'Use', 'Wsdl'], 
      ['http://tempuri.org/SetOutSourceWeight', 'http://10.9.1.97/CardTransToERP/webService.asmx', 'http://tempuri.org/CheckPassByQtyAmount', 'http://tempuri.org/GetPurchInfoByVendAccount', 'http://tempuri.org/GetSalesInfoByCustCard', 'http://tempuri.org/HelloWorld', 'http://tempuri.org/SetItemTransfer'
      , 'http://tempuri.org/SetOutSourceWeight', 'http://tempuri.org/SetPurchPackingSlip', 'http://tempuri.org/SetSalesPackingSlip', 'http://tempuri.org/test', 'SetOutSourceWeight', 'SetOutSourceWeightResponse', 'document', TargetNamespace
      , 'SOAP', 'literal', WSDLLocation]);
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'SetOutSourceWeight');
    __Message.Write('_xml', TypeInfo(WideString), _xml, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('SetOutSourceWeightResult', TypeInfo(WideString), result, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TWebService_Proxy.SetItemTransfer(const _xml: WideString): WideString;
begin
    __Message.SetAttributes(__TransportChannel, ['Action', 'Location', 'remap_CheckPassByQtyAmount', 'remap_GetPurchInfoByVendAccount', 'remap_GetSalesInfoByCustCard', 'remap_HelloWorld', 'remap_SetItemTransfer'
      , 'remap_SetOutSourceWeight', 'remap_SetPurchPackingSlip', 'remap_SetSalesPackingSlip', 'remap_test', 'SOAPInputNameOverride', 'SOAPOutputNameOverride', 'Style', 'TargetNamespace'
      , 'Type', 'Use', 'Wsdl'], 
      ['http://tempuri.org/SetItemTransfer', 'http://10.9.1.97/CardTransToERP/webService.asmx', 'http://tempuri.org/CheckPassByQtyAmount', 'http://tempuri.org/GetPurchInfoByVendAccount', 'http://tempuri.org/GetSalesInfoByCustCard', 'http://tempuri.org/HelloWorld', 'http://tempuri.org/SetItemTransfer'
      , 'http://tempuri.org/SetOutSourceWeight', 'http://tempuri.org/SetPurchPackingSlip', 'http://tempuri.org/SetSalesPackingSlip', 'http://tempuri.org/test', 'SetItemTransfer', 'SetItemTransferResponse', 'document', TargetNamespace
      , 'SOAP', 'literal', WSDLLocation]);
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'NewLibrary', __InterfaceName, 'SetItemTransfer');
    __Message.Write('_xml', TypeInfo(WideString), _xml, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('SetItemTransferResult', TypeInfo(WideString), result, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

initialization
  RegisterProxyClass(IWebService_IID, TWebService_Proxy);


finalization
  UnregisterProxyClass(IWebService_IID);

end.
