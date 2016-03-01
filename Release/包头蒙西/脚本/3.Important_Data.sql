--SET   IDENTITY_INSERT   Sys_SerialBase   ON
--set   nocount   on   select   'insert   Sys_SerialBase(R_ID,B_Group,B_Object,B_Prefix,B_IDLen,B_Base,B_Date)   values('as   '--',R_ID,',',''''+B_Group+'''',',',''''+B_Object+'''',',',''''+B_Prefix+'''',',',B_IDLen,',',B_Base,',',''''+convert(char(23),B_Date,121)+'''',')'   from   Sys_SerialBase
--                                                                                      R_ID                                                                                                             B_IDLen          B_Base                                     
--------------------------------------------------------------------------------------- ----------- ---- ----------------- ---- ---------------------------------- ---- --------------------------- ---- ----------- ---- ----------- ---- ------------------------- ----
insert   Sys_SerialBase(B_Group,B_Object,B_Prefix,B_IDLen,B_Base,B_Date)   values('AXFunction'      ,    'AX_MsgNo'                         ,    'MX'                        ,    15          ,    0           ,    NULL                      )
insert   Sys_SerialBase(B_Group,B_Object,B_Prefix,B_IDLen,B_Base,B_Date)   values('BusFunction'     ,    'Bus_Pound'                        ,    'PB'                        ,    11          ,    0           ,    NULL                      )
insert   Sys_SerialBase(B_Group,B_Object,B_Prefix,B_IDLen,B_Base,B_Date)   values('BusFunction'     ,    'Bus_Bill'                         ,    'TH'                        ,    11          ,    0           ,    NULL                      )
insert   Sys_SerialBase(B_Group,B_Object,B_Prefix,B_IDLen,B_Base,B_Date)   values('BusFunction'     ,    'Bus_PurchID'                      ,    'CG'                        ,    11          ,    0           ,    NULL                      )
insert   Sys_SerialBase(B_Group,B_Object,B_Prefix,B_IDLen,B_Base,B_Date)   values('BusFunction'     ,    'Bus_WaiXie'                       ,    'WX'                        ,    11          ,    0           ,    NULL                      )
insert   Sys_SerialBase(B_Group,B_Object,B_Prefix,B_IDLen,B_Base,B_Date)   values('BusFunction'     ,    'Bus_Transfer'                     ,    'TF'                        ,    11          ,    0           ,    NULL                      )

--SET   IDENTITY_INSERT   Sys_SerialBase   OFF

