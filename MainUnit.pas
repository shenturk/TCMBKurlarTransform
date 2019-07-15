unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBClient, Grids, DBGrids, Internet, ComObj, msxml,
  ExtCtrls, DBCtrls, ShellAPI, MidasLib, xmldom, Provider, Xmlxform;

type
  TTCMBKurlarForm = class(TForm)
    Label1: TLabel;
    EditURL: TEdit;
    ButtonFetch: TButton;
    DBGridKurlar: TDBGrid;
    DSKurlar: TDataSource;
    CDSKurlar: TClientDataSet;
    DBNavigator1: TDBNavigator;
    LoaderTimer: TTimer;
    LabelHome: TLabel;
    XMLTransformProviderKurlar: TXMLTransformProvider;
    CDSKurlarCurrencyCode: TStringField;
    CDSKurlarUnit: TStringField;
    CDSKurlarIsim: TStringField;
    CDSKurlarForexBuying: TStringField;
    CDSKurlarForexSelling: TStringField;
    CDSKurlarBanknoteBuying: TStringField;
    CDSKurlarBanknoteSelling: TStringField;
    procedure ButtonFetchClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LoaderTimerTimer(Sender: TObject);
    procedure LabelHomeClick(Sender: TObject);
    procedure LabelHomeMouseEnter(Sender: TObject);
    procedure LabelHomeMouseLeave(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TCMBKurlarForm: TTCMBKurlarForm;

implementation

{$R *.dfm}

procedure TTCMBKurlarForm.ButtonFetchClick(Sender: TObject);
var
  URL: string;
  Content: string;
  Request: TRequest;
begin
  URL := EditURL.Text;
  if URL = '' then
    raise Exception.Create('URL boþ olamaz!');
  Request := TRequest.Create;
  try
    ButtonFetch.Enabled := False;
    Request.Open('GET', URL);
    Request.SendRequest(Internet.FInternet);
    Content := Request.Response.Content;
    if Content = '' then
      raise Exception.Create('Baðlantý sýrasýnda hata oluþtu!');
    Request.Response.ContentStream.SaveToFile('Today.xml');
    XMLTransformProviderKurlar.XMLDataFile := 'Today.xml';
    CDSKurlar.Close;
    CDSKurlar.Open;
    DBGridKurlar.SetFocus;
  finally
    ButtonFetch.Enabled := True;
    Request.Free;
  end;
end;

procedure TTCMBKurlarForm.FormCreate(Sender: TObject);
begin
  CDSKurlar.Close;
  OpenInternet;
  LoaderTimer.Enabled := True;
end;

procedure TTCMBKurlarForm.FormDestroy(Sender: TObject);
begin
  CloseInternet;
end;

procedure TTCMBKurlarForm.LoaderTimerTimer(Sender: TObject);
begin
  LoaderTimer.Enabled := False;
  ButtonFetchClick(Sender);
end;

procedure TTCMBKurlarForm.LabelHomeClick(Sender: TObject);
begin
  ShellExecute(Self.Handle, 'open', 'http://shenturk.com', '', '', SW_SHOWNORMAL);
end;

procedure TTCMBKurlarForm.LabelHomeMouseEnter(Sender: TObject);
begin
  LabelHome.Font.Style := [fsUnderline];
end;

procedure TTCMBKurlarForm.LabelHomeMouseLeave(Sender: TObject);
begin
  LabelHome.Font.Style := [];
end;

end.
