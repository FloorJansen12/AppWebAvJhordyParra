<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="inc/config.asp" -->
<!--#include file="inc/auth.asp" -->
<%
Response.CodePage = 65001
Response.CharSet  = "utf-8"

RequireLogin
RequireAdmin

' Solo se permite eliminar mediante POST
If UCase(Request.ServerVariables("REQUEST_METHOD")) <> "POST" Then
    Response.Redirect "songs.asp?msg=forbidden"
    Response.End
End If

Dim songId, cn, failed

songId = ToInt(Request.Form("id"), 0)

If songId <= 0 Then
    Response.Redirect "songs.asp?msg=notfound"
    Response.End
End If

failed = False

On Error Resume Next

Set cn = DbOpen()
If Err.Number <> 0 Then
    failed = True
    Err.Clear
Else
    ' Se eliminan primero las referencias para respetar las claves foraneas
    cn.BeginTrans

    cn.Execute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = " & songId
    cn.Execute "DELETE FROM TBL_TRACKLIST     WHERE ID_SONG = " & songId
    cn.Execute "DELETE FROM TBL_PLAYER        WHERE ID_SONG = " & songId
    cn.Execute "DELETE FROM TBL_SONG          WHERE ID_SONG = " & songId

    If Err.Number <> 0 Then
        failed = True
        Err.Clear
        cn.RollbackTrans
    Else
        cn.CommitTrans
    End If

    cn.Close
    Set cn = Nothing
End If

On Error GoTo 0

If failed Then
    Response.Redirect "songs.asp?msg=error"
Else
    Response.Redirect "songs.asp?msg=deleted"
End If
Response.End
%>
