program TCMBKurlar;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {TCMBKurlarForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'TCMB Kurlar';
  Application.CreateForm(TTCMBKurlarForm, TCMBKurlarForm);
  Application.Run;
end.
