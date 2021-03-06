{*******************************************************************************
  作者: dmzn@163.com 2008-08-07
  描述: 系统数据库常量定义

  备注:
  *.自动创建SQL语句,支持变量:$Inc,自增;$Float,浮点;$Integer=sFlag_Integer;
    $Decimal=sFlag_Decimal;$Image,二进制流
*******************************************************************************}
unit USysDB;

{$I Link.inc}
interface

uses
  SysUtils, Classes;

const
  cSysDatabaseName: array[0..4] of String = (
     'Access', 'SQL', 'MySQL', 'Oracle', 'DB2');
  //db names

  cPrecision            = 100;
  {-----------------------------------------------------------------------------
   描述: 计算精度
   *.重量为吨的计算中,小数值比较或者相减运算时会有误差,所以会先放大,去掉
     小数位后按照整数计算.放大倍数由精度值确定.
  -----------------------------------------------------------------------------}

type
  TSysDatabaseType = (dtAccess, dtSQLServer, dtMySQL, dtOracle, dtDB2);
  //db types

  PSysTableItem = ^TSysTableItem;
  TSysTableItem = record
    FTable: string;
    FNewSQL: string;
  end;
  //系统表项

var
  gSysTableList: TList = nil;                        //系统表数组
  gSysDBType: TSysDatabaseType = dtSQLServer;        //系统数据类型

//------------------------------------------------------------------------------
const
  //自增字段
  sField_Access_AutoInc          = 'Counter';
  sField_SQLServer_AutoInc       = 'Integer IDENTITY (1,1) PRIMARY KEY';

  //小数字段
  sField_Access_Decimal          = 'Float';
  sField_SQLServer_Decimal       = 'Decimal(15, 5)';

  //图片字段
  sField_Access_Image            = 'OLEObject';
  sField_SQLServer_Image         = 'Image';

  //日期相关
  sField_SQLServer_Now           = 'getDate()';

