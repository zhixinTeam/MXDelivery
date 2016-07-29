inherited fFormBill: TfFormBill
  Left = 367
  Top = 246
  ClientHeight = 480
  ClientWidth = 458
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 458
    Height = 480
    AutoControlTabOrders = False
    inherited BtnOK: TButton
      Left = 312
      Top = 447
      Caption = #24320#21333
      TabOrder = 11
    end
    inherited BtnExit: TButton
      Left = 382
      Top = 447
      TabOrder = 13
    end
    object EditValue: TcxTextEdit [2]
      Left = 296
      Top = 378
      ParentFont = False
      TabOrder = 10
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object EditCus: TcxTextEdit [3]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditCName: TcxTextEdit [4]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditJXMan: TcxTextEdit [5]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditDate: TcxTextEdit [6]
      Left = 81
      Top = 186
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditStock: TcxTextEdit [7]
      Left = 81
      Top = 328
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 4
      OnKeyPress = EditLadingKeyPress
      Width = 152
    end
    object EditSName: TcxTextEdit [8]
      Left = 81
      Top = 303
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 5
      OnKeyPress = EditLadingKeyPress
      Width = 152
    end
    object EditMax: TcxTextEdit [9]
      Left = 296
      Top = 328
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 6
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditTruck: TcxButtonEdit [10]
      Left = 81
      Top = 378
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 9
      OnKeyPress = EditLadingKeyPress
      Width = 152
    end
    object EditType: TcxComboBox [11]
      Left = 81
      Top = 353
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#26632#21488
        'V=V'#12289'VIP'
        'S=S'#12289#33337#36816)
      TabOrder = 7
      OnKeyPress = EditLadingKeyPress
      Width = 152
    end
    object EditFQ: TcxTextEdit [12]
      Left = 296
      Top = 353
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = True
      TabOrder = 8
      Width = 132
    end
    object EditMan: TcxTextEdit [13]
      Left = 81
      Top = 161
      ParentFont = False
      TabOrder = 16
      Width = 121
    end
    object ListStock: TcxComboBox [14]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 20
      Properties.ReadOnly = False
      Properties.OnChange = ListStockPropertiesChange
      TabOrder = 17
      Width = 121
    end
    object EditCard: TcxTextEdit [15]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 18
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          Caption = #29289#26009#21015#34920':'
          Control = ListStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #21345#29255#32534#21495':'
          Control = EditCard
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCName
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item5: TdxLayoutItem
          Caption = #32463' '#38144' '#21830':'
          Control = EditJXMan
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #24320' '#21333' '#20154':'
          Control = EditMan
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item6: TdxLayoutItem
          Caption = #24320#21333#26102#38388':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #25552#21333#20449#24687
        object dxGroupLayout1Group7: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxlytmLayout1Item10: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #27700#27877#21517#31216':'
            Control = EditSName
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Group2: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxlytmLayout1Item9: TdxLayoutItem
              Caption = #27700#27877#32534#21495':'
              Control = EditStock
              ControlOptions.ShowBorder = False
            end
            object dxlytmLayout1Item11: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21487#25552#36135#37327':'
              Control = EditMax
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxGroupLayout1Group6: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxGroupLayout1Group4: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxlytmLayout1Item13: TdxLayoutItem
              Caption = #25552#36135#36890#36947':'
              Control = EditType
              ControlOptions.ShowBorder = False
            end
            object dxlytmLayout1Item14: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #27700#27877#32534#21495':'
              Control = EditFQ
              ControlOptions.ShowBorder = False
            end
          end
          object dxGroupLayout1Group3: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxlytmLayout1Item12: TdxLayoutItem
              Caption = #25552#36135#36710#36742':'
              Control = EditTruck
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item8: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21150#29702#21544#25968':'
              Control = EditValue
              ControlOptions.ShowBorder = False
            end
          end
        end
      end
    end
  end
end
