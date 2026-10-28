<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html lang="es" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Song list · PoliMusic</title>
    <link rel="stylesheet" href="Content/Song.css" />
</head>
<body>
    <form id="formSong" runat="server">
        <div class="app">

            <header class="topbar">
                <div class="topbar-inner">
                    <a class="brand" href="Default.aspx" title="PoliMusic">
                        <span class="brand-mark">
                            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                <path d="M9 17.4V6.9a1 1 0 0 1 .8-.98l6.3-1.26A1 1 0 0 1 17.4 5.6v9.9"
                                    stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
                                <circle cx="6.7" cy="17.7" r="2.3" fill="currentColor" />
                                <circle cx="15.1" cy="15.8" r="2.3" fill="currentColor" />
                            </svg>
                        </span>
                        <span class="brand-name">Poli<span>Music</span></span>
                    </a>

                    <span class="crumb">Biblioteca<span class="crumb-sep">/</span><strong>Song list</strong></span>

                    <div class="topbar-right">
                        <div class="user-chip">
                            <asp:Image ID="imgUserPhoto" runat="server" CssClass="avatar"
                                onerror="this.onerror=null;this.src='UserImages/default.jpg';" />
                            <span class="user-meta">
                                <span class="user-label">Welcome</span>
                                <span class="user-name"><asp:Literal ID="litUserName" runat="server"></asp:Literal></span>
                            </span>
                        </div>
                        <a class="btn-logout" href="Logout.aspx" title="Cerrar sesión">
                            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                <path d="M14.4 5.6H7.6A1.6 1.6 0 0 0 6 7.2v9.6a1.6 1.6 0 0 0 1.6 1.6h6.8"
                                    stroke="currentColor" stroke-width="1.6" stroke-linecap="round" />
                                <path d="M16.6 8.7 19.9 12l-3.3 3.3M10.6 12h9"
                                    stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" />
                            </svg>
                            <span>Logout</span>
                        </a>
                    </div>
                </div>
            </header>

            <main class="page">

                <section class="hero">
                    <div class="hero-copy">
                        <p class="eyebrow"><span class="dot"></span>Tu biblioteca</p>
                        <h1>Song <span class="grad">list</span></h1>
                        <p class="hero-sub">
                            Todo el catálogo en un solo lugar. Pulsa play y escucha: cada reproducción
                            suma al contador de la canción.
                        </p>
                        <div class="stats">
                            <span class="pill">
                                <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                    <path d="M9 16.8V7.4l8-1.6v9.4" stroke="currentColor" stroke-width="1.8"
                                        stroke-linecap="round" stroke-linejoin="round" />
                                    <circle cx="6.8" cy="17.4" r="2.2" fill="currentColor" />
                                    <circle cx="14.8" cy="15.4" r="2.2" fill="currentColor" />
                                </svg>
                                <b><asp:Literal ID="litTotalSongs" runat="server"></asp:Literal></b> canciones
                            </span>
                            <span class="pill">
                                <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                    <path d="M4.6 14.4v-2a7.4 7.4 0 0 1 14.8 0v2" stroke="currentColor"
                                        stroke-width="1.7" stroke-linecap="round" />
                                    <rect x="2.9" y="13.2" width="3.7" height="6.4" rx="1.5" stroke="currentColor" stroke-width="1.5" />
                                    <rect x="17.4" y="13.2" width="3.7" height="6.4" rx="1.5" stroke="currentColor" stroke-width="1.5" />
                                </svg>
                                <b><asp:Literal ID="litTotalPlays" runat="server"></asp:Literal></b> reproducciones
                            </span>
                        </div>
                    </div>

                    <div class="hero-art" aria-hidden="true">
                        <div class="vinyl"><span class="vinyl-label"></span></div>
                    </div>
                </section>

                <section class="panel">
                    <header class="panel-head">
                        <div class="panel-titles">
                            <h2>Listado de canciones</h2>
                            <p>Selecciona una canción del listado para reproducirla.</p>
                        </div>
                        <span class="count-chip"><asp:Literal ID="litSongCount" runat="server"></asp:Literal> tracks</span>
                    </header>

                    <asp:Panel ID="pnlTable" runat="server" CssClass="table-wrap">
                        <table class="songs">
                            <thead>
                                <tr>
                                    <th class="c-id" scope="col">ID Canción</th>
                                    <th class="c-name" scope="col">Nombre</th>
                                    <th class="c-path" scope="col">Ruta</th>
                                    <th class="c-plays" scope="col">Reproducciones</th>
                                    <th class="c-play" scope="col">Reproducir</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptSongs" runat="server">
                                    <ItemTemplate>
                                        <tr class='<%# RowClass(Eval("SongPath")) %>' data-id='<%# Eval("ID") %>'>
                                            <td class="c-id"><span class="id-chip"><%# Eval("ID") %></span></td>
                                            <td class="c-name">
                                                <span class="track-name">
                                                    <span class="track-disc" aria-hidden="true"></span>
                                                    <span class="track-title"><%# H(Eval("SongName")) %></span>
                                                </span>
                                            </td>
                                            <td class="c-path"><code><%# H(Eval("SongPath")) %></code></td>
                                            <td class="c-plays"><span class="plays" data-plays><%# PlaysText(Eval("Plays")) %></span></td>
                                            <td class="c-play">
                                                <div class="player" data-available='<%# AvailableFlag(Eval("SongPath")) %>'>
                                                    <button type="button" class="play-btn" data-play
                                                        aria-label="Reproducir canción"<%# DisabledAttribute(Eval("SongPath")) %>>
                                                        <svg class="ic-play" viewBox="0 0 24 24" aria-hidden="true">
                                                            <path d="M8.2 5.6v12.8L19 12z" fill="currentColor" />
                                                        </svg>
                                                        <svg class="ic-pause" viewBox="0 0 24 24" aria-hidden="true">
                                                            <path d="M8 5.5h3.2v13H8zM12.8 5.5H16v13h-3.2z" fill="currentColor" />
                                                        </svg>
                                                    </button>
                                                    <span class="missing-chip">Sin audio</span>
                                                    <div class="timeline">
                                                        <span class="time" data-cur>0:00</span>
                                                        <input type="range" class="seek" min="0" max="100" step="0.1"
                                                            value="0" aria-label="Progreso de la canción" />
                                                        <span class="time dur" data-dur>0:00</span>
                                                    </div>
                                                    <div class="vol-wrap">
                                                        <button type="button" class="vol-btn" data-mute aria-label="Silenciar">
                                                            <svg class="ic-vol" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                                                <path d="M4.5 9.6h3L12 6v12l-4.5-3.6h-3z" stroke="currentColor"
                                                                    stroke-width="1.6" stroke-linejoin="round" />
                                                                <path d="M15.4 9.2a4 4 0 0 1 0 5.6" stroke="currentColor"
                                                                    stroke-width="1.6" stroke-linecap="round" />
                                                            </svg>
                                                            <svg class="ic-muted" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                                                <path d="M4.5 9.6h3L12 6v12l-4.5-3.6h-3z" stroke="currentColor"
                                                                    stroke-width="1.6" stroke-linejoin="round" />
                                                                <path d="m15.6 9.7 4 4.6M19.6 9.7l-4 4.6" stroke="currentColor"
                                                                    stroke-width="1.6" stroke-linecap="round" />
                                                            </svg>
                                                        </button>
                                                        <input type="range" class="vol" min="0" max="1" step="0.01"
                                                            value="0.8" aria-label="Volumen" />
                                                    </div>
                                                    <audio preload="none" src='<%# SongUrl(Eval("SongPath")) %>'></audio>
                                                </div>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </asp:Panel>

                    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                        <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                            <circle cx="12" cy="12" r="8.4" stroke="currentColor" stroke-width="1.4" />
                            <circle cx="12" cy="12" r="2.1" fill="currentColor" />
                        </svg>
                        <asp:Literal ID="litEmptyMessage" runat="server"></asp:Literal>
                    </asp:Panel>
                </section>

                <footer class="foot">
                    <span>PoliMusic · Song list</span>
                    <span class="foot-dot"></span>
                    <span>Aplicación web ASP.NET con SQL Server</span>
                </footer>

            </main>
        </div>
    </form>

    <script type="text/javascript" src="Content/Song.js"></script>
</body>
</html>
