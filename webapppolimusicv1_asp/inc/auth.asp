<%
' ============================================================
'  auth.asp  -  Control de sesion y de roles
'  Rol 0 = Usuario normal / Rol 1 = Administrador
' ============================================================

Function IsLoggedIn()
    IsLoggedIn = (Len(Session("UserID") & "") > 0)
End Function

Function IsAdmin()
    IsAdmin = (CStr(Session("UserType") & "") = "1")
End Function

Sub RequireLogin()
    If Not IsLoggedIn() Then
        Response.Redirect "login.asp"
        Response.End
    End If
End Sub

Sub RequireAdmin()
    If Not IsAdmin() Then
        Response.Redirect "songs.asp?msg=forbidden"
        Response.End
    End If
End Sub
%>
