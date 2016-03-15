inherited fFormGetPurchLine: TfFormGetPurchLine
  Left = 633
  Top = 413
  Caption = #36873#25321#25910#26009#21475
  ClientHeight = 158
  ClientWidth = 326
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 326
    Height = 158
    inherited BtnOK: TButton
      Left = 180
      Top = 125
      Caption = #30830#23450
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 250
      Top = 125
      TabOrder = 4
    end
    object cxLabel1: TcxLabel [2]
      Left = 23
      Top = 61
      AutoSize = False
      ParentFont = False
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 20
      Width = 287
    end
    object EditLineName: TcxTextEdit [3]
      Left = 93
      Top = 86
      ParentFont = False
      Properties.MaxLength = 15
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsOffice11
      TabOrder = 2
      OnKeyPress = EditLineNameKeyPress
      Width = 121
    end
    object EditLineID: TcxComboBox [4]
      Left = 93
      Top = 36
      ParentFont = False
      Properties.OnChange = EditLineIDPropertiesChange
      TabOrder = 0
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = ''
        object dxLayout1Item3: TdxLayoutItem
          Caption = #25910#26009#21475#32534#21495':'
          Control = EditLineID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #25910'  '#26009'  '#21475':'
          Control = EditLineName
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