ResourceString     
  {*权限项*}
  sPopedom_Read       = 'A';                         //浏览
  sPopedom_Add        = 'B';                         //添加
  sPopedom_Edit       = 'C';                         //修改
  sPopedom_Delete     = 'D';                         //删除
  sPopedom_Preview    = 'E';                         //预览
  sPopedom_Print      = 'F';                         //打印
  sPopedom_Export     = 'G';                         //导出
  sPopedom_ViewPrice  = 'H';                         //查看单价

  {*数据库标识*}
  sFlag_DB_K3         = 'King_K3';                   //金蝶数据库
  sFlag_DB_NC         = 'YonYou_NC';                 //用友数据库

  {*相关标记*}
  sFlag_Yes           = 'Y';                         //是
  sFlag_No            = 'N';                         //否
  sFlag_Unknow        = 'U';                         //未知 
  sFlag_Enabled       = 'Y';                         //启用
  sFlag_Disabled      = 'N';                         //禁用
  sFlag_Delimiter     = '@';                         //分割符

  sFlag_Integer       = 'I';                         //整数
  sFlag_Decimal       = 'D';                         //小数

  sFlag_ManualNo      = '%';                         //手动指定(非系统自动)
  sFlag_NotMatter     = '@';                         //无关编号(任意编号都可)
  sFlag_ForceDone     = '#';                         //强制完成(未完成前不换)
  sFlag_FixedNo       = '$';                         //指定编号(使用相同编号)

  sFlag_Provide       = 'P';                         //供应
  sFlag_Sale          = 'S';                         //销售
  sFlag_Returns       = 'R';                         //退货
  sFlag_Other         = 'O';                         //其它
  sFlag_DuanDao       = 'D';                         //短倒(预制皮重,单次称重)
  sFlag_WaiXie        = 'W';                         //外协(进-重-出-进-皮-出)
  sFlag_Refund        = 'F';                         //退货(进-重-皮-出)(袋装不过磅)
  
  sFlag_TiHuo         = 'T';                         //自提
  sFlag_SongH         = 'S';                         //送货
  sFlag_XieH          = 'X';                         //运卸

  sFlag_Dai           = 'D';                         //袋装水泥
  sFlag_San           = 'S';                         //散装水泥

  sFlag_BillNew       = 'N';                         //新单
  sFlag_BillEdit      = 'E';                         //修改
  sFlag_BillDel       = 'D';                         //删除
  sFlag_BillLading    = 'L';                         //提货中
  sFlag_BillPick      = 'P';                         //拣配
  sFlag_BillPost      = 'G';                         //过账
  sFlag_BillDone      = 'O';                         //完成

  sFlag_TypeShip      = 'S';                         //船运
  sFlag_TypeZT        = 'Z';                         //栈台
  sFlag_TypeVIP       = 'V';                         //VIP
  sFlag_TypeCommon    = 'C';                         //普通,订单类型

  sFlag_CardIdle      = 'I';                         //空闲卡
  sFlag_CardUsed      = 'U';                         //使用中
  sFlag_CardLoss      = 'L';                         //挂失卡
  sFlag_CardInvalid   = 'N';                         //注销卡

  sFlag_TruckNone     = 'N';                         //无状态车辆
  sFlag_TruckIn       = 'I';                         //进厂车辆
  sFlag_TruckOut      = 'O';                         //出厂车辆
  sFlag_TruckBFP      = 'P';                         //磅房皮重车辆
  sFlag_TruckBFM      = 'M';                         //磅房毛重车辆
  sFlag_TruckSH       = 'S';                         //送货车辆
  sFlag_TruckFH       = 'F';                         //放灰车辆
  sFlag_TruckZT       = 'Z';                         //栈台车辆
  sFlag_TruckXH       = 'X';                         //验收车辆

  sFlag_TJNone        = 'N';                         //未调价
  sFlag_TJing         = 'T';                         //调价中
  sFlag_TJOver        = 'O';                         //调价完成
  
  sFlag_PoundBZ       = 'B';                         //标准
  sFlag_PoundPZ       = 'Z';                         //皮重
  sFlag_PoundPD       = 'P';                         //配对
  sFlag_PoundCC       = 'C';                         //出厂(过磅模式)
  sFlag_PoundLS       = 'L';                         //临时

  sFlag_ProvideC      = 'C';                         //承运商
  sFlag_ProvideD      = 'D';                         //倒入倒出地
  sFlag_ProvideL      = 'L';                         //产品线
  sFlag_ProvideG      = 'G';                         //供应商

  sFlag_BatchInUse    = 'Y';                         //批次号有效
  sFlag_BatchOutUse   = 'N';                         //批次号已封存
  sFlag_BatchDel      = 'D';                         //批次号已删除

  sFlag_SysParam      = 'SysParam';                  //系统参数
  sFlag_EnableBakdb   = 'Uses_BackDB';               //备用库
  sFlag_ValidDate     = 'SysValidDate';              //有效期
  sFlag_PrintBill     = 'PrintStockBill';            //需打印订单
  sFlag_ViaBillCard   = 'ViaBillCard';               //直接制卡
  
  sFlag_PDaiWuChaZ    = 'PoundDaiWuChaZ';            //袋装正误差
  sFlag_PDaiWuChaF    = 'PoundDaiWuChaF';            //袋装负误差
  sFlag_PDaiPercent   = 'PoundDaiPercent';           //按比例计算误差
  sFlag_PDaiWuChaStop = 'PoundDaiWuChaStop';         //误差时停止业务
  sFlag_PSanWuChaF    = 'PoundSanWuChaF';            //散装负误差
  sFlag_PSanWuChaP    = 'PoundSanWuChaP';            //散装皮重误差
  sFlag_PProWuChaM    = 'PoundProWuChaM';            //供应毛重误差
  sFlag_PoundWuCha    = 'PoundWuCha';                //过磅误差分组
  sFlag_PoundIfDai    = 'PoundIFDai';                //袋装是否过磅
  sFlag_NFStock       = 'NoFaHuoStock';              //现场无需发货
  sFlag_StockIfYS     = 'StockIfYS';                 //现场是否验收
  sFlag_DispatchPound = 'PoundDispatch';             //磅站调度
  sFlag_PSanVerifyStock='PSanVerifyStock';           //散装校验
  sFlag_OutOfRefund   = 'OutOfRefund';               //退货时限
  sFlag_ViaBillBatch  = 'ViaBillBatch';              //开单时获取批次
  sFlag_BatchAuto     = 'Batch_Auto';                //自动生成批次号
  sFlag_BatchBrand    = 'Batch_Brand';               //批次区分品牌
  sFlag_BatchValid    = 'Batch_Valid';               //启用批次管理

  sFlag_CommonItem    = 'CommonItem';                //公共信息
  sFlag_CardItem      = 'CardItem';                  //磁卡信息项
  sFlag_AreaItem      = 'AreaItem';                  //区域信息项
  sFlag_TruckItem     = 'TruckItem';                 //车辆信息项
  sFlag_CustomerItem  = 'CustomerItem';              //客户信息项
  sFlag_BankItem      = 'BankItem';                  //银行信息项
  sFlag_UserLogItem   = 'UserLogItem';               //用户登录项
  sFlag_PurchLineItem = 'PurchLineItem';             //收料信息项

  sFlag_StockItem     = 'StockItem';                 //水泥信息项
  sFlag_PackerItem    = 'PackerItem';                //包机信息项
  sFlag_BillItem      = 'BillItem';                  //提单信息项
  sFlag_TruckQueue    = 'TruckQueue';                //车辆队列
                                                               
  sFlag_PaymentItem   = 'PaymentItem';               //付款方式信息项
  sFlag_PaymentItem2  = 'PaymentItem2';              //销售回款信息项
  sFlag_LadingItem    = 'LadingItem';                //提货方式信息项

  sFlag_ProviderItem  = 'ProviderItem';              //供应商信息项
  sFlag_MaterailsItem = 'MaterailsItem';             //原材料信息项
  sFlag_ProviderType  = 'ProviderType';              //供应商类型

  sFlag_HardSrvURL    = 'HardMonURL';
  sFlag_MITSrvURL     = 'MITServiceURL';             //服务地址
  sFlag_CompanyID     = 'SystemCompanyID';           //工厂标识

  sFlag_AutoIn        = 'Truck_AutoIn';              //自动进厂
  sFlag_AutoOut       = 'Truck_AutoOut';             //自动出厂
  sFlag_InTimeout     = 'InFactTimeOut';             //进厂超时(队列)
  sFlag_InAndBill     = 'InFactAndBill';             //进停车厂开单间隔
  sFlag_SanMultiBill  = 'SanMultiBill';              //散装预开多单
  sFlag_NoDaiQueue    = 'NoDaiQueue';                //袋装禁用队列
  sFlag_NoSanQueue    = 'NoSanQueue';                //散装禁用队列
  sFlag_DelayQueue    = 'DelayQueue';                //延迟排队(厂内)
  sFlag_PoundQueue    = 'PoundQueue';                //延迟排队(厂内依据过皮时间)
  sFlag_NetPlayVoice  = 'NetPlayVoice';              //使用网络语音播发

  sFlag_BusGroup      = 'BusFunction';               //业务编码组
  sFlag_BillNo        = 'Bus_Bill';                  //交货单号
  sFlag_WaiXieNo      = 'Bus_WaiXie';                //外协编号
  sFlag_PoundID       = 'Bus_Pound';                 //称重记录
  sFlag_Customer      = 'Bus_Customer';              //客户编号
  sFlag_SaleMan       = 'Bus_SaleMan';               //业务员编号
  sFlag_ZhiKa         = 'Bus_ZhiKa';                 //纸卡编号
  sFlag_WeiXin        = 'Bus_WeiXin';                //微信映射编号
  sFlag_HYDan         = 'Bus_HYDan';                 //化验单号
  sFlag_ForceHint     = 'Bus_HintMsg';               //强制提示
  sFlag_PurchInfo     = 'Bus_PurchID';               //采购单号
  sFlag_Transfer      = 'Bus_Transfer';              //短倒单号
  sFlag_PoundErr      = 'Bus_PoundErr';              //称重记录
  sFlag_RefundNo      = 'Bus_RefundNo';              //退货单号

  sFlag_SerialAX      = 'AXFunction';                //AX编码组
  sFlag_AXMsgNo       = 'AX_MsgNo';                  //AX消息号

  {*数据表*}
  sTable_Group        = 'Sys_Group';                 //用户组
  sTable_User         = 'Sys_User';                  //用户表
  sTable_Menu         = 'Sys_Menu';                  //菜单表
  sTable_Popedom      = 'Sys_Popedom';               //权限表
  sTable_PopItem      = 'Sys_PopItem';               //权限项
  sTable_Entity       = 'Sys_Entity';                //字典实体
  sTable_DictItem     = 'Sys_DataDict';              //字典明细

  sTable_SysDict      = 'Sys_Dict';                  //系统字典
  sTable_ExtInfo      = 'Sys_ExtInfo';               //附加信息
  sTable_SysLog       = 'Sys_EventLog';              //系统日志
  sTable_SysErrLog    = 'Sys_EventErrLog';           //错误日志
  sTable_BaseInfo     = 'Sys_BaseInfo';              //基础信息
  sTable_SerialBase   = 'Sys_SerialBase';            //编码种子
  sTable_SerialStatus = 'Sys_SerialStatus';          //编号状态
  sTable_WorkePC      = 'Sys_WorkePC';               //验证授权

  sTable_Card         = 'S_Card';                    //销售磁卡
  sTable_Bill         = 'S_Bill';                    //提货单
  sTable_BillBak      = 'S_BillBak';                 //已删交货单
  sTable_Refund       = 'S_Refund';                  //退货单
  sTable_RefundBak    = 'S_RefundBak';               //已删除退货单

  sTable_StockMatch   = 'S_StockMatch';              //品种映射
  sTable_StockParam   = 'S_StockParam';              //品种参数
  sTable_StockParamExt= 'S_StockParamExt';           //参数扩展

  sTable_Truck        = 'S_Truck';                   //车辆表
  sTable_ZTLines      = 'S_ZTLines';                 //装车道
  sTable_ZTTrucks     = 'S_ZTTrucks';                //车辆队列
  sTable_Batcode      = 'S_Batcode';                 //批次编号(自动生成)
  sTable_BatcodeDoc   = 'S_BatcodeDoc';              //批次编号(手工录入)
  sTable_BatcodeDocBak= 'S_BatcodeDocBak';           //批次编号(手工录入,已删除)

  sTable_Provider     = 'P_Provider';                //客户表
  sTable_Materails    = 'P_Materails';               //物料表
  sTable_PurchInfo    = 'P_PurchInfo';
  sTable_PurchInfoBak = 'P_PurchInfoBak';            //采购单
  sTable_WaiXieInfo   = 'P_WaiXieInfo';
  sTable_WaiXieBak    = 'P_WaiXieBak';               //外协单
  sTable_PurchCorrect = 'P_PurchCorrect';            //采购勘误单

  sTable_Transfer     = 'P_Transfer';                //短倒明细单
  sTable_TransferBak  = 'P_TransferBak';             //短倒明细单

  sTable_WeixinLog    = 'Sys_WeixinLog';             //微信日志
  sTable_WeixinMatch  = 'Sys_WeixinMatch';           //账号匹配
  sTable_WeixinTemp   = 'Sys_WeixinTemplate';        //信息模板

  sTable_PoundLog     = 'Sys_PoundLog';              //过磅数据
  sTable_PoundBak     = 'Sys_PoundBak';              //过磅作废
  sTable_PoundErr     = 'Sys_PoundErr';              //过磅作废
  sTable_Picture      = 'Sys_Picture';               //存放图片

  sTable_AX_CardInfo  = 'S_AXCardInfo';              //销售卡片
  sTable_AX_MoneyInfo = 'S_AXMoneyInfo';             //销售资金
  sTable_AX_OrderInfo = 'P_AXOrderInfo';             //供应订单 

