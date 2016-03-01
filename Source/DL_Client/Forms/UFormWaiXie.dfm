inherited fFormWaiXie: TfFormWaiXie
  Left = 451
  Top = 243
  ClientHeight = 412
  ClientWidth = 411
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 411
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
      Left = 265
      Top = 379
      Caption = #24320#21333
      TabOrder = 1
    end
    inherited BtnExit: TButton
      Left = 335
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
      Width = 368
    end
    object EditCusName: TcxTextEdit [7]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 80
      Properties.ReadOnly = True
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
      Width = 571
    end
    object EditSenderName: TcxTextEdit [9]
      Left = 81
      Top = 121
      ParentFont = False
      Properties.MaxLength = 80
      Properties.ReadOnly = True
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
      Properties.ReadOnly = True
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
      Width = 357
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
      end
    end
  end
end
