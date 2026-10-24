<%
' ============================================================
'  config.asp  -  Configuracion global y utilidades comunes
'  Proyecto: PoliMusic (ASP Clasico / SQL Server)
' ============================================================

Const APP_NAME        = "PoliMusic"
Const ASSETS_BASE     = "SongFilesAndImages_resources"
Const DB_SERVER       = "localhost"
Const DB_NAME         = "BDD_PoliMusic"
Const DB_USER         = "usr_polimusic"
Const DB_PASS         = "Politecnica1"

' UTF-8 para la salida (la directiva CodePage de cada pagina ya fija
' la codificacion de entrada de los formularios)
Response.CodePage  = 65001
Response.CharSet   = "utf-8"

' ------------------------------------------------------------
'  Abre una conexion ADO contra SQL Server
' ------------------------------------------------------------
Function DbOpen()
    Dim cn
    Set cn = Server.CreateObject("ADODB.Connection")
    cn.ConnectionTimeout = 10
    cn.Open "Provider=SQLOLEDB;Data Source=" & DB_SERVER & ";" & _
            "Initial Catalog=" & DB_NAME & ";" & _
            "User ID=" & DB_USER & ";Password=" & DB_PASS & ";"
    Set DbOpen = cn
End Function

' ------------------------------------------------------------
'  Convierte una ruta del tipo "~/songFiles/x.mp3" en una ruta web
'  valida dentro de la carpeta de recursos.
' ------------------------------------------------------------
Function AssetUrl(ByVal relPath)
    Dim p, pos, seg, rest
    p = Replace(relPath & "", "\", "/")
    If Left(p, 2) = "~/" Then p = Mid(p, 3)
    If Left(p, 1) = "/"  Then p = Mid(p, 2)

    pos = InStr(p, "/")
    If pos > 0 Then
        seg  = LCase(Left(p, pos - 1))
        rest = Mid(p, pos + 1)
    Else
        seg  = LCase(p)
        rest = ""
    End If

    Select Case seg
        Case "songfiles"
            AssetUrl = ASSETS_BASE & "/SongFiles/" & rest
        Case "userimages"
            If rest = "" Then rest = "default.jpg"
            AssetUrl = ASSETS_BASE & "/UserImages/" & rest
        Case "playlistimages"
            If rest = "" Then rest = "default.jpg"
            AssetUrl = ASSETS_BASE & "/PlaylistImages/" & rest
        Case Else
            AssetUrl = ASSETS_BASE & "/PlaylistImages/default.jpg"
    End Select
End Function

' ------------------------------------------------------------
'  Indica si un archivo fisico existe (para saber si hay audio)
' ------------------------------------------------------------
Function AssetExists(ByVal webPath)
    Dim fso
    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    AssetExists = False
    If Err.Number = 0 Then
        AssetExists = fso.FileExists(Server.MapPath(webPath))
    End If
    Err.Clear
    Set fso = Nothing
    On Error GoTo 0
End Function

' ------------------------------------------------------------
'  Devuelve la foto del usuario o el avatar por defecto
' ------------------------------------------------------------
Function UserPhotoUrl(ByVal photo)
    Dim u
    u = AssetUrl(photo)
    If Not AssetExists(u) Then u = ASSETS_BASE & "/UserImages/default.jpg"
    UserPhotoUrl = u
End Function

' ------------------------------------------------------------
'  Helpers de seguridad y formato
' ------------------------------------------------------------
Function H(ByVal value)
    H = Server.HTMLEncode(value & "")
End Function

Function ToInt(ByVal value, ByVal fallback)
    Dim n
    ToInt = fallback
    If IsNumeric(value) Then
        n = CDbl(value)
        ' Se valida el rango antes de convertir para evitar desbordamientos
        If n >= 0 And n <= 2147483647 Then
            ToInt = CLng(n)
        End If
    End If
End Function

Function RoleLabel(ByVal userType)
    If CStr(userType) = "1" Then
        RoleLabel = "Administrador"
    Else
        RoleLabel = "Usuario"
    End If
End Function

Function Num(ByVal value)
    Num = FormatNumber(value, 0, -1, 0, -1)
End Function

Function BoolNum(ByVal flag)
    If flag Then
        BoolNum = "1"
    Else
        BoolNum = "0"
    End If
End Function
%>
