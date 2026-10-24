<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="inc/config.asp" -->
<!--#include file="inc/auth.asp" -->
<!--#include file="inc/layout.asp" -->
<%
Response.CodePage = 65001
Response.CharSet  = "utf-8"

RequireLogin

Dim cn, rs, sql
Dim totalSongs, playableSongs
Dim flashMsg, flashType, chipClass
Dim artUrl

artUrl = ASSETS_BASE & "/PlaylistImages/default.jpg"

If IsAdmin() Then
    chipClass = "admin"
Else
    chipClass = "user"
End If

' ---------------- Mensajes de retorno ----------------
flashMsg  = ""
flashType = "ok"

Select Case LCase(Request.QueryString("msg") & "")
    Case "saved"
        flashMsg = "Canción creada correctamente."
        flashType = "ok"
    Case "updated"
        flashMsg = "Canción actualizada correctamente."
        flashType = "ok"
    Case "deleted"
        flashMsg = "Canción eliminada correctamente."
        flashType = "ok"
    Case "forbidden"
        flashMsg = "No tienes permisos para realizar esa acción."
        flashType = "error"
    Case "notfound"
        flashMsg = "La canción solicitada no existe."
        flashType = "error"
    Case "error"
        flashMsg = "Ocurrió un error al procesar la solicitud."
        flashType = "error"
End Select

' ---------------- Datos ----------------
On Error Resume Next

Set cn = DbOpen()
If Err.Number <> 0 Then
    Response.Write "<p style=""padding:40px;color:#fb7185"">No se pudo conectar con la base de datos.</p>"
    Response.End
End If

sql = "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS,0) AS PLAYS, " & _
      " (SELECT TOP 1 a.TITLE_ALBUM FROM TBL_TRACKLIST t " & _
      "    INNER JOIN TBL_ALBUM a ON a.ID_ALBUM = t.ID_ALBUM " & _
      "    WHERE t.ID_SONG = s.ID_SONG ORDER BY a.ID_ALBUM) AS ALBUM, " & _
      " (SELECT TOP 1 ar.ARTIST_NAME + ' ' + ISNULL(ar.ARTIST_LASTNAME,'') FROM TBL_PLAYER p " & _
      "    INNER JOIN TBL_ARTIST ar ON ar.ID_ARTIST = p.ID_ARTIST " & _
      "    WHERE p.ID_SONG = s.ID_SONG ORDER BY ar.ID_ARTIST) AS ARTIST " & _
      "FROM TBL_SONG s ORDER BY s.ID_SONG"

Set rs = Server.CreateObject("ADODB.Recordset")
rs.CursorLocation = 3
rs.Open sql, cn, 3, 1

If Err.Number <> 0 Then
    Response.Write "<p style=""padding:40px;color:#fb7185"">No se pudo leer el listado de canciones.</p>"
    Response.End
End If

On Error GoTo 0

' Conteo previo: total y cuantas tienen archivo de audio disponible
totalSongs    = 0
playableSongs = 0
If rs.RecordCount > 0 Then
    totalSongs = rs.RecordCount
    rs.MoveFirst
    Do While Not rs.EOF
        If AssetExists(AssetUrl(rs("SONG_PATH") & "")) Then playableSongs = playableSongs + 1
        rs.MoveNext
    Loop
    rs.MoveFirst
End If

