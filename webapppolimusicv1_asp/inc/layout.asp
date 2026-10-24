<%
' ============================================================
'  layout.asp  -  Cabecera, barra lateral y pie comunes
' ============================================================

Sub PageHead(ByVal pageTitle, ByVal activeNav)
    Dim photo, roleClass
    photo = UserPhotoUrl(Session("UserPhoto"))
    If IsAdmin() Then
        roleClass = "admin"
    Else
        roleClass = "user"
    End If
%><!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= H(pageTitle) %> &middot; <%= APP_NAME %></title>
<link rel="stylesheet" href="css/styles.css">
</head>
<body>
<div class="app">

  <aside class="sidebar">
    <a class="brand" href="songs.asp">
      <span class="brand-mark" aria-hidden="true">
        <svg viewBox="0 0 24 24" fill="none">
          <path d="M7 17V7.6a1 1 0 0 1 .78-.98l6-1.2A1 1 0 0 1 15 6.4V15" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
          <circle cx="5" cy="17.5" r="2.2" fill="currentColor"/>
          <circle cx="13" cy="15.5" r="2.2" fill="currentColor"/>
        </svg>
      </span>
      <span class="brand-text">Poli<span>Music</span></span>
    </a>

    <nav class="nav" aria-label="Navegaci&oacute;n principal">
      <a class="nav-item<% If activeNav = "home" Then Response.Write " is-active" %>" href="songs.asp">
        <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 10.5 12 4l8 6.5V19a1 1 0 0 1-1 1h-4v-5H9v5H5a1 1 0 0 1-1-1z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/></svg>
        <span>Inicio</span>
      </a>
      <a class="nav-item<% If activeNav = "songs" Then Response.Write " is-active" %>" href="songs.asp#song-list">
        <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 6h11M4 12h11M4 18h7" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/><circle cx="18.5" cy="17.5" r="2.2" stroke="currentColor" stroke-width="1.6"/><path d="M20.7 17.5V8l-4 1" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        <span>Song List</span>
      </a>
      <a class="nav-item" href="logout.asp">
        <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M15 5H7a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h8" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><path d="M17 8.5 20.5 12 17 15.5M11 12h9" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        <span>Cerrar sesi&oacute;n</span>
      </a>
    </nav>

    <div class="side-card">
      <p class="side-label">Sesi&oacute;n activa</p>
      <div class="side-user">
        <img class="avatar avatar-sm" src="<%= H(photo) %>" alt="">
        <div class="side-user-info">
          <strong><%= H(Session("Username")) %></strong>
          <span class="role-badge role-<%= roleClass %>"><%= RoleLabel(Session("UserType")) %></span>
        </div>
      </div>
    </div>

    <p class="side-note">ASP Cl&aacute;sico &middot; SQL Server</p>
  </aside>

  <main class="main">
<%
End Sub

Sub PageFoot()
%>
  </main>
</div>
<script src="js/app.js"></script>
</body>
</html>
<%
End Sub
%>
