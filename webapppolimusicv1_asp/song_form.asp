<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="inc/config.asp" -->
<!--#include file="inc/auth.asp" -->
<!--#include file="inc/layout.asp" -->
<%
Response.CodePage = 65001
Response.CharSet  = "utf-8"

RequireLogin
RequireAdmin

Dim mode, isEdit, songId
Dim fName, fPath, fPlays, errMsg
Dim cn, rs, cmd, sql
Dim fileList, fso, folder, f, optPath

mode   = LCase(Request.QueryString("mode") & "")
If mode <> "edit" Then mode = "new"
isEdit = (mode = "edit")

songId = ToInt(Request.QueryString("id"), 0)
If isEdit And songId <= 0 Then
    Response.Redirect "songs.asp?msg=notfound"
    Response.End
End If

errMsg = ""
fName  = ""
fPath  = "~/songFiles/"
fPlays = 0

' ---------------- Archivos de audio disponibles ----------------
fileList = ""
On Error Resume Next
Set fso = Server.CreateObject("Scripting.FileSystemObject")
Set folder = fso.GetFolder(Server.MapPath(ASSETS_BASE & "/SongFiles"))
For Each f In folder.Files
    If LCase(fso.GetExtensionName(f.Name)) = "mp3" Then
        If fileList <> "" Then fileList = fileList & "|"
        fileList = fileList & f.Name
    End If
Next
Set folder = Nothing
Set fso    = Nothing
Err.Clear
On Error GoTo 0

' ---------------- Procesamiento del formulario ----------------
If UCase(Request.ServerVariables("REQUEST_METHOD")) = "POST" Then

    fName  = Trim(Request.Form("song_name") & "")
    fPath  = Trim(Request.Form("song_path") & "")
    fPlays = Trim(Request.Form("plays") & "")

    If fName = "" Then
        errMsg = "El nombre de la canción es obligatorio."
    ElseIf Len(fName) > 50 Then
        errMsg = "El nombre no puede superar los 50 caracteres."
    ElseIf fPath = "" Then
        errMsg = "La ruta del archivo es obligatoria."
    ElseIf Len(fPath) > 255 Then
        errMsg = "La ruta no puede superar los 255 caracteres."
    ElseIf Not IsNumeric(fPlays) Then
        errMsg = "Las reproducciones deben ser un número."
    ElseIf CDbl(fPlays) < 0 Or CDbl(fPlays) > 2147483647 Then
        errMsg = "Las reproducciones deben estar entre 0 y 2.147.483.647."
    End If

    If errMsg = "" Then
        ' Normaliza rutas escritas solo con el nombre del archivo
        If InStr(fPath, "/") = 0 And InStr(fPath, "\") = 0 Then
            fPath = "~/songFiles/" & fPath
        End If
        fPath = Replace(fPath, "\", "/")

        On Error Resume Next

        Set cn = DbOpen()
        If Err.Number <> 0 Then
            errMsg = "No se pudo conectar con la base de datos."
            Err.Clear
        Else
            Set cmd = Server.CreateObject("ADODB.Command")
            Set cmd.ActiveConnection = cn
            cmd.CommandType = 1

            If isEdit Then
                cmd.CommandText = "UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ?, PLAYS = ? WHERE ID_SONG = ?"
            Else
                cmd.CommandText = "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (?, ?, ?)"
            End If

            cmd.Parameters.Append cmd.CreateParameter("@name", 200, 1, 50, fName)
            cmd.Parameters.Append cmd.CreateParameter("@path", 200, 1, 255, fPath)
            cmd.Parameters.Append cmd.CreateParameter("@plays", 3, 1, , CLng(fPlays))
            If isEdit Then
                cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , songId)
            End If

            cmd.Execute , , 128

            If Err.Number <> 0 Then
                errMsg = "No se pudo guardar la canción."
                Err.Clear
            End If

            cn.Close
            Set cmd = Nothing
            Set cn  = Nothing
        End If

        On Error GoTo 0

        If errMsg = "" Then
            If isEdit Then
                Response.Redirect "songs.asp?msg=updated"
            Else
                Response.Redirect "songs.asp?msg=saved"
            End If
            Response.End
        End If
    End If

ElseIf isEdit Then

    ' ---------------- Carga de la cancion a editar ----------------
    On Error Resume Next
    Set cn = DbOpen()
    If Err.Number = 0 Then
        Set cmd = Server.CreateObject("ADODB.Command")
        Set cmd.ActiveConnection = cn
        cmd.CommandType = 1
        cmd.CommandText = "SELECT SONG_NAME, SONG_PATH, PLAYS FROM TBL_SONG WHERE ID_SONG = ?"
        cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , songId)
        Set rs = cmd.Execute

        If Err.Number = 0 Then
            If rs.EOF Then
                rs.Close
                cn.Close
                Response.Redirect "songs.asp?msg=notfound"
                Response.End
            End If
            fName  = rs("SONG_NAME") & ""
            fPath  = rs("SONG_PATH") & ""
            fPlays = ToInt(rs("PLAYS"), 0)
            rs.Close
        End If

        cn.Close
        Set rs  = Nothing
        Set cmd = Nothing
        Set cn  = Nothing
    End If
    Err.Clear
    On Error GoTo 0

