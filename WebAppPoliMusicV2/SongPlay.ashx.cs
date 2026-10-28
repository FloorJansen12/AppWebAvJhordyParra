using System;
using System.Configuration;
using System.Web;

namespace WebAppPoliMusicV2
{
    /// <summary>
    /// Handler que registra una reproducción (AJAX) sin recargar la página
    /// para que el audio no se corte. Responde con el nuevo contador.
    /// </summary>
    public class SongPlayHandler : IHttpHandler
    {
        public bool IsReusable
        {
            get { return false; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            int idSong;
            if (!int.TryParse(context.Request["id"], out idSong) || idSong <= 0)
            {
                context.Response.StatusCode = 400;
                context.Response.Write("-1");
                return;
            }

            try
            {
                string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
                int plays = new BLL.Song(strConnString).IncrementPlays(idSong);
                context.Response.Write(plays.ToString());
            }
            catch (Exception)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("-1");
            }
        }
    }
}
