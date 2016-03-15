inherited fFramePoundErr: TfFramePoundErr
  Width = 1065
  Height = 513
  inherited ToolBar1: TToolBar
    Width = 1065
    inherited BtnAdd: TToolButton
      Visible = False
    end
    inherited BtnEdit: TToolButton
      Caption = #22788#29702
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 205
    Width = 1065
    Height = 308
    PopupMenu = PopupMenu1
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PopupMenu1
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 1065
    Height = 138
    object EditCus: TcxButtonEdit [0]
      Left = 225
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 105
    end
    object EditTruck: TcxButtonEdit [1]
      Left = 393
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 2
      OnKeyPress = OnCtrlKeyPress
      Width = 105
    end
    object cxTextEdit1: TcxTextEdit [2]
      Left = 57
      Top = 93
      Hint = 'T.E_SrcID'
      ParentFont = False
      TabOrder = 4
      Width = 100
    end
    object cxTextEdit2: TcxTextEdit [3]
      Left = 220
      Top = 93
      Hint = 'T.E_CusName'
      ParentFont = False
      TabOrder = 5
      Width = 125
    end
    object cxTextEdit4: TcxTextEdit [4]
      Left = 596
      Top = 93
      Hint = 'T.E_Truck'
      ParentFont = False
      TabOrder = 7
      Width = 100
    end
    object cxTextEdit3: TcxTextEdit [5]
      Left = 771
      Top = 93
      Hint = 'T.E_LimValue'
      ParentFont = False
      TabOrder = 8
      Width = 100
    end
    object EditDate: TcxButtonEdit [6]
      Left = 561
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 3
      Width = 176
    end
    object EditLID: TcxButtonEdit [7]
      Left = 57
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 105
    end
    object Edit1: TcxTextEdit [8]
      Left = 408
      Top = 93
      Hint = 'T.E_StockName'
      ParentFont = False
      TabOrder = 6
      Width = 125
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item8: TdxLayoutItem
          Caption = #21333#21495':'
          Control = EditLID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #21333#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #29289#26009#21697#31181':'
          Control = Edit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = #25552#36135#37327'('#21544'):'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 197
    Width = 1065
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 1065
    inherited TitleBar: TcxLabel
      Caption = #38169#35823#30917#21333#35760#24405#26597#35810
      Style.IsFontAssigned = True
      Width = 1065
      AnchorX = 533
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 4
    Top = 236
  end
  inherited DataSource1: TDataSource
    Left = 32
    Top = 236
  end
  object PopupMenu1: TPopupMenu
    Left = 64
    Top = 240
    object N1: TMenuItem
      Caption = #31216#37325#26102#25235#25293
      OnClick = N1Click
    end
  end
end