End If

Dim pageAction, formTitle, formKicker
If isEdit Then
    pageAction = "song_form.asp?mode=edit&amp;id=" & songId
    formTitle  = "Editar canción"
    formKicker = "Actualiza los datos de la canción seleccionada."
Else
    pageAction = "song_form.asp?mode=new"
    formTitle  = "Nueva canción"
    formKicker = "Registra una canción en la biblioteca."
End If

PageHead formTitle, "songs"
%>
      <header class="topbar">
        <div class="crumbs">
          <span class="crumb-mark"></span>
          <a href="songs.asp">Song List</a>
          <span class="crumb-sep">/</span>
          <strong><%= formTitle %></strong>
        </div>
        <div class="topbar-right">
          <a class="btn btn-ghost" href="songs.asp">
            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M10 5.5 4.5 12 10 18.5M4.5 12H19" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>
            Volver
          </a>
        </div>
      </header>

      <section class="form-panel">
        <header class="form-head">
          <p class="eyebrow">Administración</p>
          <h1><%= formTitle %></h1>
          <p><%= formKicker %></p>
        </header>

        <% If errMsg <> "" Then %>
        <div class="flash flash-error" role="alert">
          <span><%= H(errMsg) %></span>
        </div>
        <% End If %>

        <form method="post" action="<%= pageAction %>" class="song-form">
          <div class="field">
            <label for="song_name">Nombre de la canción</label>
            <input id="song_name" name="song_name" type="text" maxlength="50" required
                   value="<%= H(fName) %>" placeholder="Ej. Adventure">
            <span class="field-hint">Máximo 50 caracteres.</span>
          </div>

          <div class="field">
            <label for="song_path">Archivo de audio</label>
            <input id="song_path" name="song_path" type="text" maxlength="255" required
                   value="<%= H(fPath) %>" list="fileOptions" placeholder="~/songFiles/archivo.mp3">
            <datalist id="fileOptions">
              <%
              Dim parts, k
              If fileList <> "" Then
                  parts = Split(fileList, "|")
                  For k = 0 To UBound(parts)
                      Response.Write "<option value=""~/songFiles/" & H(parts(k)) & """></option>"
                  Next
              End If
              %>
            </datalist>
            <span class="field-hint">Usa una ruta como <code>~/songFiles/archivo.mp3</code>. Los archivos existentes aparecen como sugerencia.</span>
          </div>

          <div class="field field-sm">
            <label for="plays">Reproducciones</label>
            <input id="plays" name="plays" type="number" min="0" step="1" value="<%= H(fPlays) %>">
          </div>

          <div class="form-actions">
            <a class="btn btn-ghost" href="songs.asp">Cancelar</a>
            <button class="btn btn-primary" type="submit">
              <% If isEdit Then %>Guardar cambios<% Else %>Crear canción<% End If %>
            </button>
          </div>
        </form>
      </section>

      <footer class="page-foot">
        <p><%= APP_NAME %> &middot; Aplicación web en ASP Clásico con SQL Server</p>
      </footer>
<%
PageFoot
%>
