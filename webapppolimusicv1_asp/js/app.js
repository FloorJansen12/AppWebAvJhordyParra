/* ============================================================
   PoliMusic - Interacciones de interfaz y reproductor
   ============================================================ */
(function () {
  'use strict';

  document.addEventListener('DOMContentLoaded', function () {
    initPasswordToggle();
    initFlash();
    initDeleteModal();
    initPlayer();
  });

  /* ----------------------------------------------------------
     Mostrar / ocultar contraseña (login)
     ---------------------------------------------------------- */
  function initPasswordToggle() {
    var toggle = document.querySelector('[data-toggle-pass]');
    var input = document.getElementById('password');
    if (!toggle || !input) return;

    toggle.addEventListener('click', function () {
      var isPass = input.type === 'password';
      input.type = isPass ? 'text' : 'password';
      toggle.classList.toggle('is-visible', isPass);
      input.focus();
    });
  }

  /* ----------------------------------------------------------
     Avisos de la pagina
     ---------------------------------------------------------- */
  function initFlash() {
    var flashes = document.querySelectorAll('[data-flash]');
    Array.prototype.forEach.call(flashes, function (box) {
      var close = box.querySelector('[data-flash-close]');
      if (close) {
        close.addEventListener('click', function () {
          box.parentNode.removeChild(box);
        });
      }
      window.setTimeout(function () {
        if (box.parentNode) {
          box.style.transition = 'opacity .3s ease, transform .3s ease';
          box.style.opacity = '0';
          box.style.transform = 'translateY(-4px)';
          window.setTimeout(function () {
            if (box.parentNode) box.parentNode.removeChild(box);
          }, 320);
        }
      }, 5200);
    });
  }

  /* ----------------------------------------------------------
     Modal de eliminacion (solo administrador)
     ---------------------------------------------------------- */
  function initDeleteModal() {
    var modal = document.getElementById('deleteModal');
    if (!modal) return;

    var inputId = document.getElementById('delId');
    var labelName = document.getElementById('delName');

    function close() {
      modal.hidden = true;
      if (inputId) inputId.value = '';
    }

    Array.prototype.forEach.call(
      document.querySelectorAll('[data-delete]'),
      function (btn) {
        btn.addEventListener('click', function () {
          if (inputId) inputId.value = btn.getAttribute('data-delete');
          if (labelName) labelName.textContent = btn.getAttribute('data-name') || '';
          modal.hidden = false;
        });
      }
    );

    Array.prototype.forEach.call(
      document.querySelectorAll('[data-close-modal]'),
      function (el) {
        el.addEventListener('click', close);
      }
    );

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && !modal.hidden) close();
    });
  }

  /* ----------------------------------------------------------
     Reproductor de audio
     ---------------------------------------------------------- */
  function initPlayer() {
    var audio = document.getElementById('audio');
    if (!audio) return;

    var rows = Array.prototype.slice.call(document.querySelectorAll('.song-row'));
    var playable = rows.filter(function (row) {
      return row.getAttribute('data-available') === '1';
    });

    var btnPlay = document.getElementById('btnPlay');
    var btnPrev = document.getElementById('btnPrev');
    var btnNext = document.getElementById('btnNext');
    var btnMute = document.getElementById('btnMute');
    var seek = document.getElementById('seek');
    var volume = document.getElementById('volume');
    var curTime = document.getElementById('curTime');
    var durTime = document.getElementById('durTime');
    var npTitle = document.getElementById('npTitle');
    var npArtist = document.getElementById('npArtist');
    var npArt = document.getElementById('npArt');
    var player = document.querySelector('[data-player]');

    var currentRow = null;

    /* ---------- utilidades ---------- */
    function formatTime(seconds) {
      if (!isFinite(seconds) || seconds < 0) return '0:00';
      var total = Math.floor(seconds);
      var min = Math.floor(total / 60);
      var sec = total % 60;
      return min + ':' + (sec < 10 ? '0' + sec : sec);
    }

    function setRangeFill(el, percent) {
      if (el) el.style.setProperty('--p', percent + '%');
    }

    function toast(message) {
      var box = document.createElement('div');
      box.className = 'toast';
      box.setAttribute('role', 'status');
      box.textContent = message;
      document.body.appendChild(box);
      window.setTimeout(function () {
        box.classList.add('is-out');
        window.setTimeout(function () {
          if (box.parentNode) box.parentNode.removeChild(box);
        }, 320);
      }, 3200);
    }

    function clearPlayingState() {
      rows.forEach(function (row) {
        row.classList.remove('is-playing');
      });
    }

    /* ---------- carga de una pista ---------- */
    function loadRow(row, autoplay) {
      currentRow = row;

      audio.src = row.getAttribute('data-src');

      if (npTitle) npTitle.textContent = row.getAttribute('data-title') || '';
      if (npArtist) npArtist.textContent = row.getAttribute('data-artist') || '';
      if (npArt) npArt.src = row.getAttribute('data-art') || '';

      if (seek) {
        seek.value = 0;
        setRangeFill(seek, 0);
      }
      if (curTime) curTime.textContent = '0:00';
      if (durTime) durTime.textContent = '0:00';

      if (autoplay) {
        var promise = audio.play();
        if (promise && typeof promise.catch === 'function') {
          promise.catch(function () {
            clearPlayingState();
            toast('No se pudo iniciar la reproducción.');
          });
        }
      }
    }

    function playRow(row) {
      if (!row) return;
      if (row.getAttribute('data-available') !== '1') {
        toast('El archivo de audio de esta canción no está disponible.');
        return;
      }
      if (row === currentRow) {
        if (audio.paused) {
          audio.play();
        } else {
          audio.pause();
        }
        return;
      }
      loadRow(row, true);
    }

    function step(delta) {
      if (!playable.length) {
        toast('No hay canciones con audio disponible.');
        return;
      }
      var index = playable.indexOf(currentRow);
      if (index === -1) index = delta > 0 ? -1 : 0;
      var next = (index + delta + playable.length) % playable.length;
      loadRow(playable[next], true);
    }

    /* ---------- eventos de las filas ---------- */
    rows.forEach(function (row) {
      row.addEventListener('click', function (event) {
        if (event.target.closest('a')) return;
        if (event.target.closest('[data-delete]')) return;
        playRow(row);
      });
    });

    /* ---------- controles ---------- */
    if (btnPlay) {
      btnPlay.addEventListener('click', function () {
        if (!currentRow) {
          if (!playable.length) {
            toast('No hay canciones con audio disponible.');
            return;
          }
          loadRow(playable[0], true);
          return;
        }
        if (audio.paused) {
          audio.play();
        } else {
          audio.pause();
        }
      });
    }

    if (btnPrev) btnPrev.addEventListener('click', function () { step(-1); });
    if (btnNext) btnNext.addEventListener('click', function () { step(1); });

    audio.addEventListener('play', function () {
      clearPlayingState();
      if (currentRow) currentRow.classList.add('is-playing');
      if (player) player.classList.add('is-playing');
      if (btnPlay) btnPlay.setAttribute('aria-label', 'Pausar');
    });

    audio.addEventListener('pause', function () {
      clearPlayingState();
      if (player) player.classList.remove('is-playing');
      if (btnPlay) btnPlay.setAttribute('aria-label', 'Reproducir');
    });

    audio.addEventListener('ended', function () {
      clearPlayingState();
      if (playable.length > 1) {
        step(1);
      }
    });

    audio.addEventListener('loadedmetadata', function () {
      if (durTime) durTime.textContent = formatTime(audio.duration);
    });

    audio.addEventListener('timeupdate', function () {
      if (!audio.duration) return;
      var percent = (audio.currentTime / audio.duration) * 100;
      if (seek) {
        seek.value = percent;
        setRangeFill(seek, percent);
      }
      if (curTime) curTime.textContent = formatTime(audio.currentTime);
    });

    audio.addEventListener('error', function () {
      if (!audio.src) return;
      clearPlayingState();
      toast('No se pudo cargar el archivo de audio.');
    });

    /* ---------- progreso ---------- */
    if (seek) {
      seek.addEventListener('input', function () {
        if (!audio.duration) return;
        var percent = parseFloat(seek.value) || 0;
        audio.currentTime = (percent / 100) * audio.duration;
        setRangeFill(seek, percent);
      });
    }

    /* ---------- volumen ---------- */
    function setVolume(value) {
      audio.volume = value;
      audio.muted = false;
      if (volume) {
        volume.value = value;
        setRangeFill(volume, value * 100);
      }
      if (btnMute) btnMute.classList.remove('is-muted');
    }

    function syncMuteIcon() {
      if (btnMute) btnMute.classList.toggle('is-muted', audio.muted || audio.volume === 0);
    }

    if (volume) {
      var initialVolume = parseFloat(volume.value);
      if (isNaN(initialVolume)) initialVolume = 0.8;
      setVolume(initialVolume);

      volume.addEventListener('input', function () {
        setVolume(parseFloat(volume.value) || 0);
      });
    }

    if (btnMute) {
      btnMute.addEventListener('click', function () {
        if (audio.muted) {
          audio.muted = false;
        } else {
          audio.muted = true;
        }
        syncMuteIcon();
      });
    }

    audio.addEventListener('volumechange', syncMuteIcon);
  }
})();
