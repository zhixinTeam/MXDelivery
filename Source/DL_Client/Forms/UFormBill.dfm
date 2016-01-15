inherited fFormBill: TfFormBill
  Left = 541
  Top = 384
  ClientHeight = 390
  ClientWidth = 416
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 416
    Height = 390
    AutoControlTabOrders = False
    inherited BtnOK: TButton
      Left = 270
      Top = 357
      Caption = #24320#21333
      TabOrder = 12
    end
    inherited BtnExit: TButton
      Left = 340
      Top = 357
      TabOrder = 14
    end
    object EditValue: TcxTextEdit [2]
      Left = 279
      Top = 312
      ParentFont = False
      TabOrder = 11
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object EditCard: TcxTextEdit [3]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditCus: TcxTextEdit [4]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditCName: TcxTextEdit [5]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditJXMan: TcxTextEdit [6]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditDate: TcxTextEdit [7]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 4
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditStock: TcxTextEdit [8]
      Left = 81
      Top = 237
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 5
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditSName: TcxTextEdit [9]
      Left = 81
      Top = 262
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 6
      OnKeyPress = EditLadingKeyPress
      Width = 135
    end
    object EditMax: TcxTextEdit [10]
      Left = 279
      Top = 262
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 7
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditTruck: TcxButtonEdit [11]
      Left = 81
      Top = 312
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 10
      OnKeyPress = EditLadingKeyPress
      Width = 135
    end
    object EditType: TcxComboBox [12]
      Left = 81
      Top = 287
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#26632#21488
        'V=V'#12289'VIP'
        'S=S'#12289#33337#36816)
      TabOrder = 8
      OnKeyPress = EditLadingKeyPress
      Width = 135
    end
    object EditFQ: TcxTextEdit [13]
      Left = 279
      Top = 287
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 9
      Width = 132
    end
    object EditMan: TcxTextEdit [14]
      Left = 81
      Top = 136
      TabOrder = 17
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
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
        object dxlytmLayout1Item9: TdxLayoutItem
          Caption = #27700#27877#32534#21495':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxGroupLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxGroupLayout1Group7: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxlytmLayout1Item10: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #27700#27877#21517#31216':'
              Control = EditSName
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
end
