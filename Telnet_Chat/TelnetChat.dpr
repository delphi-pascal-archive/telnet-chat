program TelnetChat;

uses
  Forms,
  TelSource in 'TelSource.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Telnet chat';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
