<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="inc/config.asp" -->
<!--#include file="inc/auth.asp" -->
<%
Response.CodePage = 65001
Response.CharSet  = "utf-8"

If IsLoggedIn() Then
    Response.Redirect "songs.asp"
Else
    Response.Redirect "login.asp"
End If
%>
