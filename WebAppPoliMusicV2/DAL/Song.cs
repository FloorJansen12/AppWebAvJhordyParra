using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace WebAppPoliMusicV2.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla TBL_SONG (CRUD + contador de reproducciones).
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// CREATE: inserta una canción y devuelve el número de filas afectadas.
        /// </summary>
        public int Save(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "INSERT INTO [TBL_SONG] ([SONG_NAME], [SONG_PATH], [PLAYS]) " +
                        "VALUES (@SONG_NAME, @SONG_PATH, @PLAYS)";
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.SongName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.SongPath);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// READ: devuelve todas las canciones ordenadas por ID_SONG.
        /// </summary>
        public List<Entities.Song> Read()
        {
            List<Entities.Song> songs = new List<Entities.Song>();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], ISNULL([PLAYS], 0) AS [PLAYS] " +
                        "FROM [TBL_SONG] ORDER BY [ID_SONG]";
                    cmd.Connection = con;
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            songs.Add(MapSong(reader));
                        }
                    }
                }
            }
            return songs;
        }

        /// <summary>
        /// READ: devuelve una canción por su ID (null si no existe).
        /// </summary>
        public Entities.Song ReadById(int idSong)
        {
            Entities.Song song = null;
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT TOP 1 [ID_SONG], [SONG_NAME], [SONG_PATH], ISNULL([PLAYS], 0) AS [PLAYS] " +
                        "FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            song = MapSong(reader);
                        }
                    }
                }
            }
            return song;
        }

        /// <summary>
        /// UPDATE: actualiza nombre, ruta y reproducciones de una canción.
        /// </summary>
        public int Update(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET " +
                        "[SONG_NAME] = @SONG_NAME " +
                        ", [SONG_PATH] = @SONG_PATH " +
                        ", [PLAYS] = @PLAYS " +
                        "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", song.ID);
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.SongName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.SongPath);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// DELETE: elimina una canción por su ID.
        /// </summary>
        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "DELETE FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Suma una reproducción a la canción y devuelve el nuevo contador (-1 si no existe).
        /// </summary>
        public int IncrementPlays(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET [PLAYS] = ISNULL([PLAYS], 0) + 1 " +
                        "OUTPUT INSERTED.[PLAYS] " +
                        "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    object returnValue = cmd.ExecuteScalar();
                    if (returnValue == null || returnValue == DBNull.Value)
                    {
                        return -1;
                    }
                    return Convert.ToInt32(returnValue);
                }
            }
        }

        /// <summary>
        /// Comprueba si ya existe una canción con ese nombre (0 = no existe).
        /// </summary>
        public int CheckExistSong(string songName)
        {
            object returnValue;
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT TOP 1 [ID_SONG] FROM [TBL_SONG] WHERE [SONG_NAME] = @SONG_NAME";
                    cmd.Parameters.AddWithValue("@SONG_NAME", songName);
                    cmd.Connection = con;
                    con.Open();
                    returnValue = cmd.ExecuteScalar();
                    return (returnValue == null) ? 0 : Convert.ToInt32(returnValue);
                }
            }
        }

        /// <summary>
        /// Convierte la fila actual del lector en una entidad Song.
        /// </summary>
        private Entities.Song MapSong(SqlDataReader reader)
        {
            Entities.Song song = new Entities.Song();
            song.ID = Convert.ToInt32(reader["ID_SONG"]);
            song.SongName = Convert.ToString(reader["SONG_NAME"]);
            song.SongPath = Convert.ToString(reader["SONG_PATH"]);
            song.Plays = (reader["PLAYS"] == DBNull.Value) ? 0 : Convert.ToInt32(reader["PLAYS"]);
            return song;
        }
    }


}
