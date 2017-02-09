inherited fFormOrder: TfFormOrder
  Left = 452
  Top = 185
  ClientHeight = 442
  ClientWidth = 425
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 425
    Height = 442
    AutoControlTabOrders = False
    inherited BtnOK: TButton
      Left = 279
      Top = 409
      Caption = #24320#21333
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 349
      Top = 409
      TabOrder = 6
    end
    object EditValue: TcxTextEdit [2]
      Left = 279
      Top = 367
      ParentFont = False
      TabOrder = 3
      Text = '0.00'
      OnKeyPress = EditLadingKeyPress
      Width = 138
    end
    object EditMate: TcxTextEdit [3]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditProvider: TcxTextEdit [4]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditTruck: TcxButtonEdit [5]
      Left = 81
      Top = 367
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 135
    end
    object EditMateID: TcxTextEdit [6]
      Left = 281
      Top = 161
      ParentFont = False
      TabOrder = 9
      Width = 121
    end
    object EditProID: TcxTextEdit [7]
      Left = 81
      Top = 36
      ParentFont = False
      TabOrder = 10
      Width = 121
    end
    object EditFreeze: TcxTextEdit [8]
      Left = 81
      Top = 186
      Enabled = False
      ParentFont = False
      TabOrder = 11
      Text = '0.00'
      Width = 121
    end
    object EditRest: TcxTextEdit [9]
      Left = 81
      Top = 211
      Enabled = False
      ParentFont = False
      TabOrder = 12
      Text = '0.00'
      Width = 121
    end
    object EditFreeTruck: TcxTextEdit [10]
      Left = 281
      Top = 186
      Enabled = False
      ParentFont = False
      TabOrder = 13
      Width = 121
    end
    object EditEnd: TcxTextEdit [11]
      Left = 281
      Top = 211
      Enabled = False
      ParentFont = False
      TabOrder = 14
      Text = '0.00'
      Width = 121
    end
    object EditCYS: TcxComboBox [12]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.OnChange = EditCYSPropertiesChange
      TabOrder = 15
      Width = 121
    end
    object EditCYName: TcxTextEdit [13]
      Left = 81
      Top = 111
      ParentFont = False
      TabOrder = 16
      Width = 121
    end
    object EditLineID: TcxComboBox [14]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.OnChange = EditCYSPropertiesChange
      TabOrder = 17
      Width = 121
    end
    object EditLine: TcxTextEdit [15]
      Left = 281
      Top = 136
      ParentFont = False
      TabOrder = 18
      Width = 121
    end
    object EditPValue: TcxTextEdit [16]
      Left = 81
      Top = 236
      ParentFont = False
      TabOrder = 19
      Text = '0.00'
      Width = 320
    end
    object CKBuDan: TcxCheckBox [17]
      Left = 11
      Top = 409
      Caption = #34917#21333
      ParentFont = False
      TabOrder = 20
      Transparent = True
      OnClick = CKBuDanClick
      Width = 121
    end
    object EditSrcId: TcxTextEdit [18]
      Left = 81
      Top = 317
      TabOrder = 21
      Width = 121
    end
    object EditSrcP: TcxTextEdit [19]
      Left = 81
      Top = 342
      TabOrder = 22
      Text = '0.00'
      Width = 136
    end
    object EditSrcM: TcxTextEdit [20]
      Left = 280
      Top = 342
      TabOrder = 23
      Text = '0.00'
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          Caption = #20379#24212#32534#21495':'
          Control = EditProID
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item3: TdxLayoutItem
          Caption = #20379' '#24212' '#21830':'
          Control = EditProvider
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #25215#36816#32534#21495':'
          Control = EditCYS
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item12: TdxLayoutItem
          Caption = #25215' '#36816' '#21830':'
          Control = EditCYName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Group2: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Group5: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              ShowBorder = False
              object dxLayout1Item13: TdxLayoutItem
                Caption = #25910#26009#32534#21495':'
                Control = EditLineID
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item9: TdxLayoutItem
                AutoAligns = [aaVertical]
                AlignHorz = ahClient
                Caption = #21407' '#26448' '#26009':'
                Control = EditMate
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Item5: TdxLayoutItem
              Caption = #20923' '#32467' '#37327':'
              Control = EditFreeze
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item6: TdxLayoutItem
              Caption = #35746#21333#21097#20313':'
              Control = EditRest
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group3: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Item14: TdxLayoutItem
              Caption = #25910'  '#26009'  '#21475':'
              Control = EditLine
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item3: TdxLayoutItem
              Caption = #21407#26448#26009#32534#21495':'
              Control = EditMateID
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item7: TdxLayoutItem
              Caption = #26410#20986#21378#36710#36742':'
              Control = EditFreeTruck
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item10: TdxLayoutItem
              Caption = #24403#21069#21487#29992#37327':'
              Control = EditEnd
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayout1Item15: TdxLayoutItem
          Caption = #36710#36742#30382#37325':'
          Control = EditPValue
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #25552#21333#20449#24687
        object dxLayout1Item17: TdxLayoutItem
          Caption = #21407#30917#21333#21495':'
          Control = EditSrcId
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group6: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item18: TdxLayoutItem
            Caption = #21407#36710#30382#37325':'
            Control = EditSrcP
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item19: TdxLayoutItem
            Caption = #21407#36710#27611#37325':'
            Control = EditSrcM
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group7: TdxLayoutGroup
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
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item16: TdxLayoutItem [0]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = CKBuDan
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