const

  {*新建表*}
  sSQL_NewSysDict = 'Create Table $Table(D_ID $Inc, D_Name varChar(15),' +
       'D_Desc varChar(30), D_Value varChar(50), D_Memo varChar(20),' +
       'D_ParamA $Float, D_ParamB varChar(50), D_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   系统字典: SysDict
   *.D_ID: 编号
   *.D_Name: 名称
   *.D_Desc: 描述
   *.D_Value: 取值
   *.D_Memo: 相关信息
   *.D_ParamA: 浮点参数
   *.D_ParamB: 字符参数
   *.D_Index: 显示索引
  -----------------------------------------------------------------------------}
  
  sSQL_NewExtInfo = 'Create Table $Table(I_ID $Inc, I_Group varChar(20),' +
       'I_ItemID varChar(20), I_Item varChar(30), I_Info varChar(500),' +
       'I_ParamA $Float, I_ParamB varChar(50), I_Index Integer Default 0)';
  {-----------------------------------------------------------------------------
   扩展信息表: ExtInfo
   *.I_ID: 编号
   *.I_Group: 信息分组
   *.I_ItemID: 信息标识
   *.I_Item: 信息项
   *.I_Info: 信息内容
   *.I_ParamA: 浮点参数
   *.I_ParamB: 字符参数
   *.I_Memo: 备注信息
   *.I_Index: 显示索引
  -----------------------------------------------------------------------------}
  
  sSQL_NewSysLog = 'Create Table $Table(L_ID $Inc, L_Date DateTime,' +
       'L_Man varChar(32),L_Group varChar(20), L_ItemID varChar(20),' +
       'L_KeyID varChar(20), L_Event varChar(220))';
  {-----------------------------------------------------------------------------
   系统日志: SysLog
   *.L_ID: 编号
   *.L_Date: 操作日期
   *.L_Man: 操作人
   *.L_Group: 信息分组
   *.L_ItemID: 信息标识
   *.L_KeyID: 辅助标识
   *.L_Event: 事件
  -----------------------------------------------------------------------------}

  sSQL_NewBaseInfo = 'Create Table $Table(B_ID $Inc, B_Group varChar(15),' +
       'B_Text varChar(100), B_Py varChar(25), B_Memo varChar(50),' +
       'B_PID Integer, B_Index Float)';
  {-----------------------------------------------------------------------------
   基本信息表: BaseInfo
   *.B_ID: 编号
   *.B_Group: 分组
   *.B_Text: 内容
   *.B_Py: 拼音简写
   *.B_Memo: 备注信息
   *.B_PID: 上级节点
   *.B_Index: 创建顺序
  -----------------------------------------------------------------------------}

  sSQL_NewSerialBase = 'Create Table $Table(R_ID $Inc, B_Group varChar(15),' +
       'B_Object varChar(32), B_Prefix varChar(25), B_IDLen Integer,' +
       'B_Base Integer, B_Date DateTime)';
  {-----------------------------------------------------------------------------
   串行编号基数表: SerialBase
   *.R_ID: 编号
   *.B_Group: 分组
   *.B_Object: 对象
   *.B_Prefix: 前缀
   *.B_IDLen: 编号长
   *.B_Base: 基数
   *.B_Date: 参考日期
  -----------------------------------------------------------------------------}

  sSQL_NewSerialStatus = 'Create Table $Table(R_ID $Inc, S_Object varChar(32),' +
       'S_SerailID varChar(32), S_PairID varChar(32), S_Status Char(1),' +
       'S_Date DateTime)';
  {-----------------------------------------------------------------------------
   串行状态表: SerialStatus
   *.R_ID: 编号
   *.S_Object: 对象
   *.S_SerailID: 串行编号
   *.S_PairID: 配对编号
   *.S_Status: 状态(Y,N)
   *.S_Date: 创建时间
  -----------------------------------------------------------------------------}

  sSQL_NewWorkePC = 'Create Table $Table(R_ID $Inc, W_Name varChar(100),' +
       'W_MAC varChar(32), W_Factory varChar(32), W_Serial varChar(32),' +
       'W_Departmen varChar(32), W_ReqMan varChar(32), W_ReqTime DateTime,' +
       'W_RatifyMan varChar(32), W_RatifyTime DateTime, W_Valid Char(1))';
  {-----------------------------------------------------------------------------
   工作授权: WorkPC
   *.R_ID: 编号
   *.W_Name: 电脑名称
   *.W_MAC: MAC地址
   *.W_Factory: 工厂编号
   *.W_Departmen: 部门
   *.W_Serial: 编号
   *.W_ReqMan,W_ReqTime: 接入申请
   *.W_RatifyMan,W_RatifyTime: 批准
   *.W_Valid: 有效(Y/N)
  -----------------------------------------------------------------------------}

  sSQL_NewSyncItem = 'Create Table $Table(R_ID $Inc, S_Table varChar(100),' +
       'S_Action Char(1), S_Record varChar(32), S_Param1 varChar(100),' +
       'S_Param2 $Float, S_Time DateTime)';
  {-----------------------------------------------------------------------------
   同步数据项: SyncItem
   *.R_ID: 编号
   *.S_Table: 表名称
   *.S_Action: 增删改(A,E,D)
   *.S_Record: 记录编号
   *.S_Param1,S_Param2: 参数
   *.S_Time: 时间
  -----------------------------------------------------------------------------}

  sSQL_NewStockMatch = 'Create Table $Table(R_ID $Inc, M_Group varChar(8),' +
       'M_ID varChar(20), M_Name varChar(80), M_Status Char(1))';
  {-----------------------------------------------------------------------------
   相似品种映射: StockMatch
   *.R_ID: 记录编号
   *.M_Group: 分组
   *.M_ID: 物料号
   *.M_Name: 物料名称
   *.M_Status: 状态
  -----------------------------------------------------------------------------}

  sSQL_NewSysErrLog = 'Create Table $Table(R_ID $Inc, E_Date DateTime,' +
       'E_Man varChar(32),E_Group varChar(20), E_ItemID varChar(20),' +
       'E_KeyID varChar(20), E_Result Char(1), E_Event varChar(220))';
  {-----------------------------------------------------------------------------
   系统错误日志: SysErrLog
   *.R_ID: 编号
   *.E_Date: 操作日期
   *.E_Man: 操作人
   *.E_Group: 信息分组
   *.E_ItemID: 信息标识
   *.E_KeyID: 辅助标识
   *.E_Event: 事件
   *.E_Result: 业务执行结果(Y、作为预警;N、执行失败)
  -----------------------------------------------------------------------------}

  sSQL_NewBill = 'Create Table $Table(R_ID $Inc, L_ID varChar(20),' +
       'L_Card varChar(16),L_ZhiKa varChar(15),L_Project varChar(100),' +
       'L_CusID varChar(15),L_CusName varChar(80),L_CusPY varChar(80),' +
       'L_SaleID varChar(15),L_SaleMan varChar(32),' +
       'L_Type Char(1),L_StockNo varChar(20),L_StockName varChar(80),' +
       'L_Value $Float,L_Price $Float,' +
       'L_Truck varChar(15),L_Status Char(1),L_NextStatus Char(1),' +
       'L_InTime DateTime,L_InMan varChar(32),' +
       'L_PValue $Float,L_PDate DateTime,L_PMan varChar(32),' +
       'L_MValue $Float,L_MDate DateTime,L_MMan varChar(32),' +
       'L_LadeTime DateTime,L_LadeMan varChar(32), ' +
       'L_LadeLine varChar(15),L_LineName varChar(32),' +
       'L_PackerNo varChar(32),L_PeiBi varChar(16),' +
       'L_DaiTotal Integer,L_DaiNormal Integer,L_DaiBuCha Integer,' +
       'L_OutFact DateTime,L_OutMan varChar(32),' +
       'L_Lading Char(1),L_IsVIP varChar(1),L_Seal varChar(100),' +
       'L_HYDan varChar(16),L_District varChar(16),L_PrintCode varChar(32),' +
       'L_Man varChar(32),L_Date DateTime,' +
       'L_DelMan varChar(32),L_DelDate DateTime,' +
       'L_AXStatus Char(1), L_AXMemo varChar(500),' +
       'L_SyncNum Integer Default 0,L_SyncDate DateTime,L_SyncMemo varChar(500))';
  {-----------------------------------------------------------------------------
   交货单表: Bill
   *.R_ID: 编号
   *.L_ID: 提单号
   *.L_Card: 磁卡号
   *.L_ZhiKa: 纸卡号
   *.L_CusID,L_CusName,L_CusPY:客户
   *.L_SaleID,L_SaleMan:业务员
   *.L_Type: 类型(袋,散)
   *.L_StockNo: 物料编号
   *.L_StockName: 物料描述 
   *.L_Value: 提货量
   *.L_Price: 提货单价
   *.L_Truck: 车船号
   *.L_Status,L_NextStatus:状态控制
   *.L_InTime,L_InMan: 进厂放行
   *.L_PValue,L_PDate,L_PMan: 称皮重
   *.L_MValue,L_MDate,L_MMan: 称毛重
   *.L_LadeTime,L_LadeMan: 发货时间,发货人
   *.L_LadeLine,L_LineName: 发货通道
   *.L_PackerNo: 包装机号
   *.L_PeiBi: 配比编号
   *.L_DaiTotal,L_DaiNormal,L_DaiBuCha:总装,正常,补差
   *.L_OutFact,L_OutMan: 出厂放行
   *.L_Lading: 提货方式(自提,送货)
   *.L_IsVIP:VIP单
   *.L_Seal: 封签号
   *.L_HYDan: 化验单
   *.L_District: 区域码
   *.L_PrintCode: 喷码号
   *.L_Man:操作人
   *.L_Date:创建时间
   *.L_DelMan: 交货单删除人员
   *.L_DelDate: 交货单删除时间
   *.L_AXStatus: AX系统中状态
   *.L_AXMemo: AX系统备注
   *.L_SyncNum: 提交次数
   *.L_SyncDate: 提交成功时间
   *.L_SyncMemo: 提交错误描述
  -----------------------------------------------------------------------------}

    sSQL_NewRefund = 'Create Table $Table(R_ID $Inc, F_ID varChar(20),' +
       'F_Card varChar(16),F_LID varChar(20),F_LOutFact DateTime,' +
       'F_CusID varChar(15),F_CusName varChar(80),F_CusPY varChar(80),' +
       'F_SaleID varChar(15),F_SaleMan varChar(32),' +
       'F_Type Char(1),F_StockNo varChar(20),F_StockName varChar(80),' +
       'F_LimValue $Float,F_Value $Float,F_Price $Float,' +
       'F_Truck varChar(15),F_Status Char(1),F_NextStatus Char(1),' +
       'F_InTime DateTime,F_InMan varChar(32),' +
       'F_PValue $Float,F_PDate DateTime,F_PMan varChar(32),' +
       'F_MValue $Float,F_MDate DateTime,F_MMan varChar(32),' +
       'F_LadeTime DateTime,F_LadeMan varChar(32), ' +
       'F_LadeLine varChar(15),F_LineName varChar(32),' +
       'F_OutFact DateTime,F_OutMan varChar(32),' +
       'F_Man varChar(32),F_Date DateTime,' +
       'F_DelMan varChar(32),F_DelDate DateTime, ' +
       'F_SyncNum Integer Default 0,F_SyncDate DateTime,F_SyncMemo varChar(500))';
  {-----------------------------------------------------------------------------
   退货单表: Refund
   *.R_ID: 编号
   *.F_ID: 退货单号
   *.F_Card: 磁卡号
   *.F_LID: 退货单对应提货单号
   *.F_LOutFact: 提货出厂时间
   *.F_CusID,F_CusName,F_CusPY:客户
   *.F_SaleID,F_SaleMan:业务员
   *.F_Type: 类型(袋,散)
   *.F_StockNo: 物料编号
   *.F_StockName: 物料描述
   *.F_LimValue: 提货单原始提货量
   *.F_Value: 退货量
   *.F_Price: 退货单价
   *.F_Truck: 车船号
   *.F_Status,F_NextStatus:状态控制
   *.F_InTime,F_InMan: 进厂放行
   *.F_PValue,F_PDate,F_PMan: 称皮重
   *.F_MValue,F_MDate,F_MMan: 称毛重
   *.F_LadeTime,F_LadeMan: 卸货时间,卸货人
   *.F_LadeLine,F_LineName: 卸货通道
   *.F_OutFact,F_OutMan: 出厂放行
   *.F_Man:操作人
   *.F_Date:创建时间
   *.F_DelMan: 退货单删除人员
   *.F_DelDate: 退货单删除时间
   *.F_SyncNum: 提交次数
   *.F_SyncDate: 提交成功时间
   *.F_SyncMemo: 提交错误描述
  -----------------------------------------------------------------------------}

  sSQL_NewCard = 'Create Table $Table(R_ID $Inc, C_Card varChar(16),' +
       'C_Card2 varChar(32), C_Card3 varChar(32),' +
       'C_Owner varChar(15), C_TruckNo varChar(15), C_Status Char(1),' +
       'C_Freeze Char(1), C_Used Char(1), C_UseTime Integer Default 0,' +
       'C_Man varChar(32), C_Date DateTime, C_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   磁卡表:Card
   *.R_ID:记录编号
   *.C_Card:主卡号
   *.C_Card2,C_Card3:副卡号
   *.C_Owner:持有人标识
   *.C_TruckNo:提货车牌
   *.C_Used:用途(供应,销售,临时)
   *.C_UseTime:使用次数
   *.C_Status:状态(空闲,使用,注销,挂失)
   *.C_Freeze:是否冻结
   *.C_Man:办理人
   *.C_Date:办理时间
   *.C_Memo:备注信息
  -----------------------------------------------------------------------------}

  sSQL_NewTruck = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15), ' +
       'T_PY varChar(15), T_Owner varChar(32), T_Phone varChar(15), T_Used Char(1), ' +
       'T_PrePValue $Float, T_PrePMan varChar(32), T_PrePTime DateTime, ' +
       'T_PrePUse Char(1), T_MinPVal $Float, T_MaxPVal $Float, ' +
       'T_PValue $Float Default 0, T_PTime Integer Default 0,' +
       'T_PlateColor varChar(12),T_Type varChar(12), T_LastTime DateTime, ' +
       'T_Card varChar(32), T_CardUse Char(1), T_NoVerify Char(1),' +
       'T_Valid Char(1), T_VIPTruck Char(1), T_HasGPS Char(1),' +
       'T_MatePID varChar(15), T_MateID varChar(15), T_MateName varChar(80),' +
       'T_SrcAddr varChar(150), T_DestAddr varChar(150)' +
       ')';
  {-----------------------------------------------------------------------------
   车辆信息:Truck
   *.R_ID: 记录号
   *.T_Truck: 车牌号
   *.T_PY: 车牌拼音
   *.T_Owner: 车主
   *.T_Phone: 联系方式
   *.T_Used: 用途(供应,销售)
   *.T_PrePValue: 预置皮重
   *.T_PrePMan: 预置司磅
   *.T_PrePTime: 预置时间
   *.T_PrePUse: 使用预置
   *.T_MinPVal: 历史最小皮重
   *.T_MaxPVal: 历史最大皮重
   *.T_PValue: 有效皮重
   *.T_PTime: 过皮次数
   *.T_PlateColor: 车牌颜色
   *.T_Type: 车型
   *.T_LastTime: 上次活动
   *.T_Card: 电子标签
   *.T_CardUse: 使用电子签(Y/N)
   *.T_NoVerify: 不校验时间
   *.T_Valid: 是否有效
   *.T_VIPTruck:是否VIP
   *.T_HasGPS:安装GPS(Y/N)

   //---------------------------短倒业务数据信息--------------------------------
   *.T_MatePID:上个物料编号
   *.T_MateID:物料编号
   *.T_MateName: 物料名称
   *.T_SrcAddr:倒出地址
   *.T_DestAddr:倒入地址
   ---------------------------------------------------------------------------//

   有效平均皮重算法:
   T_PValue = (T_PValue * T_PTime + 新皮重) / (T_PTime + 1)
  -----------------------------------------------------------------------------}

  sSQL_NewPoundLog = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Type varChar(1), P_Order varChar(20), P_Card varChar(16),' +
       'P_Bill varChar(20), P_Truck varChar(15), P_CusID varChar(32),' +
       'P_CusName varChar(80), P_MID varChar(32),P_MName varChar(80),' +
       'P_MType varChar(10), P_LimValue $Float,' +
       'P_PValue $Float, P_PDate DateTime, P_PMan varChar(32), ' +
       'P_MValue $Float, P_MDate DateTime, P_MMan varChar(32), ' +
       'P_FactID varChar(32), P_PStation varChar(10), P_MStation varChar(10),' +
       'P_Direction varChar(10), P_PModel varChar(10), P_Status Char(1),' +
       'P_Valid Char(1), P_PrintNum Integer Default 1,' +
       'P_DelMan varChar(32), P_DelDate DateTime, P_KZValue $Float)';
  {-----------------------------------------------------------------------------
   过磅记录: PoundLog
   *.P_ID: 编号
   *.P_Type: 类型(销售,供应,临时)
   *.P_Order: 订单号(供应)
   *.P_Bill: 交货单
   *.P_Truck: 车牌
   *.P_CusID: 客户号
   *.P_CusName: 物料名
   *.P_MID: 物料号
   *.P_MName: 物料名
   *.P_MType: 包,散等
   *.P_LimValue: 票重
   *.P_PValue,P_PDate,P_PMan: 皮重
   *.P_MValue,P_MDate,P_MMan: 毛重
   *.P_FactID: 工厂编号
   *.P_PStation,P_MStation: 称重磅站
   *.P_Direction: 物料流向(进,出)
   *.P_PModel: 过磅模式(标准,配对等)
   *.P_Status: 记录状态
   *.P_Valid: 是否有效
   *.P_PrintNum: 打印次数
   *.P_DelMan,P_DelDate: 删除记录
   *.P_KZValue: 供应扣杂
  -----------------------------------------------------------------------------}

  sSQL_NewPoundError = 'Create Table $Table(R_ID $Inc, E_ID varChar(15),' +
       'E_Type varChar(1), E_Card varChar(16),' +
       'E_Truck varChar(15), E_CusID varChar(32), E_CusName varChar(100),' +
       'E_MID varChar(32),E_MName varChar(80), E_MType varChar(10),' +
       'E_SrcID varChar(20), E_LimValue $Float, E_SrcNextStatus Char(1),' +
       'E_PValue $Float, E_PDate DateTime, E_PMan varChar(32), ' +
       'E_MValue $Float, E_MDate DateTime, E_MMan varChar(32), ' +
       'E_FactID varChar(32), E_PStation varChar(10), E_MStation varChar(10),' +
       'E_PModel varChar(10), E_Valid Char(1),' +
       'E_Man varChar(32), E_Date DateTime,' +
       'E_DealMan varChar(32), E_DealDate DateTime, E_DealMemo varChar(500),' +
       'E_Memo varChar(500))';
  {-----------------------------------------------------------------------------
   错误磅单: PoundError
   *.P_ID: 编号
   *.E_Type: 类型(销售,供应,临时)
   *.E_Card: 卡号
   *.E_Truck: 车牌号
   *.E_CusID: 客户号
   *.E_CusName: 物料名
   *.E_MID: 物料号
   *.E_MName: 物料名
   *.E_MType: 包,散等
   *.E_SrcID: 订单号(供应);提货单(销售)
   *.E_LimValue: 票重
   *.E_SrcNextStatus: 订单下一状态
   *.E_PValue,E_PDate,E_PMan: 皮重
   *.E_MValue,E_MDate,E_MMan: 毛重
   *.E_FactID: 工厂编号
   *.E_PStation,E_MStation: 称重磅站
   *.E_Valid: (N、未处理;Y、已处理)
   *.E_Man,E_Date:
   *.E_DealMan,E_DealDate,E_DealMemo: 处理人
   *.E_Memo: 错误信息
  -----------------------------------------------------------------------------}

  sSQL_NewPicture = 'Create Table $Table(R_ID $Inc, P_ID varChar(15),' +
       'P_Name varChar(32), P_Mate varChar(80), P_Date DateTime, P_Picture Image)';
  {-----------------------------------------------------------------------------
   图片: Picture
   *.P_ID: 编号
   *.P_Name: 名称
   *.P_Mate: 物料
   *.P_Date: 时间
   *.P_Picture: 图片
  -----------------------------------------------------------------------------}

  sSQL_NewZTLines = 'Create Table $Table(R_ID $Inc, Z_ID varChar(15),' +
       'Z_Name varChar(32), Z_StockNo varChar(20), Z_Stock varChar(80),' +
       'Z_StockType Char(1), Z_PeerWeight Integer, Z_PackerNo varChar(32),' +
       'Z_QueueMax Integer, Z_VIPLine Char(1), Z_Valid Char(1), Z_Index Integer)';
  {-----------------------------------------------------------------------------
   装车线配置: ZTLines
   *.R_ID: 记录号
   *.Z_ID: 编号
   *.Z_Name: 名称
   *.Z_StockNo: 品种编号
   *.Z_Stock: 品名
   *.Z_StockType: 类型(袋,散)
   *.Z_PeerWeight: 袋重
   *.Z_PackerNo: 包机编号
   *.Z_QueueMax: 队列大小
   *.Z_VIPLine: VIP通道
   *.Z_Valid: 是否有效
   *.Z_Index: 顺序索引
  -----------------------------------------------------------------------------}

  sSQL_NewZTTrucks = 'Create Table $Table(R_ID $Inc, T_Truck varChar(15),' +
       'T_StockNo varChar(20), T_Stock varChar(80), T_Type Char(1),' +
       'T_Line varChar(15), T_Index Integer, ' +
       'T_InTime DateTime, T_InFact DateTime, T_InQueue DateTime,' +
       'T_InLade DateTime, T_VIP Char(1), T_Valid Char(1), T_Bill varChar(15),' +
       'T_Value $Float, T_PeerWeight Integer, T_Total Integer Default 0,' +
       'T_Normal Integer Default 0, T_BuCha Integer Default 0,' +
       'T_PDate DateTime, T_IsPound Char(1),T_HKBills varChar(200))';
  {-----------------------------------------------------------------------------
   待装车队列: ZTTrucks
   *.R_ID: 记录号
   *.T_Truck: 车牌号
   *.T_StockNo: 品种编号
   *.T_Stock: 品种名称
   *.T_Type: 品种类型(D,S)
   *.T_Line: 所在道
   *.T_Index: 顺序索引
   *.T_InTime: 入队时间
   *.T_InFact: 进厂时间
   *.T_InQueue: 上屏时间
   *.T_InLade: 提货时间
   *.T_VIP: 特权
   *.T_Bill: 提单号
   *.T_Valid: 是否有效
   *.T_Value: 提货量
   *.T_PeerWeight: 袋重
   *.T_Total: 总装袋数
   *.T_Normal: 正常袋数
   *.T_BuCha: 补差袋数
   *.T_PDate: 过磅时间
   *.T_IsPound: 需过磅(Y/N)
   *.T_HKBills: 合卡交货单列表
  -----------------------------------------------------------------------------}

  sSQL_NewWXLog = 'Create Table $Table(R_ID $Inc, L_UserID varChar(50), ' +
       'L_Data varChar(2000), L_MsgID varChar(20), L_Result varChar(150),' +
       'L_Count Integer Default 0, L_Status Char(1), ' +
       'L_Comment varChar(100), L_Date DateTime)';
  {-----------------------------------------------------------------------------
   微信发送日志:WeixinLog
   *.R_ID:记录编号
   *.L_UserID: 接收者ID
   *.L_Data:微信数据
   *.L_Count:发送次数
   *.L_MsgID: 微信返回标识
   *.L_Result:发送返回信息
   *.L_Status:发送状态(N待发送,I发送中,Y已发送)
   *.L_Comment:备注
   *.L_Date: 发送时间
  -----------------------------------------------------------------------------}

  sSQL_NewWXMatch = 'Create Table $Table(R_ID $Inc, M_ID varChar(15), ' +
       'M_WXID varChar(50), M_WXName varChar(64), M_WXFactory varChar(15), ' +
       'M_IsValid Char(1), M_Comment varChar(100), ' +
       'M_AttentionID varChar(32), M_AttentionType Char(1))';
  {-----------------------------------------------------------------------------
   微信账户:WeixinMatch
   *.R_ID:记录编号
   *.M_ID: 微信编号
   *.M_WXID:开发ID
   *.M_WXName:微信名
   *.M_WXFactory:微信注册工厂编码
   *.M_IsValid: 是否有效
   *.M_Comment: 备注             
   *.M_AttentionID,M_AttentionType: 微信关注客户ID,类型(S、业务员;C、客户;G、管理员)
  -----------------------------------------------------------------------------}

  sSQL_NewWXTemplate = 'Create Table $Table(R_ID $Inc, W_Type varChar(15), ' +
       'W_TID varChar(50), W_TFields varChar(64), ' +
       'W_TComment Char(300), W_IsValid Char(1))';
  {-----------------------------------------------------------------------------
   微信账户:WeixinMatch
   *.R_ID:记录编号
   *.W_Type:类型
   *.W_TID:标识
   *.W_TFields:数据域段
   *.W_IsValid: 是否有效
   *.W_TComment: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewProvider = 'Create Table $Table(R_ID $Inc, P_ID varChar(32),' +
       'P_Name varChar(80),P_PY varChar(80), P_Phone varChar(20),' +
       'P_Type Char(1), P_Saler varChar(32),P_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   供应商: Provider
   *.P_ID: 编号
   *.P_Name: 名称
   *.P_PY: 拼音简写
   *.P_Phone: 联系方式
   *.P_Saler: 业务员
   *.P_Type: 供应商类型(C、承运商;D、倒入倒出地;G、供应商;L、产品线)
   *.P_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewMaterails = 'Create Table $Table(R_ID $Inc, M_ID varChar(32),' +
       'M_Name varChar(80),M_PY varChar(80),M_Unit varChar(20),M_Price $Float,' +
       'M_PrePValue Char(1), M_PrePTime Integer, M_Memo varChar(50))';
  {-----------------------------------------------------------------------------
   物料表: Materails
   *.M_ID: 编号
   *.M_Name: 名称
   *.M_PY: 拼音简写
   *.M_Unit: 单位
   *.M_PrePValue: 预置皮重
   *.M_PrePTime: 皮重时长(天)
   *.M_Memo: 备注
  -----------------------------------------------------------------------------}

  sSQL_NewPurchInfo = 'Create Table $Table(R_ID $Inc, P_ID varChar(20),' +
       'P_Card varChar(16), P_Truck varChar(15),' +
       'P_ProID varChar(15), P_ProName varChar(160), P_ProPY varChar(160),' +
       'P_TransID varChar(15), P_TransName varChar(160), P_TransPY varChar(160),' +
       'P_SaleID varChar(32), P_SaleMan varChar(80), P_SalePY varChar(80),' +
       'P_Type Char(1), P_StockNo varChar(32), P_StockName varChar(160),' +
       'P_Status Char(1), P_NextStatus Char(1),' +
       'P_InTime DateTime, P_InMan varChar(32),' +
       'P_PValue $Float, P_PDate DateTime, P_PMan varChar(32),' +
       'P_MValue $Float, P_MDate DateTime, P_MMan varChar(32),' +
       'P_SrcPValue $Float, P_SrcMValue $Float, P_SrcID varChar(32),' +
       'P_YTime DateTime, P_YMan varChar(32), ' +
       'P_OutFact DateTime, P_OutMan varChar(32), ' +
       'P_Value $Float,P_KZValue $Float, P_AKValue $Float,' +
       'P_YSResult Char(1), P_YLine varChar(15), P_YLineName varChar(32),' +
       'P_Man varChar(32), P_Date DateTime,' +
       'P_DelMan varChar(32), P_DelDate DateTime, P_Memo varChar(500),' +
       'P_SyncNum Integer Default 0, P_SyncDate DateTime, P_SyncMemo varChar(500))';
  {-----------------------------------------------------------------------------
   入厂表: PurchInfo
   *.R_ID: 编号
   *.P_ID: 入厂号
   *.P_Card: 磁卡号
   *.P_ProID,P_ProName,P_ProPY:客户
   *.P_SaleID,P_SaleMan, P_SalePY:业务员
   *.P_Type: 类型(袋,散)
   *.P_StockNo: 物料编号
   *.P_StockName: 物料描述
   *.P_Truck: 车牌号
   *.P_Status,P_NextStatus: 状态
   *.P_InTime,P_InMan: 进厂放行
   *.P_PValue,P_PDate,P_PMan: 称皮重
   *.P_MValue,P_MDate,P_MMan: 称毛重
   *.P_YTime,P_YMan: 收货时间,验收人,
   *.P_Value,P_KZValue,P_AKValue: 收货量,验收扣除(明扣),暗扣
   *.P_YLine,P_YLineName: 收货通道
   *.P_YSResult: 验收结果
   *.P_OutFact,P_OutMan: 出厂放行
   *.P_Man,P_Date: 删除信息
   *.P_DelMan,P_DelDate: 删除信息
   *.P_SyncNum: 提交次数
   *.P_SyncDate: 提交成功时间
   *.P_SyncMemo: 提交错误描述
  -----------------------------------------------------------------------------}

  sSQL_NewTransfer = 'Create Table $Table(R_ID $Inc, T_ID varChar(20),' +
       'T_Card varChar(16), T_Truck varChar(15), T_PID varChar(15),' +
       'T_SrcAddr varChar(160), T_DestAddr varChar(160),' +
       'T_Type Char(1), T_StockNo varChar(32), T_StockName varChar(160),' +
       'T_PValue $Float, T_PDate DateTime, T_PMan varChar(32),' +
       'T_MValue $Float, T_MDate DateTime, T_MMan varChar(32),' +
       'T_Value $Float, T_Man varChar(32), T_Date DateTime,' +
       'T_DelMan varChar(32), T_DelDate DateTime, T_Memo varChar(500),' +
       'T_SyncNum Integer Default 0, T_SyncDate DateTime, T_SyncMemo varChar(500))';
  {-----------------------------------------------------------------------------
   入厂表: Transfer
   *.R_ID: 编号
   *.T_ID: 短倒业务号
   *.T_PID: 磅单编号
   *.T_Card: 磁卡号
   *.T_Truck: 车牌号
   *.T_SrcAddr:倒出地点
   *.T_DestAddr:倒入地点
   *.T_Type: 类型(袋,散)
   *.T_StockNo: 物料编号
   *.T_StockName: 物料描述
   *.T_PValue,T_PDate,T_PMan: 称皮重
   *.T_MValue,T_MDate,T_MMan: 称毛重
   *.T_Value: 收货量
   *.T_Man,T_Date: 单据信息
   *.T_DelMan,T_DelDate: 删除信息
   *.T_SyncNum, T_SyncDate, T_SyncMemo: 同步次数; 同步完成时间; 同步信息
  -----------------------------------------------------------------------------}

  sSQL_NewWaiXieInfo = 'Create Table $Table(R_ID $Inc, W_ID varChar(20),' +
       'W_Card varChar(16), W_Truck varChar(15),' +
       'W_ProID varChar(15), W_ProName varChar(160), W_ProPY varChar(160),' +
       'W_TransID varChar(15), W_TransName varChar(160), W_TransPY varChar(160),' +
       'W_ProductLine varchar(160), W_OutXH Char(1),' +
       'W_Type Char(1), W_StockNo varChar(32), W_StockName varChar(160),' +
       'W_Status Char(1), W_NextStatus Char(1),' +
       'W_InTime1 DateTime, W_InMan1 varChar(32),' +
       'W_InTime2 DateTime, W_InMan2 varChar(32),' +
       'W_PValue $Float, W_PDate DateTime, W_PMan varChar(32),' +
       'W_MValue $Float, W_MDate DateTime, W_MMan varChar(32),' +
       'W_OutFact1 DateTime, W_OutMan1 varChar(32), ' +
       'W_OutFact2 DateTime, W_OutMan2 varChar(32), ' +
       'W_Man varChar(32), W_Date DateTime,' +
       'W_DelMan varChar(32), W_DelDate DateTime,' +
       'W_SyncNum Integer Default 0, W_SyncDate DateTime, W_SyncMemo varChar(500))';
  {-----------------------------------------------------------------------------
   外协表: WaiXieInfo
   *.R_ID: 编号
   *.W_ID: 入厂号
   *.W_Card: 磁卡号
   *.W_Truck: 车牌号
   *.W_ProID,W_ProName,W_ProPY:客户
   *.W_TransID,W_TransName, W_TransPY:运输单位
   *.W_ProductLine: 产品线
   *.W_OutXH: 厂外卸货模式
   *.W_Type: 类型(袋,散)
   *.W_StockNo: 物料编号
   *.W_StockName: 物料描述
   *.W_Status,W_NextStatus: 状态
   *.W_InTime1,W_InTime2: 进厂
   *.W_PValue,W_PDate,W_PMan: 称皮重
   *.W_MValue,W_MDate,W_MMan: 称毛重
   *.W_OutFact1,W_OutFact2: 出厂
   *.W_Man,W_Date: 开单人
   *.W_DelMan,W_DelDate: 删除信息
   *.W_SyncNum: 提交次数
   *.W_SyncDate: 提交成功时间
   *.W_SyncMemo: 提交错误描述
  -----------------------------------------------------------------------------}

  sSQL_NewBatcode = 'Create Table $Table(R_ID $Inc, B_Stock varChar(32),' +
       'B_Name varChar(80), B_Prefix varChar(5), B_Base Integer,' +
       'B_Incement Integer, B_Length Integer, ' +
       'B_Value $Float, B_Low $Float, B_High $Float, B_Week Integer,' +
       'B_AutoNew Char(1), B_UseDate Char(1), B_FirstDate DateTime,' +
       'B_LastDate DateTime, B_HasUse $Float Default 0, B_Batcode varChar(32))';
  {-----------------------------------------------------------------------------
   批次编码表: Batcode
   *.R_ID: 编号
   *.B_Stock: 物料号
   *.B_Name: 物料名
   *.B_Prefix: 前缀
   *.B_Base: 起始编码(基数)
   *.B_Incement: 编号增量
   *.B_Length: 编号长度
   *.B_Value:检测量
   *.B_Low,B_High:上下限(%)
   *.B_Week: 编号周期(天)
   *.B_AutoNew: 元旦重置(Y/N)
   *.B_UseDate: 使用日期编码
   *.B_FirstDate: 首次使用时间
   *.B_LastDate: 上次基数更新时间
   *.B_HasUse: 已使用
   *.B_Batcode: 当前批次号
  -----------------------------------------------------------------------------}

  sSQL_NewBatcodeDoc = 'Create Table $Table(R_ID $Inc, D_ID varChar(32),' +
       'D_Stock varChar(32),D_Name varChar(80), D_Brand varChar(32), ' +
       'D_Plan $Float Default 0, D_Sent $Float  Default 0, ' +
       'D_Rund $Float Default 0, D_Init $Float  Default 0, D_Warn $Float  Default 0, ' +
       'D_Man varChar(32), D_Date DateTime, D_DelMan varChar(32), D_DelDate DateTime, ' +
       'D_UseDate DateTime, D_LastDate DateTime, D_Valid char(1))';
  {-----------------------------------------------------------------------------
   批次编码表: Batcode
   *.R_ID: 编号
   *.D_ID: 批次号
   *.D_Stock: 物料号
   *.D_Name: 物料名
   *.D_Brand: 水泥品牌
   *.D_Plan: 计划总量
   *.D_Sent: 已发量
   *.D_Rund: 退货量
   *.D_Init: 初始量
   *.D_Warn: 预警量
   *.D_Man:  操作人
   *.D_Date: 生成时间
   *.D_DelMan: 删除人
   *.D_DelDate: 删除时间
   *.D_UseDate: 启用时间
   *.D_LastDate: 终止时间
   *.D_Valid: 是否启用(N、封存;Y、启用；D、删除)
  -----------------------------------------------------------------------------}

  sSQL_NewAXCard = 'Create Table $Table(R_ID $Inc, C_ID varChar(20),' +
       'C_Card varChar(50), C_Stock varChar(32), C_Count Integer Default 0,' +
       'C_Freeze $Float, C_HasDone $Float)';
  {-----------------------------------------------------------------------------
   订单表: Order
   *.R_ID: 记录编号
   *.C_ID: 记录编号
   *.C_Card: 卡片编号
   *.C_Stock: 品种编号
   *.C_Count: 厂内车辆
   *.C_Freeze: 冻结量
   *.C_HasDone: 完成量
  -----------------------------------------------------------------------------}

  sSQL_NewAXMoney = 'Create Table $Table(R_ID $Inc, M_ID varChar(20),' +
       'M_CusID varChar(20), M_CusName varChar(150), M_Count Integer Default 0,' +
       'M_Freeze $Float, M_HasDone $Float)';
  {-----------------------------------------------------------------------------
   AX金额表: Money
   *.R_ID: 记录编号
   *.M_ID: 记录编号
   *.M_CusID: 客户编号
   *.M_CusName: 客户名称
   *.M_Count: 厂内车辆
   *.M_Freeze: 冻结量
   *.M_HasDone: 完成量
  -----------------------------------------------------------------------------}
  
//------------------------------------------------------------------------------
// 数据查询
//------------------------------------------------------------------------------
  sQuery_SysDict = 'Select D_ID, D_Value, D_Memo, D_ParamA, ' +
         'D_ParamB From $Table Where D_Name=''$Name'' Order By D_Index ASC';
  {-----------------------------------------------------------------------------
   从数据字典读取数据
   *.$Table:数据字典表
   *.$Name:字典项名称
  -----------------------------------------------------------------------------}

  sQuery_ExtInfo = 'Select I_ID, I_Item, I_Info From $Table Where ' +
         'I_Group=''$Group'' and I_ItemID=''$ID'' Order By I_Index Desc';
  {-----------------------------------------------------------------------------
   从扩展信息表读取数据
   *.$Table:扩展信息表
   *.$Group:分组名称
   *.$ID:信息标识
  -----------------------------------------------------------------------------}

function CardStatusToStr(const nStatus: string): string;
//磁卡状态
function TruckStatusToStr(const nStatus: string): string;
//车辆状态
function BillTypeToStr(const nType: string): string;
//订单类型
function PostTypeToStr(const nPost: string): string;
//岗位类型
function BusinessToStr(const nBus: string): string;
//业务类型

implementation

//Desc: 将nStatus转为可读内容
function CardStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_CardIdle then Result := '空闲' else
  if nStatus = sFlag_CardUsed then Result := '正常' else
  if nStatus = sFlag_CardLoss then Result := '挂失' else
  if nStatus = sFlag_CardInvalid then Result := '注销' else Result := '未知';
end;

//Desc: 将nStatus转为可识别的内容
function TruckStatusToStr(const nStatus: string): string;
begin
  if nStatus = sFlag_TruckIn then Result := '进厂' else
  if nStatus = sFlag_TruckOut then Result := '出厂' else
  if nStatus = sFlag_TruckBFP then Result := '称皮重' else
  if nStatus = sFlag_TruckBFM then Result := '称毛重' else
  if nStatus = sFlag_TruckSH then Result := '送货中' else
  if nStatus = sFlag_TruckXH then Result := '验收处' else
  if nStatus = sFlag_TruckFH then Result := '放灰处' else
  if nStatus = sFlag_TruckZT then Result := '栈台' else Result := '未进厂';
end;

//Desc: 交货单类型转为可识别内容
function BillTypeToStr(const nType: string): string;
begin
  if nType = sFlag_TypeShip then Result := '船运' else
  if nType = sFlag_TypeZT   then Result := '栈台' else
  if nType = sFlag_TypeVIP  then Result := 'VIP' else Result := '普通';
end;

//Desc: 将岗位转为可识别内容
function PostTypeToStr(const nPost: string): string;
begin
  if nPost = sFlag_TruckIn   then Result := '门卫进厂' else
  if nPost = sFlag_TruckOut  then Result := '门卫出厂' else
  if nPost = sFlag_TruckBFP  then Result := '磅房称皮' else
  if nPost = sFlag_TruckBFM  then Result := '磅房称重' else
  if nPost = sFlag_TruckFH   then Result := '散装放灰' else
  if nPost = sFlag_TruckZT   then Result := '袋装栈台' else Result := '厂外';
end;

//Desc: 业务类型转为可识别内容
function BusinessToStr(const nBus: string): string;
begin
  if nBus = sFlag_Sale       then Result := '销售' else
  if nBus = sFlag_Provide    then Result := '供应' else
  if nBus = sFlag_Returns    then Result := '退货' else
  if nBus = sFlag_DuanDao    then Result := '短倒' else
  if nBus = sFlag_WaiXie     then Result := '外协' else
  if nBus = sFlag_Other      then Result := '其它';
end;

//------------------------------------------------------------------------------
//Desc: 添加系统表项
procedure AddSysTableItem(const nTable,nNewSQL: string);
var nP: PSysTableItem;
begin
  New(nP);
  gSysTableList.Add(nP);

  nP.FTable := nTable;
  nP.FNewSQL := nNewSQL;
end;

//Desc: 系统表
procedure InitSysTableList;
begin
  gSysTableList := TList.Create;

  AddSysTableItem(sTable_SysDict, sSQL_NewSysDict);
  AddSysTableItem(sTable_ExtInfo, sSQL_NewExtInfo);
  AddSysTableItem(sTable_SysLog, sSQL_NewSysLog);
  AddSysTableItem(sTable_SysErrLog, sSQL_NewSysErrLog);

  AddSysTableItem(sTable_BaseInfo, sSQL_NewBaseInfo);
  AddSysTableItem(sTable_SerialBase, sSQL_NewSerialBase);
  AddSysTableItem(sTable_SerialStatus, sSQL_NewSerialStatus);
  AddSysTableItem(sTable_StockMatch, sSQL_NewStockMatch);
  AddSysTableItem(sTable_WorkePC, sSQL_NewWorkePC);

  AddSysTableItem(sTable_WeixinLog, sSQL_NewWXLog);
  AddSysTableItem(sTable_WeixinMatch, sSQL_NewWXMatch);
  AddSysTableItem(sTable_WeixinTemp, sSQL_NewWXTemplate);

  AddSysTableItem(sTable_Card, sSQL_NewCard);
  //AddSysTableItem(sTable_CardExt, sSQL_NewCard);
  AddSysTableItem(sTable_Bill, sSQL_NewBill);
  AddSysTableItem(sTable_BillBak, sSQL_NewBill);
  AddSysTableItem(sTable_Refund, sSQL_NewRefund);
  AddSysTableItem(sTable_RefundBak, sSQL_NewRefund);

  AddSysTableItem(sTable_Truck, sSQL_NewTruck);
  AddSysTableItem(sTable_ZTLines, sSQL_NewZTLines);
  AddSysTableItem(sTable_ZTTrucks, sSQL_NewZTTrucks);
  AddSysTableItem(sTable_PoundLog, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundBak, sSQL_NewPoundLog);
  AddSysTableItem(sTable_PoundErr, sSQL_NewPoundError);
  AddSysTableItem(sTable_Picture, sSQL_NewPicture);
  AddSysTableItem(sTable_Batcode, sSQL_NewBatcode);
  AddSysTableItem(sTable_BatcodeDoc, sSQL_NewBatcodeDoc);
  AddSysTableItem(sTable_BatcodeDocBak, sSQL_NewBatcodeDoc);

  AddSysTableItem(sTable_AX_CardInfo, sSQL_NewAXCard);
  AddSysTableItem(sTable_AX_OrderInfo, sSQL_NewAXCard);
  AddSysTableItem(sTable_AX_MoneyInfo, sSQL_NewAXMoney);

  AddSysTableItem(sTable_Provider, ssql_NewProvider);
  AddSysTableItem(sTable_Materails, sSQL_NewMaterails);
  AddSysTableItem(sTable_PurchInfo, sSQL_NewPurchInfo);
  AddSysTableItem(sTable_PurchInfoBak, sSQL_NewPurchInfo);
  AddSysTableItem(sTable_Transfer, sSQL_NewTransfer);
  AddSysTableItem(sTable_TransferBak, sSQL_NewTransfer);
  AddSysTableItem(sTable_WaiXieInfo, sSQL_NewWaiXieInfo);
  AddSysTableItem(sTable_WaiXieBak, sSQL_NewWaiXieInfo);
end;

//Desc: 清理系统表
procedure ClearSysTableList;
var nIdx: integer;
begin
  for nIdx:= gSysTableList.Count - 1 downto 0 do
  begin
    Dispose(PSysTableItem(gSysTableList[nIdx]));
    gSysTableList.Delete(nIdx);
  end;

  FreeAndNil(gSysTableList);
end;

initialization
  InitSysTableList;
finalization
  ClearSysTableList;
end.


