inherited fFormPoundErr: TfFormPoundErr
  Left = 291
  Top = 161
  Width = 486
  Height = 566
  BorderStyle = bsSizeable
  Caption = #23703#20301#20449#24687#38169#35823#22788#29702
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 470
    Height = 528
    inherited BtnOK: TButton
      Left = 324
      Top = 495
      Caption = #25918#34892
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 394
      Top = 495
      TabOrder = 7
    end
    object ListInfo: TcxMCListBox [2]
      Left = 23
      Top = 36
      Width = 336
      Height = 172
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 74
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 258
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
      OnClick = ListInfoClick
    end
    object ListBill: TcxListView [3]
      Left = 23
      Top = 407
      Width = 350
      Height = 115
      Columns = <
        item
          Caption = #21333#25454#32534#21495
          Width = 80
        end
        item
          Alignment = taCenter
          Caption = #25552'/'#20379'('#21544')'
          Width = 100
        end
        item
          Caption = #29289#26009#21517#31216
          Width = 80
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 5
      ViewStyle = vsReport
      OnSelectItem = ListBillSelectItem
    end
    object EditCus: TcxTextEdit [4]
      Left = 81
      Top = 238
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 110
    end
    object EditBill: TcxTextEdit [5]
      Left = 81
      Top = 213
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 105
    end
    object MemoErr: TMemo [6]
      Left = 82
      Top = 264
      Width = 364
      Height = 73
      BorderStyle = bsNone
      TabOrder = 3
    end
    object MemoDeal: TMemo [7]
      Left = 82
      Top = 344
      Width = 364
      Height = 25
      BorderStyle = bsNone
      TabOrder = 4
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #20132#36135#21333#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          Caption = 'cxMCListBox1'
          ShowCaption = False
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object LayItem1: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #21333#25454#32534#21495':'
            Control = EditBill
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item5: TdxLayoutItem
            Caption = #23458#25143#21517#31216':'
            Control = EditCus
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #38169#35823#20449#24687':'
          Control = MemoErr
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #22788#29702#24847#35265':'
          Control = MemoDeal
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #20132#36135#21333#21015#34920
        object dxLayout1Item7: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = 'cxListView1'
          ShowCaption = False
          Control = ListBill
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
