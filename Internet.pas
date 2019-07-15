
{ Execute icinde IsWindowUnicode kontrolu yapildi. 19.06.2011 }

unit Internet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, WinInet;

const
  MAX_STRINGS = 12;

type
  { Forward declaration }
  TResponse = class;

  { TRequest }
  TRequest = class(TObject)
  private
    FResponse: TResponse;
    FContent: string;
    FVariables: array[0..MAX_STRINGS - 1] of string;
    FContext: Pointer;
    FHeaders: string;
    FSecure: Boolean;
    FAutoRedirect: Boolean;
    procedure AddHeaderItem(const Item, FormatStr: string);
  protected
    function GetVariable(const Index: Integer): string;
    procedure SetVariable(const Index: Integer; const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    property Context: Pointer read FContext write FContext;
    procedure Open(const Method, URI: string);
    function SendRequest(InetHandle: HINTERNET): Integer;
    procedure SetRequestHeader(const Param, Value: string);
    property AutoRedirect: Boolean read FAutoRedirect write FAutoRedirect;
    property Secure: Boolean read FSecure write FSecure;
    property Headers: string read FHeaders;
    property Host: string index 0 read GetVariable write SetVariable;
    property URL: string index 1 read GetVariable write SetVariable;
    property Method: string index 2 read GetVariable write SetVariable;
    property Cookie: string index 3 read GetVariable write SetVariable;
    property Content: string read FContent write FContent;
    property ContentType: string index 4 read GetVariable write SetVariable;
    property ContentLength: string index 5 read GetVariable write SetVariable;
    property Accept: string index 6 read GetVariable write SetVariable;
    property Connection: string index 7 read GetVariable write SetVariable;
    property Version: string index 8 read GetVariable write SetVariable;
    property Referer: string index 9 read GetVariable write SetVariable;
    property UserAgent: string index 10 read GetVariable write SetVariable;
    property Response: TResponse read FResponse;
  end;

  { TResponse }
  TResponse = class(TObject)
  private
    FRequestHandle: HINTERNET;
    FVariables: array[0..MAX_STRINGS - 1] of string;
    FContentStream: TMemoryStream;
    FHeaders: string;
    function GetVariable(const Index: Integer): string;
    procedure SetVariable(const Index: Integer; const Value: string);
    function GetContent: string;
    function GetHeaders: string;
    procedure SetHeaders(const Value: string);
  public
    constructor Create(RequestHandle: HINTERNET);
    destructor Destroy; override;
    property SetCookie: string index 4 read GetVariable write SetVariable;
    property ContentStream: TMemoryStream read FContentStream;
    property Content: string read GetContent;
    property Headers: string read GetHeaders write SetHeaders;
  end;

  { TInetThread }
  TInetThread = class(TThread)
  private
    { Private declarations }
    FRequest: TRequest;
    FInetHandle: HINTERNET;
    FHandle: THandle;
    FMessage: Cardinal;
    function GetResponse: TResponse;
  protected
    procedure Execute; override;
  public
    constructor Create(AHandle: THandle; AMessage: Cardinal; AInetHandle: HINTERNET);
    destructor Destroy; override;
    property Request: TRequest read FRequest;
    property Response: TResponse read GetResponse;
    property Terminated;
    property FreeOnTerminate;
  end;

  { TInternetThread }
  TInternetThread = class(TInetThread)
  end;

  { TRequestThread }
  TRequestThread = class(TThread)
  private
    { Private declarations }
    FRequest: TRequest;
    FInetHandle: HINTERNET;
    function GetResponse: TResponse;
  protected
    procedure Execute; override;
  public
    constructor Create(AInetHandle: HINTERNET);
    destructor Destroy; override;
    property Request: TRequest read FRequest;
    property Response: TResponse read GetResponse;
    property Terminated;
    property FreeOnTerminate;
  end;

type
  { TURLComponentStrings }
  TURLComponentStrings = record
    Scheme,
    HostName,
    URLPath,
    ExtraInfo: string;
  end;

var
  FInternet: WinInet.HINTERNET = nil;

{ OpenInternet }
function OpenInternet: Boolean;

{ CloseInternet }
procedure CloseInternet;

implementation

{ CloseInternet }
procedure CloseInternet;
begin
  if FInternet <> nil then
    if InternetCloseHandle(FInternet) then
      FInternet := nil;
end;

{ OpenInternet }
function OpenInternet: Boolean;
begin
  CloseInternet;
  FInternet := InternetOpen(nil, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  Result := FInternet <> nil;
end;

{ CrackURL }
function CrackURL(const URL: string; var URLComponents: TURLComponentStrings): BOOL;
var
  InetComponents: URL_COMPONENTS;
begin

  FillChar(InetComponents, SizeOf(URL_COMPONENTS), 0);
  with InetComponents do
  begin
    dwStructSize := SizeOf(URL_COMPONENTS);
    dwSchemeLength := INTERNET_MAX_SCHEME_LENGTH;
    dwHostNameLength := INTERNET_MAX_HOST_NAME_LENGTH;
    dwUserNameLength := INTERNET_MAX_USER_NAME_LENGTH;
    dwPasswordLength := INTERNET_MAX_PASSWORD_LENGTH;
    dwUrlPathLength := INTERNET_MAX_PATH_LENGTH;
    dwExtraInfoLength := INTERNET_MAX_URL_LENGTH;
  end;

  Result := InternetCrackUrl(PChar(URL), 0, 0, InetComponents);
  if Result then
    with InetComponents, URLComponents do
    begin
      SetString(Scheme, lpszScheme, dwSchemeLength);
      SetString(HostName, lpszHostName, dwHostNameLength);
      SetString(URLPath, lpszUrlPath, dwUrlPathLength);
      SetString(ExtraInfo, lpszExtraInfo, dwExtraInfoLength);
    end;

end;

{ TRequest }

procedure TRequest.AddHeaderItem(const Item, FormatStr: string);
begin
  if Item <> '' then
    FHeaders := FHeaders + Format(FormatStr, [Item]);
end;

constructor TRequest.Create;
begin
  inherited Create;
  FAutoRedirect := True;
  FSecure := False;
  Method := 'GET';
  Version := 'HTTP/1.1';
  FResponse := TResponse.Create(nil);
end;

destructor TRequest.Destroy;
begin
  FResponse.Free;
  inherited Destroy;
end;

function TRequest.GetVariable(const Index: Integer): string;
begin
  if (Index >= 0) and (Index < MAX_STRINGS) then
    Result := FVariables[Index]
  else Result := '';
end;

procedure TRequest.Open(const Method, URI: string);
var
  S: TURLComponentStrings;
begin
  CrackURL(URI, S);
  Self.Method := Method;
  Self.Secure := S.Scheme = 'https';
  Self.Host := S.HostName;
  Self.URL := S.URLPath + S.ExtraInfo;
end;

function TRequest.SendRequest(InetHandle: HINTERNET): Integer;
const
  CSecureFlag: array[Boolean] of Integer = (0, INTERNET_FLAG_SECURE);
  CAutoRedirect: array[Boolean] of Integer = (INTERNET_FLAG_NO_AUTO_REDIRECT, 0);
var
  hConnect, hRequest: HINTERNET;
  Buffer: array[0..8191] of Char;
  dwNumberOfBytes, dwAvailable: DWORD;
  ReadResult: BOOL;
  Port: Integer;

  function GetHttpVariable(Index: Integer): string;
  var
    Buffer: array[0..8191] of Char;
    dwLength, dwReserved: DWORD;
  begin
    Result := '';
    dwLength := SizeOf(Buffer);
    dwReserved := 0;
    FillChar(Buffer, dwLength, 0);
    if HttpQueryInfo(hRequest, Index, @Buffer, dwLength, dwReserved) then
    begin
      SetString(Result, Buffer, dwLength);
      Result := PChar(Result);
    end;
  end;

begin

  Result := -1;

  if not Assigned(InetHandle) then Exit;

  Port := INTERNET_DEFAULT_HTTP_PORT;
  if FSecure then Port := INTERNET_DEFAULT_HTTPS_PORT;

  hConnect := InternetConnect(InetHandle, PChar(Host), Port, nil, nil,
    INTERNET_SERVICE_HTTP, 0, Cardinal(FContext));

  if hConnect <> nil then
  begin

    try
      hRequest := HttpOpenRequest(hConnect, PChar(Method), PChar(URL),
        PChar(Version), nil, nil,
        INTERNET_FLAG_HYPERLINK or CSecureFlag[FSecure] or
        CAutoRedirect[FAutoRedirect], //???
        Cardinal(FContext));

      if hRequest <> nil then
      begin
        try

          AddHeaderItem(Accept, 'Accept: %s'#13#10);
          AddHeaderItem(Cookie, 'Cookie: %s'#13#10);
          AddHeaderItem(Referer, 'Referer: %s'#13#10);
          AddHeaderItem(UserAgent, 'User-Agent: %s'#13#10);
          AddHeaderItem(Connection, 'Connection: %s'#13#10);
          AddHeaderItem(ContentType, 'Content-Type: %s'#13#10);

          if HttpSendRequest(hRequest, PChar(Headers), Length(Headers),
            PChar(Content), Length(Content)) then
          begin

            Response.SetCookie := GetHttpVariable(HTTP_QUERY_SET_COOKIE);
            Response.Headers := GetHttpVariable(HTTP_QUERY_RAW_HEADERS_CRLF);

            repeat
              if InternetQueryDataAvailable(hRequest, dwAvailable, 0, Cardinal(FContext)) then
              begin
                FillChar(Buffer, SizeOf(Buffer), 0);
                ReadResult := InternetReadFile(hRequest, @Buffer, SizeOf(Buffer), dwNumberOfBytes);
                if (not ReadResult) and (GetLastError() <> ERROR_IO_PENDING) then
                begin
                  Result := -1;
                  Break;
                end;
                Response.ContentStream.Write(Buffer, dwNumberOfBytes);
              end
              else begin
                if GetLastError() <> ERROR_IO_PENDING then
                begin
                  Result := -1;
                  Break;
                end;
              end;
            until dwNumberOfBytes = 0;
            Result := 0;
          end;
        {
        HttpEndRequest(hRequest, nil, 0, 0);
        }
        finally
          InternetCloseHandle(hRequest);
        end;
      end;
    finally
      InternetCloseHandle(hConnect);
    end;

  end;

end;

procedure TRequest.SetRequestHeader(const Param, Value: string);
begin
  FHeaders := FHeaders + Format('%s: %s'#13#10, [Param, Value]);
end;

procedure TRequest.SetVariable(const Index: Integer; const Value: string);
begin
  if (Index >= 0) and (Index < MAX_STRINGS) then
    FVariables[Index] := Value;
end;

{ TResponse }

constructor TResponse.Create(RequestHandle: HINTERNET);
begin
  inherited Create;
  FRequestHandle := RequestHandle;
  FContentStream := TMemoryStream.Create;
end;

destructor TResponse.Destroy;
begin
  FContentStream.Free;
  inherited Destroy;
end;

function TResponse.GetContent: string;
var
  Stream: TStringStream;
begin
  Stream := TStringStream.Create('');
  try
    ContentStream.SaveToStream(Stream);
    Result := Stream.DataString;
  finally
    Stream.Free;
  end;
end;

function TResponse.GetHeaders: string;
begin
  Result := FHeaders;
end;

function TResponse.GetVariable(const Index: Integer): string;
begin
  if (Index >= 0) and (Index < MAX_STRINGS) then
    Result := FVariables[Index]
  else Result := '';
end;

procedure TResponse.SetHeaders(const Value: string);
begin
  FHeaders := Value;
end;

procedure TResponse.SetVariable(const Index: Integer; const Value: string);
begin
  if (Index >= 0) and (Index < MAX_STRINGS) then
    FVariables[Index] := Value;
end;

{ TInetThread }

constructor TInetThread.Create(AHandle: THandle; AMessage: Cardinal;
  AInetHandle: HINTERNET);
begin
  inherited Create(True);
  FHandle := AHandle;
  FMessage := AMessage;
  FInetHandle := AInetHandle;
  FRequest := TRequest.Create;
end;

destructor TInetThread.Destroy;
begin
  FRequest.Free;
  inherited Destroy;
end;

procedure TInetThread.Execute;
var
  Result: Integer;
begin
  if not Assigned(Self) then Exit;
  Result := FRequest.SendRequest(FInetHandle);
  if IsWindow(FHandle) then
  begin
    if IsWindowUnicode(FHandle) then PostMessageW(FHandle, FMessage, 0, Result)
    else PostMessage(FHandle, FMessage, 0, Result);
  end;
end;

function TInetThread.GetResponse: TResponse;
begin
  Result := FRequest.Response;
end;

{ TRequestThread }

constructor TRequestThread.Create(AInetHandle: HINTERNET);
begin
  inherited Create(True);
  FInetHandle := AInetHandle;
  FRequest := TRequest.Create;
end;

destructor TRequestThread.Destroy;
begin
  FRequest.Free;
  inherited Destroy;
end;

procedure TRequestThread.Execute;
begin
  if not Assigned(Self) then Exit;
  FRequest.SendRequest(FInetHandle);
  Terminate;
end;

function TRequestThread.GetResponse: TResponse;
begin
  Result := FRequest.Response;
end;

end.
