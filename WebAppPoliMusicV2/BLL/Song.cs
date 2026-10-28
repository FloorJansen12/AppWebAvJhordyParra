using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    /// <summary>
    /// Capa de negocio de las canciones: valida y delega en la DAL.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Save(song);
        }

        public List<Entities.Song> Read()
        {
            return new DAL.Song(strConnectionString).Read();
        }

        public Entities.Song ReadById(int idSong)
        {
            return new DAL.Song(strConnectionString).ReadById(idSong);
        }

        public int Update(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Update(song);
        }

        public int Delete(int idSong)
        {
            return new DAL.Song(strConnectionString).Delete(idSong);
        }

        public int IncrementPlays(int idSong)
        {
            return new DAL.Song(strConnectionString).IncrementPlays(idSong);
        }

        public int CheckExistSong(string songName)
        {
            return new DAL.Song(strConnectionString).CheckExistSong(songName);
        }

        /// <summary>
        /// Validaciones de negocio antes de guardar/actualizar una canción.
        /// Devuelve una cadena vacía cuando todo está correcto.
        /// </summary>
        public string ValidationsSong(Entities.Song song)
        {
            if (song == null)
            {
                return "La canción es requerida!";
            }
            if (string.IsNullOrEmpty(song.SongName) || song.SongName.Trim() == string.Empty)
            {
                return "El nombre de la canción es requerido!";
            }
            if (song.SongName.Length > 50)
            {
                return "El nombre no puede superar los 50 caracteres!";
            }
            if (string.IsNullOrEmpty(song.SongPath) || song.SongPath.Trim() == string.Empty)
            {
                return "La ruta del archivo es requerida!";
            }
            if (song.SongPath.Length > 255)
            {
                return "La ruta no puede superar los 255 caracteres!";
            }
            if (song.Plays < 0)
            {
                return "Las reproducciones no pueden ser negativas!";
            }
            return string.Empty;
        }
    }


}
