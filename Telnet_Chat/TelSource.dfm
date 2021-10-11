object Form1: TForm1
  Left = 239
  Top = 127
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Telnet Chat'
  ClientHeight = 465
  ClientWidth = 683
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object LOG: TMemo
    Left = 8
    Top = 8
    Width = 513
    Height = 385
    TabOrder = 0
  end
  object CL: TListBox
    Left = 528
    Top = 8
    Width = 145
    Height = 385
    ItemHeight = 16
    TabOrder = 1
  end
  object PORT: TEdit
    Left = 152
    Top = 400
    Width = 49
    Height = 25
    TabOrder = 2
    Text = '23'
  end
  object CON: TButton
    Left = 208
    Top = 400
    Width = 89
    Height = 25
    Caption = 'Connect!'
    TabOrder = 3
    OnClick = CONClick
  end
  object MSG: TEdit
    Left = 8
    Top = 432
    Width = 665
    Height = 25
    Enabled = False
    TabOrder = 4
    Text = 'Message here'
    OnKeyPress = MSGKeyPress
  end
  object IP: TEdit
    Left = 8
    Top = 400
    Width = 137
    Height = 25
    TabOrder = 5
    Text = '127.0.0.1'
  end
  object Button1: TButton
    Left = 536
    Top = 400
    Width = 137
    Height = 25
    Caption = 'Start server'
    TabOrder = 6
    OnClick = Button1Click
  end
  object NICK: TEdit
    Left = 304
    Top = 400
    Width = 113
    Height = 25
    Enabled = False
    TabOrder = 7
    Text = 'Nickname'
  end
  object Button2: TButton
    Left = 424
    Top = 400
    Width = 105
    Height = 25
    Caption = 'Change nick'
    Enabled = False
    TabOrder = 8
    OnClick = Button2Click
  end
  object Telnet: TIdTelnetServer
    Bindings = <>
    CommandHandlers = <>
    Greeting.NumericCode = 0
    Greeting.Text.Strings = (
      'You are connected to test server.')
    MaxConnectionReply.NumericCode = 0
    MaxConnectionReply.Text.Strings = (
      'Max connections')
    MaxConnections = 1000
    OnConnect = TelnetConnect
    OnExecute = TelnetExecute
    OnDisconnect = TelnetDisconnect
    OnException = TelnetException
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    LoginMessage = 'Indy Telnet Server'
    Left = 24
    Top = 32
  end
  object Timer: TTimer
    Interval = 200
    OnTimer = TimerTimer
    Left = 248
    Top = 288
  end
  object TelnetC: TIdTelnet
    MaxLineAction = maException
    ReadTimeout = 0
    OnDisconnected = TelnetCDisconnected
    OnConnected = TelnetCConnected
    Port = 23
    OnDataAvailable = TelnetCDataAvailable
    Terminal = 'dumb'
    Left = 56
    Top = 32
  end
end
