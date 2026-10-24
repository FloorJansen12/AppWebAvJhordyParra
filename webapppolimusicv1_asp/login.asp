<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="inc/config.asp" -->
<!--#include file="inc/auth.asp" -->
<%
Response.CodePage = 65001
Response.CharSet  = "utf-8"

If IsLoggedIn() Then
    Response.Redirect "songs.asp"
    Response.End
End If

Dim errMsg, notice, uName, uPass
Dim cn, cmd, rs

errMsg = ""
notice = ""

If Request.QueryString("bye") = "1" Then
    notice = "Tu sesi&oacute;n se cerr&oacute; correctamente."
End If

If UCase(Request.ServerVariables("REQUEST_METHOD")) = "POST" Then

    uName = Trim(Request.Form("username") & "")
    uPass = Trim(Request.Form("password") & "")

    If uName = "" Or uPass = "" Then
        errMsg = "Debes ingresar tu usuario y tu contraseña."
    ElseIf Len(uName) > 50 Or Len(uPass) > 50 Then
        errMsg = "Los datos ingresados no son válidos."
    Else

        On Error Resume Next

        Set cn = DbOpen()
        If Err.Number <> 0 Then
            errMsg = "No se pudo conectar con la base de datos."
            Err.Clear
        Else
            Set cmd = Server.CreateObject("ADODB.Command")
            Set cmd.ActiveConnection = cn
            cmd.CommandType = 1
            cmd.CommandText = "SELECT TOP 1 ID_USER, USERNAME, USER_TYPE, USER_PHOTO, EMAIL " & _
                              "FROM TBL_USER WHERE USERNAME = ? AND PASSWORD = ?"
            cmd.Parameters.Append cmd.CreateParameter("@username", 200, 1, 50, uName)
            cmd.Parameters.Append cmd.CreateParameter("@password", 200, 1, 50, uPass)

            Set rs = cmd.Execute
            If Err.Number <> 0 Then
                errMsg = "No se pudo validar el usuario."
                Err.Clear
            ElseIf rs.EOF Then
                errMsg = "Usuario o contraseña incorrectos."
            Else
                ' --- Variables de sesion usadas por el resto de la aplicacion ---
                Session("UserID")    = CLng(rs("ID_USER"))
                Session("Username")  = rs("USERNAME") & ""
                Session("UserType")  = CInt(rs("USER_TYPE"))
                Session("UserPhoto") = rs("USER_PHOTO") & ""
                Session("UserEmail") = rs("EMAIL") & ""
                Session.Timeout      = 60

                rs.Close
                cn.Close
                Set rs  = Nothing
                Set cmd = Nothing
                Set cn  = Nothing

                On Error GoTo 0
                Response.Redirect "songs.asp"
                Response.End
            End If

            If Not (rs Is Nothing) Then
                If rs.State = 1 Then rs.Close
            End If
            Set rs  = Nothing
            Set cmd = Nothing
            cn.Close
            Set cn  = Nothing
        End If

        On Error GoTo 0
    End If
End If
%><!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Iniciar sesi&oacute;n &middot; <%= APP_NAME %></title>
<link rel="stylesheet" href="css/styles.css">
</head>
<body class="auth-body">

<main class="auth-shell">

  <section class="auth-brand">
    <div class="auth-rings" aria-hidden="true"></div>
    <a class="brand brand-lg" href="login.asp">
      <span class="brand-mark" aria-hidden="true">
        <svg viewBox="0 0 24 24" fill="none">
          <path d="M7 17V7.6a1 1 0 0 1 .78-.98l6-1.2A1 1 0 0 1 15 6.4V15" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
          <circle cx="5" cy="17.5" r="2.2" fill="currentColor"/>
          <circle cx="13" cy="15.5" r="2.2" fill="currentColor"/>
        </svg>
      </span>
      <span class="brand-text">Poli<span>Music</span></span>
    </a>

    <h1 class="auth-headline">Tu m&uacute;sica,<br>en un solo lugar.</h1>
    <p class="auth-sub">Escucha el cat&aacute;logo de la biblioteca, descubre nuevas canciones y administra tu colecci&oacute;n desde un mismo panel.</p>

    <ul class="auth-points">
      <li><span class="dot"></span>Reproductor integrado en el navegador</li>
      <li><span class="dot"></span>Listado de canciones siempre disponible</li>
      <li><span class="dot"></span>Roles de usuario y administrador</li>
    </ul>

    <p class="auth-foot">ASP Cl&aacute;sico &middot; SQL Server &middot; HTML, CSS y JavaScript</p>
  </section>

  <section class="auth-card">
    <header class="auth-card-head">
      <h2>Iniciar sesi&oacute;n</h2>
      <p>Ingresa con tu cuenta para entrar a la biblioteca.</p>
    </header>

    <% If errMsg <> "" Then %>
    <div class="alert alert-error" role="alert">
      <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.6"/><path d="M12 7.5v5.5M12 16.2v.3" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
      <span><%= H(errMsg) %></span>
    </div>
    <% End If %>

    <% If notice <> "" Then %>
    <div class="alert alert-ok" role="status">
      <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.6"/><path d="m8.2 12.3 2.4 2.4 5.2-5.2" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>
      <span><%= notice %></span>
    </div>
    <% End If %>

    <form class="auth-form" method="post" action="login.asp" autocomplete="on">
      <div class="field">
        <label for="username">Usuario</label>
        <input id="username" name="username" type="text" maxlength="50" required
               placeholder="usuario" value="<%= H(uName) %>" autocomplete="username">
      </div>

      <div class="field">
        <label for="password">Contrase&ntilde;a</label>
        <div class="field-pass">
          <input id="password" name="password" type="password" maxlength="50" required
                 placeholder="••••••••" autocomplete="current-password">
          <button type="button" class="pass-toggle" data-toggle-pass aria-label="Mostrar contrase&ntilde;a">
            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M2.8 12S6 6.4 12 6.4 21.2 12 21.2 12 18 17.6 12 17.6 2.8 12 2.8 12Z" stroke="currentColor" stroke-width="1.6"/><circle cx="12" cy="12" r="2.6" stroke="currentColor" stroke-width="1.6"/></svg>
          </button>
        </div>
      </div>

      <button class="btn btn-primary btn-block" type="submit">Entrar</button>
    </form>

    <div class="auth-demo">
      <p class="auth-demo-title">Cuentas de prueba</p>
      <div class="auth-demo-row"><span>Usuario</span><code>userNormal</code><code>12345678</code></div>
      <div class="auth-demo-row"><span>Admin</span><code>userAdmin</code><code>12345678</code></div>
    </div>
  </section>

</main>

<script src="js/app.js"></script>
</body>
</html>
