object TCMBKurlarForm: TTCMBKurlarForm
  Left = 446
  Top = 223
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'TCMB Kurlar XMLTransform'
  ClientHeight = 347
  ClientWidth = 586
  Color = clBtnFace
  Font.Charset = TURKISH_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 68
    Height = 13
    Caption = 'TCMB Kur URL'
  end
  object LabelHome: TLabel
    Left = 504
    Top = 317
    Width = 65
    Height = 13
    Cursor = crHandPoint
    Hint = 'shenturk.com'
    Caption = 'shenturk.com'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = LabelHomeClick
    OnMouseEnter = LabelHomeMouseEnter
    OnMouseLeave = LabelHomeMouseLeave
  end
  object EditURL: TEdit
    Left = 104
    Top = 16
    Width = 281
    Height = 21
    TabOrder = 0
    Text = 'http://www.tcmb.gov.tr/kurlar/today.xml'
  end
  object ButtonFetch: TButton
    Left = 392
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Getir'
    TabOrder = 1
    OnClick = ButtonFetchClick
  end
  object DBGridKurlar: TDBGrid
    Left = 16
    Top = 56
    Width = 553
    Height = 249
    DataSource = DSKurlar
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = TURKISH_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object DBNavigator1: TDBNavigator
    Left = 16
    Top = 311
    Width = 96
    Height = 25
    DataSource = DSKurlar
    VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast]
    Flat = True
    TabOrder = 3
  end
  object DSKurlar: TDataSource
    DataSet = CDSKurlar
    Left = 160
    Top = 152
  end
  object CDSKurlar: TClientDataSet
    Active = True
    Aggregates = <>
    Filter = 'CurrencyCode <> '#39'XDR'#39
    Filtered = True
    Params = <>
    ProviderName = 'XMLTransformProviderKurlar'
    Left = 192
    Top = 152
    object CDSKurlarCurrencyCode: TStringField
      DisplayLabel = 'D'#246'viz Kodu'
      DisplayWidth = 10
      FieldName = 'CurrencyCode'
      Size = 3
    end
    object CDSKurlarUnit: TStringField
      Alignment = taRightJustify
      DisplayLabel = 'Birim'
      DisplayWidth = 5
      FieldName = 'Unit'
      Size = 3
    end
    object CDSKurlarIsim: TStringField
      DisplayLabel = 'D'#246'viz Cinsi'
      DisplayWidth = 25
      FieldName = 'Isim'
      Size = 50
    end
    object CDSKurlarForexBuying: TStringField
      Alignment = taRightJustify
      DisplayLabel = 'D'#246'viz Al'#305#351
      DisplayWidth = 10
      FieldName = 'ForexBuying'
      Size = 7
    end
    object CDSKurlarForexSelling: TStringField
      Alignment = taRightJustify
      DisplayLabel = 'D'#246'viz Sat'#305#351
      DisplayWidth = 10
      FieldName = 'ForexSelling'
      Size = 7
    end
    object CDSKurlarBanknoteBuying: TStringField
      Alignment = taRightJustify
      DisplayLabel = 'Efektif Al'#305#351
      DisplayWidth = 10
      FieldName = 'BanknoteBuying'
      Size = 7
    end
    object CDSKurlarBanknoteSelling: TStringField
      Alignment = taRightJustify
      DisplayLabel = 'Efektif Sat'#305#351
      DisplayWidth = 10
      FieldName = 'BanknoteSelling'
      Size = 7
    end
  end
  object LoaderTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = LoaderTimerTimer
    Left = 224
    Top = 152
  end
  object XMLTransformProviderKurlar: TXMLTransformProvider
    TransformRead.TransformationFile = 'Today_ToDp.xtr'
    XMLDataFile = 'Today.xml'
    Left = 256
    Top = 152
  end
end
