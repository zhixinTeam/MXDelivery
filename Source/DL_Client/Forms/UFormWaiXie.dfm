inherited fFormWaiXie: TfFormWaiXie
  Left = 451
  Top = 243
  ClientHeight = 412
  ClientWidth = 444
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 444
    Height = 412
    AutoControlTabOrders = False
    object Bevel1: TBevel [0]
      Left = 23
      Top = 86
      Width = 421
      Height = 5
      Shape = bsRightLine
    end
    object Bevel2: TBevel [1]
      Left = 23
      Top = 146
      Width = 501
      Height = 5
      Shape = bsRightLine
    end
    object Bevel3: TBevel [2]
      Left = 23
      Top = 206
      Width = 423
      Height = 5
      Shape = bsRightLine
    end
    inherited BtnOK: TButton
      Left = 298
      Top = 379
      Caption = #24320#21333
      TabOrder = 1
    end
    inherited BtnExit: TButton
      Left = 368
      Top = 379
      TabOrder = 3
    end
    object EditTruck: TcxButtonEdit [5]
      Left = 81
      Top = 241
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 135
    end
    object EditCusID: TcxComboBox [6]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ItemHeight = 20
      Properties.OnEditValueChanged = EditCusIDPropertiesEditValueChanged
      TabOrder = 6
      OnKeyPress = EditLadingKeyPress
      Width = 368
    end
    object EditCusName: TcxTextEdit [7]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 80
      Properties.ReadOnly = False
      TabOrder = 7
      Width = 368
    end
    object EditSender: TcxComboBox [8]
      Left = 81
      Top = 96
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ItemHeight = 20
      Properties.OnEditValueChanged = EditCusIDPropertiesEditValueChanged
      TabOrder = 8
      OnKeyPress = EditLadingKeyPress
      Width = 571
    end
    object EditSenderName: TcxTextEdit [9]
      Left = 81
      Top = 121
      ParentFont = False
      Properties.MaxLength = 80
      Properties.ReadOnly = False
      TabOrder = 9
      Width = 571
    end
    object EditStock: TcxComboBox [10]
      Left = 81
      Top = 156
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ItemHeight = 20
      Properties.OnEditValueChanged = EditCusIDPropertiesEditValueChanged
      TabOrder = 10
      Width = 571
    end
    object EditStockName: TcxTextEdit [11]
      Left = 81
      Top = 181
      ParentFont = False
      Properties.MaxLength = 80
      Properties.ReadOnly = False
      TabOrder = 11
      Width = 571
    end
    object EditLine: TcxComboBox [12]
      Left = 81
      Top = 216
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ItemHeight = 20
      Properties.OnEditValueChanged = EditCusIDPropertiesEditValueChanged
      TabOrder = 12
      OnKeyPress = EditLadingKeyPress
      Width = 357
    end
    object Check1: TcxCheckBox [13]
      Left = 11
      Top = 379
      Caption = #36710#36742#21378#22806#21368#36135#27169#24335'.'
      ParentFont = False
      TabOrder = 13
      Transparent = True
      Width = 150
    end
    object CKBuDan: TcxCheckBox [14]
      Left = 166
      Top = 379
      Caption = #34917#21333
      ParentFont = False
      TabOrder = 14
      Transparent = True
      OnClick = CKBuDanClick
      Width = 121
    end
    object EditPValue: TcxTextEdit [15]
      Left = 81
      Top = 266
      TabOrder = 15
      Text = '0.00'
      Width = 121
    end
    object EditValue: TcxTextEdit [16]
      Left = 81
      Top = 291
      TabOrder = 16
      Text = '0.00'
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item11: TdxLayoutItem
          Caption = #23458#25143#21015#34920':'
          Control = EditCusID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item12: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCusName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Control = Bevel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #36816#36755#21333#20301':'
          Control = EditSender
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #21333#20301#21517#31216':'
          Control = EditSenderName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Control = Bevel2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #29289#26009#21015#34920':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditStockName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Control = Bevel3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Caption = #20135' '#21697' '#32447':'
          Control = EditLine
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item12: TdxLayoutItem
          Caption = #25552#36135#36710#36742':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item15: TdxLayoutItem
          Caption = #36710#36742#30382#37325':'
          Control = EditPValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item16: TdxLayoutItem
          Caption = #36135#29289#20928#37325':'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item13: TdxLayoutItem [0]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item14: TdxLayoutItem [1]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = CKBuDan
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
