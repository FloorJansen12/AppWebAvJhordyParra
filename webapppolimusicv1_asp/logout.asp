<%@ Language="VBScript" CodePage="65001" %>
<%
Response.CodePage = 65001
Response.CharSet  = "utf-8"

Session.Contents.RemoveAll
Session.Abandon

Response.Redirect "login.asp?bye=1"
Response.End
%>