PageHead "Song List", "songs"
%>
      <header class="topbar">
        <div class="crumbs">
          <span class="crumb-mark"></span>
          <span>Biblioteca</span>
          <span class="crumb-sep">/</span>
          <strong>Song List</strong>
        </div>
        <div class="topbar-right">
          <span class="role-chip role-<%= chipClass %>"><%= RoleLabel(Session("UserType")) %></span>
          <a class="btn btn-ghost" href="logout.asp">
            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M15 5H7a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h8" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><path d="M17 8.5 20.5 12 17 15.5M11 12h9" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
            Cerrar sesión
          </a>
        </div>
      </header>

      <section class="hero">
        <div class="hero-glow" aria-hidden="true"></div>
        <div class="hero-text">
          <p class="eyebrow">Bienvenido de nuevo</p>
          <h1 class="hero-title">Hola, <span class="hero-name"><%= H(Session("Username")) %></span></h1>
          <p class="hero-sub">Nos alegra verte otra vez. Tu biblioteca está lista para sonar.</p>
          <div class="hero-meta">
            <span class="pill">
              <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M7 17V7.6a1 1 0 0 1 .78-.98l6-1.2A1 1 0 0 1 15 6.4V15" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><circle cx="5" cy="17.5" r="2.2" fill="currentColor"/><circle cx="13" cy="15.5" r="2.2" fill="currentColor"/></svg>
              <span id="statTotal"><%= totalSongs %></span> canciones
            </span>
            <span class="pill">
              <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 14v-2a8 8 0 0 1 16 0v2" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/><rect x="2.6" y="13" width="4" height="7" rx="1.6" stroke="currentColor" stroke-width="1.6"/><rect x="17.4" y="13" width="4" height="7" rx="1.6" stroke="currentColor" stroke-width="1.6"/></svg>
              <span id="statPlayable"><%= playableSongs %></span> con audio
            </span>
          </div>
        </div>
        <div class="hero-art" aria-hidden="true">
          <div class="vinyl">
            <div class="vinyl-label"></div>
          </div>
        </div>
      </section>

      <% If flashMsg <> "" Then %>
      <div class="flash flash-<%= flashType %>" role="status" data-flash>
        <span><%= H(flashMsg) %></span>
        <button type="button" class="flash-close" data-flash-close aria-label="Cerrar">&times;</button>
      </div>
      <% End If %>

      <section class="panel" id="song-list">
        <header class="panel-head">
          <div class="panel-heading">
            <h2>Song List</h2>
            <p>A continuación se presenta el listado de canciones (Song List) de la biblioteca.</p>
          </div>
          <% If IsAdmin() Then %>
          <div class="panel-actions">
            <a class="btn btn-primary" href="song_form.asp?mode=new">
              <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M12 5.5v13M5.5 12h13" stroke="currentColor" stroke-width="1.9" stroke-linecap="round"/></svg>
              Añadir canción
            </a>
          </div>
          <% End If %>
        </header>

        <div class="table-wrap">
          <table class="song-table">
            <thead>
              <tr>
                <th class="col-index" scope="col">#</th>
                <th class="col-title" scope="col">Título</th>
                <th class="col-album" scope="col">Álbum</th>
                <th class="col-plays" scope="col">Reproducciones</th>
                <th class="col-state" scope="col">Estado</th>
                <% If IsAdmin() Then %><th class="col-actions" scope="col">Acciones</th><% End If %>
              </tr>
            </thead>
            <tbody>
<%
Dim i, sId, sName, sPath, sAlbum, sArtist, sPlays, sAudio, sHas, rowClass
i = 0

Do While Not rs.EOF
    i = i + 1

    sId    = CLng(rs("ID_SONG"))
    sName  = rs("SONG_NAME") & ""
    sPath  = rs("SONG_PATH") & ""
    sPlays = ToInt(rs("PLAYS"), 0)
    sAlbum = rs("ALBUM") & ""
    sArtist = Trim(rs("ARTIST") & "")

    sAudio = AssetUrl(sPath)
    sHas   = AssetExists(sAudio)

    If sAlbum = "" Then sAlbum = "—"
    If sArtist = "" Then sArtist = "Artista desconocido"

    If sHas Then
        rowClass = "song-row"
    Else
        rowClass = "song-row is-unavailable"
    End If
%>
              <tr class="<%= rowClass %>"
                  data-id="<%= sId %>"
                  data-src="<%= H(sAudio) %>"
                  data-title="<%= H(sName) %>"
                  data-artist="<%= H(sArtist) %>"
                  data-art="<%= H(artUrl) %>"
                  data-available="<%= BoolNum(sHas) %>">
                <td class="col-index">
                  <span class="row-index"><%= Right("0" & i, 2) %></span>
                  <button type="button" class="row-play" data-play aria-label="Reproducir <%= H(sName) %>">
                    <svg class="ic-play" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.5v13l10-6.5z" fill="currentColor"/></svg>
                    <svg class="ic-pause" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.5h3v13H8zM13.5 5.5h3v13h-3z" fill="currentColor"/></svg>
                  </button>
                </td>
                <td class="col-title">
                  <div class="song-cell">
                    <img class="song-art" src="<%= H(artUrl) %>" alt="" width="44" height="44">
                    <div class="song-meta">
                      <span class="song-name"><%= H(sName) %></span>
                      <span class="song-artist"><%= H(sArtist) %></span>
                    </div>
                  </div>
                </td>
                <td class="col-album"><%= H(sAlbum) %></td>
                <td class="col-plays"><%= Num(sPlays) %></td>
                <td class="col-state">
                  <% If sHas Then %>
                  <span class="state state-ok"><span class="state-dot"></span>Disponible</span>
                  <% Else %>
                  <span class="state state-off"><span class="state-dot"></span>Sin audio</span>
                  <% End If %>
                </td>
                <% If IsAdmin() Then %>
                <td class="col-actions">
                  <div class="row-actions">
                    <a class="icon-btn" href="song_form.asp?mode=edit&amp;id=<%= sId %>" title="Editar" aria-label="Editar <%= H(sName) %>">
                      <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="m4.5 19.5 4.2-.9L19 8.3a1.6 1.6 0 0 0 0-2.3l-1-1a1.6 1.6 0 0 0-2.3 0L5.4 15.3z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/></svg>
                    </a>
                    <button type="button" class="icon-btn icon-btn-danger" data-delete="<%= sId %>" data-name="<%= H(sName) %>" title="Eliminar" aria-label="Eliminar <%= H(sName) %>">
                      <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M5 7h14M9.5 7V5.5h5V7M7 7l.8 12h8.4L17 7" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </button>
                  </div>
                </td>
                <% End If %>
              </tr>
