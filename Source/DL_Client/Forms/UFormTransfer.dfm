inherited fFormTransfer: TfFormTransfer
  Left = 438
  Top = 418
  Caption = #20498#26009#31649#29702
  ClientHeight = 201
  ClientWidth = 385
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 385
    Height = 201
    inherited BtnOK: TButton
      Left = 239
      Top = 168
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 309
      Top = 168
      TabOrder = 6
    end
    object EditTruck: TcxTextEdit [2]
      Left = 81
      Top = 36
      Enabled = False
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 0
      Width = 96
    end
    object EditMate: TcxTextEdit [3]
      Left = 81
      Top = 86
      Enabled = False
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 2
      Width = 96
    end
    object EditSrcAddr: TcxTextEdit [4]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 3
      Width = 96
    end
    object EditDstAddr: TcxTextEdit [5]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.MaxLength = 32
      TabOrder = 4
      Width = 96
    end
    object EditMID: TcxComboBox [6]
      Left = 81
      Top = 61
      Enabled = False
      Properties.OnChange = EditMIDPropertiesChange
      TabOrder = 1
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #21407#26009#32534#21495':'
          Control = EditMID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #21407#26009#21517#31216':'
          Control = EditMate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #20498#20986#22320#28857':'
          Control = EditSrcAddr
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #20498#20837#22320#28857':'
          Control = EditDstAddr
          ControlOptions.ShowBorder = False
        end
      end
    end
    object TdxLayoutGroup
    end
  end
end
