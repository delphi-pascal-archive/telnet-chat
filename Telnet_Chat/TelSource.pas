unit TelSource;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdServerIOHandler, IdServerIOHandlerSocket, IdBaseComponent,
  IdComponent, IdTCPServer, IdTelnetServer, StdCtrls, ExtCtrls, StrUtils,
  IdTCPConnection, IdTCPClient, IdTelnet;

type
  TCRec = record
    IP, Nick: String;
    Port: Integer;
    Messages: array of String;
  end;
  TForm1 = class(TForm)
    Telnet: TIdTelnetServer;
    LOG: TMemo;
    CL: TListBox;
    PORT: TEdit;
    CON: TButton;
    Timer: TTimer;
    TelnetC: TIdTelnet;
    MSG: TEdit;
    IP: TEdit;
    Button1: TButton;
    NICK: TEdit;
    Button2: TButton;
    procedure TelnetExecute(AThread: TIdPeerThread);
    procedure TelnetException(AThread: TIdPeerThread;
      AException: Exception);
    procedure TelnetConnect(AThread: TIdPeerThread);
    procedure FormCreate(Sender: TObject);
    procedure TelnetDisconnect(AThread: TIdPeerThread);
    procedure MSGKeyPress(Sender: TObject; var Key: Char);
    procedure CONClick(Sender: TObject);
    procedure TelnetCConnected(Sender: TObject);
    procedure TelnetCDisconnected(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TelnetCDataAvailable(Sender: TIdTelnet;
      const Buffer: String);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Clients: array of TCRec;
  N: Integer;
  Connected: Boolean;
  Form1: TForm1;

implementation

{$R *.dfm}

function GetClient(T: TIdPeerThread): Integer;
var I: Integer;
begin
 for I:=0 to N-1 do
  if (T.Connection.Socket.Binding.IP = Clients[I].IP) and
     (T.Connection.Socket.Binding.Port = Clients[I].Port) then Result:=I;
end;

procedure TForm1.TelnetExecute(AThread: TIdPeerThread);
var S,R: String;
I,O: Integer;
T: Boolean;
begin
 S:=AThread.Connection.ReadLn();
 O:=GetClient(AThread);
 {Recieving a message}
 if S[1]='$' then begin
  R:=RightStr(S,Length(S)-1);
  AThread.Connection.WriteLn('!MSG_OK');
  LOG.Lines.Add(Format('Message "%s" from client #%d (%s:%d) was recieved',[R,O+1,Clients[O].IP,Clients[O].Port]));
  for I:=0 to N-1 do begin
   SetLength(Clients[I].Messages, Length(Clients[I].Messages)+1);
   Clients[I].Messages[Length(Clients[I].Messages)-1]:=Format('%s: %s',[Clients[O].Nick, R]);
  end;
 end
 {Sending messages to client}
 else if S='check' then begin
  if Length(Clients[O].Messages)>0 then begin
   for I:=0 to Length(Clients[O].Messages)-1 do
    AThread.Connection.WriteLn(Clients[O].Messages[I]);
   SetLength(Clients[O].Messages,0);
  end
   else AThread.Connection.WriteLn('!NO_MSGS');
 end
 {Setting up nickname}
 else if S[1]='@' then begin
  T:=True;
  R:=RightStr(S,Length(S)-1);
  for I:=0 to N-1 do
   if Clients[I].Nick=R then T:=False;
  if T then begin
   AThread.Connection.WriteLn('!NICK_OK');
   Clients[O].Nick:=R;
  end else AThread.Connection.WriteLn('!NICK_FAIL');
 end;
end;

procedure TForm1.TelnetException(AThread: TIdPeerThread;
  AException: Exception);
begin
 AThread.Connection.WriteLn(Format('?Exception: %s',[AException.Message]));
end;

procedure TForm1.TelnetConnect(AThread: TIdPeerThread);
begin
 N:=N+1;
 SetLength(Clients,N);
 Clients[N-1].IP:=AThread.Connection.Socket.Binding.IP;
 Clients[N-1].Port:=AThread.Connection.Socket.Binding.Port;
 LOG.Lines.Add(Format('Client #%d connected at %s:%d',[N,Clients[N-1].IP,Clients[N-1].Port]));
 CL.Items.Add(Format('#%d @ %s:%d',[N,Clients[N-1].IP,Clients[N-1].Port]));
 AThread.Connection.WriteLn(Format('You are client #%d. Address: %s:%d',[N,Clients[N-1].IP,Clients[N-1].Port]));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 N:=0;
end;

procedure TForm1.TelnetDisconnect(AThread: TIdPeerThread);
var I,O: Integer;
T: TCRec;
begin
 O:=GetClient(AThread);
 LOG.Lines.Add(Format('Client #%d (%s:%d) disconnected',[O+1,Clients[O].IP,Clients[O].Port]));
 for I:=O+1 to N-1 do begin
  T:=Clients[I];
  Clients[I]:=Clients[I-1];
  Clients[I-1]:=T;
  CL.Items.Strings[I-1]:=Format('#%d @ %s:%d',[I,Clients[I-1].IP,Clients[I-1].Port]);
 end;
 N:=N-1;
 CL.Items.Delete(N);
end;

procedure TForm1.MSGKeyPress(Sender: TObject; var Key: Char);
begin
 if (Ord(Key)=vk_Return) and Connected then
  TelnetC.WriteLn(Format('$%s',[MSG.Text]));
end;

procedure TForm1.CONClick(Sender: TObject);
begin
 TelnetC.BoundIP:=IP.Text;
 TelnetC.BoundPort:=StrToInt(Port.Text);
 TelnetC.Connect();
end;

procedure TForm1.TelnetCConnected(Sender: TObject);
begin
 Connected:=True;
 MessageBox(256,'Connected!','Telnet chat client',0);
 NICK.Enabled:=True;
 Button2.Enabled:=True;
 MSG.Enabled:=True;
 Button2Click(Self);
end;

procedure TForm1.TelnetCDisconnected(Sender: TObject);
begin
 Connected:=False;
 NICK.Enabled:=False;
 Button2.Enabled:=False;
 MSG.Enabled:=False;
end;

procedure TForm1.TimerTimer(Sender: TObject);
begin
 if Connected then
  TelnetC.WriteLn('check');
end;

procedure TForm1.TelnetCDataAvailable(Sender: TIdTelnet;
  const Buffer: String);
begin
 LOG.Lines.Add(Buffer);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 Telnet.Active:=True;
 MessageBox(256,'Server started!','Telnet chat server',0);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 if Connected then
  TelnetC.WriteLn(Format('@%s',[NICK.Text]));
end;

end.
