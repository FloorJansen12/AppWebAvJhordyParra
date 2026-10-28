using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        private string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                LoadAuthenticatedUser();
                LoadSongs();
            }
        }

        /// <summary>
        /// Muestra en pantalla el nombre del usuario autenticado y su foto.
        /// </summary>
        private void LoadAuthenticatedUser()
        {
            Entities.User user = Session[Util.Constants.USER] as Entities.User;
            string userName = string.Empty;
            string photo = string.Empty;

            if (user != null)
            {
                userName = user.UserName;
                photo = user.Photo;
            }
            if (string.IsNullOrEmpty(userName) && Page.User != null && Page.User.Identity != null)
            {
                userName = Page.User.Identity.Name;
            }

            litUserName.Text = Server.HtmlEncode(userName);
            imgUserPhoto.ImageUrl = ResolveUrl(string.IsNullOrEmpty(photo) ? "~/UserImages/default.jpg" : photo);
            imgUserPhoto.AlternateText = userName;
        }

        /// <summary>
        /// Carga el listado de canciones desde la capa de negocio.
        /// </summary>
        private void LoadSongs()
        {
            try
            {
                List<Entities.Song> songs = new BLL.Song(strConnString).Read();

                rptSongs.DataSource = songs;
                rptSongs.DataBind();

                int totalPlays = 0;
                for (int i = 0; i < songs.Count; i++)
                {
                    totalPlays += songs[i].Plays;
                }

                litTotalSongs.Text = songs.Count.ToString();
                litTotalPlays.Text = totalPlays.ToString("N0");
                litSongCount.Text = songs.Count.ToString();

                pnlTable.Visible = songs.Count > 0;
                pnlEmpty.Visible = songs.Count == 0;
                if (songs.Count == 0)
                {
                    litEmptyMessage.Text = "Todavía no hay canciones registradas en la biblioteca.";
                }
            }
            catch (Exception ex)
            {
                pnlTable.Visible = false;
                pnlEmpty.Visible = true;
                litTotalSongs.Text = "0";
                litTotalPlays.Text = "0";
                litSongCount.Text = "0";
                litEmptyMessage.Text = "No se pudo cargar el listado de canciones. " + Server.HtmlEncode(ex.Message);
            }
        }

        /// <summary>
        /// Codifica el texto antes de pintarlo en la página.
        /// </summary>
        public string H(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value));
        }

        /// <summary>
        /// Convierte una ruta virtual (~/SongFiles/...) en una URL usable por el navegador.
        /// </summary>
        public string SongUrl(object songPath)
        {
            string path = Convert.ToString(songPath);
            if (string.IsNullOrEmpty(path))
            {
                return string.Empty;
            }
            return ResolveUrl(path);
        }

        /// <summary>
        /// Formatea el contador de reproducciones con separador de miles.
        /// </summary>
        public string PlaysText(object plays)
        {
            int value;
            if (!int.TryParse(Convert.ToString(plays), out value))
            {
                return "0";
            }
            return value.ToString("N0");
        }

        /// <summary>
        /// Clase CSS de la fila: las canciones sin archivo de audio se atenúan.
        /// </summary>
        public string RowClass(object songPath)
        {
            return AudioExists(songPath) ? "track" : "track is-unavailable";
        }

        /// <summary>
        /// Bandera que consume el JavaScript del reproductor.
        /// </summary>
        public string AvailableFlag(object songPath)
        {
            return AudioExists(songPath) ? "true" : "false";
        }

        /// <summary>
        /// Atributo disabled para el botón de play cuando el mp3 no está en disco.
        /// </summary>
        public string DisabledAttribute(object songPath)
        {
            return AudioExists(songPath) ? string.Empty : " disabled=\"disabled\"";
        }

        private bool AudioExists(object songPath)
        {
            string path = Convert.ToString(songPath);
            if (string.IsNullOrEmpty(path))
            {
                return false;
            }
            try
            {
                return File.Exists(Server.MapPath(path));
            }
            catch (Exception)
            {
                return false;
            }
        }
    }

}