<%
    rs.MoveNext
Loop

rs.Close
Set rs = Nothing
cn.Close
Set cn = Nothing
%>
            </tbody>
          </table>

          <% If totalSongs = 0 Then %>
          <div class="empty-state">
            <p>Todavía no hay canciones registradas.</p>
          </div>
          <% End If %>
        </div>
      </section>

      <footer class="page-foot">
        <p><%= APP_NAME %> &middot; Aplicación web en ASP Clásico con SQL Server</p>
        <p>Sesión iniciada como <strong><%= H(Session("Username")) %></strong></p>
      </footer>

      <!-- Reproductor -->
      <div class="player" id="player" data-player>
        <div class="player-track">
          <img class="np-art" id="npArt" src="<%= H(artUrl) %>" alt="">
          <div class="np-meta">
            <strong id="npTitle">Ninguna canción</strong>
            <span id="npArtist">Selecciona una canción del listado</span>
          </div>
        </div>

        <div class="player-center">
          <div class="player-controls">
            <button type="button" class="ctrl" id="btnPrev" aria-label="Anterior">
              <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 5.5h2v13H7zM19 5.5v13L9.5 12z" fill="currentColor"/></svg>
            </button>
            <button type="button" class="ctrl ctrl-main" id="btnPlay" aria-label="Reproducir">
              <svg class="ic-play" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.5v13l10-6.5z" fill="currentColor"/></svg>
              <svg class="ic-pause" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.5h3v13H8zM13.5 5.5h3v13h-3z" fill="currentColor"/></svg>
            </button>
            <button type="button" class="ctrl" id="btnNext" aria-label="Siguiente">
              <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M15 5.5h2v13h-2zM5 5.5v13L14.5 12z" fill="currentColor"/></svg>
            </button>
          </div>
          <div class="player-timeline">
            <span class="time" id="curTime">0:00</span>
            <input type="range" class="range" id="seek" min="0" max="100" value="0" step="0.1" aria-label="Progreso">
            <span class="time" id="durTime">0:00</span>
          </div>
        </div>

        <div class="player-right">
          <button type="button" class="ctrl ctrl-sm" id="btnMute" aria-label="Silenciar">
            <svg class="ic-vol" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 9.5h3.2L12 5.8v12.4L7.2 14.5H4z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="M15.5 9a4 4 0 0 1 0 6" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>
            <svg class="ic-mute" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M4 9.5h3.2L12 5.8v12.4L7.2 14.5H4z" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><path d="m15.5 9.5 4 5M19.5 9.5l-4 5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>
          </button>
          <input type="range" class="range range-vol" id="volume" min="0" max="1" step="0.01" value="0.8" aria-label="Volumen">
        </div>
      </div>
      <audio id="audio" preload="metadata"></audio>

      <!-- Modal de eliminacion (solo admin) -->
      <% If IsAdmin() Then %>
      <div class="modal" id="deleteModal" hidden>
        <div class="modal-backdrop" data-close-modal></div>
        <div class="modal-card" role="dialog" aria-modal="true" aria-labelledby="delTitle">
          <h3 id="delTitle">Eliminar canción</h3>
          <p>¿Seguro que quieres eliminar <strong id="delName"></strong>? Esta acción no se puede deshacer.</p>
          <form method="post" action="song_delete.asp" class="modal-actions">
            <input type="hidden" name="id" id="delId" value="">
            <button type="button" class="btn btn-ghost" data-close-modal>Cancelar</button>
            <button type="submit" class="btn btn-danger">Eliminar</button>
          </form>
        </div>
      </div>
      <% End If %>

<%
PageFoot
%>
